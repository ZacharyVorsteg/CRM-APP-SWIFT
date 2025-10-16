import SwiftUI

@main
struct TrusendaCRMApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // Check auth status on launch
                    await authManager.checkAuthStatus()
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @StateObject private var leadViewModel = LeadViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            LeadListView()
                .tabItem {
                    Label("Leads", systemImage: "person.2.fill")
                }
                .environmentObject(leadViewModel)
            
            FollowUpListView()
                .tabItem {
                    Label("Follow-Ups", systemImage: "calendar.badge.exclamationmark")
                }
                .environmentObject(leadViewModel)
                .badge(leadViewModel.followUpCount)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .environmentObject(settingsViewModel)
        }
        .task {
            await leadViewModel.fetchLeads()
        }
    }
}

