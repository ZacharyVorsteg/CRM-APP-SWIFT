import SwiftUI

@main
struct TrusendaCRMApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    init() {
        // Suppress UISceneDelegate warnings - we use SwiftUI lifecycle
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // Clear all auth state on app launch
                    await authManager.checkAuthStatus()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showWelcome = false
    @State private var showSplash = false
    @State private var previousAuthState = false
    @State private var hasShownSplash = false
    @State private var isNewUser = false
    @State private var onboardingComplete = false // Track if onboarding is finished
    
    var body: some View {
        ZStack {
            // Welcome screen - HIGHEST priority for new users
            if showWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .transition(.identity)
                    .zIndex(2000) // Above everything else
                    .ignoresSafeArea()
                    .onDisappear {
                        // Mark onboarding as complete when welcome finishes
                        onboardingComplete = true
                    }
            }
            
            // Enterprise splash screen - Second priority
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
                    .transition(.identity)
                    .zIndex(1000)
                    .ignoresSafeArea()
                    .onDisappear {
                        // When splash finishes, show welcome for new users IMMEDIATELY
                        if isNewUser {
                            // NO DELAY - show welcome synchronously
                            showWelcome = true
                        } else {
                            // Returning user - mark onboarding complete
                            onboardingComplete = true
                        }
                    }
            }
            
            // Main content - Hidden until onboarding complete
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .opacity((showSplash || showWelcome || (isNewUser && !onboardingComplete)) ? 0 : 1)
                } else {
                    LoginView()
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            // Show splash IMMEDIATELY when user authenticates
            if isAuthenticated && !previousAuthState && !hasShownSplash {
                // Check if this is a new user
                isNewUser = UserDefaults.standard.bool(forKey: "isNewUser")
                
                // Reset onboarding state
                onboardingComplete = false
                
                // Show splash immediately
                showSplash = true
                hasShownSplash = true
            }
            previousAuthState = isAuthenticated
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var leadViewModel = LeadViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            LeadListView()
                .tabItem {
                    Label("Leads", systemImage: "person.3.fill")
                }
                .environmentObject(leadViewModel)
            
            FollowUpListView()
                .tabItem {
                    Label("Follow-Ups", systemImage: "calendar.badge.clock")
                }
                .environmentObject(leadViewModel)
                .badge(leadViewModel.followUpCount)
            
            // Activity tab temporarily commented until file is added to Xcode project
            // Uncomment after: Right-click TrusendaCRM folder → Add Files → Select RecentActivityView.swift
            /*
            RecentActivityView()
                .tabItem {
                    Label("Activity", systemImage: "clock.arrow.circlepath")
                }
                .environmentObject(leadViewModel)
            */
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .environmentObject(settingsViewModel)
                .environmentObject(authManager)
        }
        .tint(.primaryBlue) // Salesforce blue for active tab
        .task {
            // Preload all data in parallel for instant tab switching
            async let leads: Void = leadViewModel.fetchLeads()
            async let tenantInfo: Void = settingsViewModel.fetchTenantInfo()
            async let publicForm: Void = settingsViewModel.fetchPublicForm()
            
            _ = await (leads, tenantInfo, publicForm)
        }
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

