import SwiftUI

struct ImportedContact: Identifiable {
    let id = UUID()
    let name: String
    let email: String?
    let phone: String?
}

// MARK: - Premium Success Toast
/// Premium success notification with elegant animations, undo, and edit functionality
/// Matches user feedback: gradients, shadows, typography hierarchy, auto-dismiss, haptics
struct PremiumSuccessToast: View {
    let leadName: String
    let onUndo: () -> Void
    let onDismiss: () -> Void
    
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkRotation: Double = -90
    @State private var opacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 14) {
            // Large animated checkmark with scale & rotation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
                .rotationEffect(.degrees(checkmarkRotation))
            
            // Typography hierarchy: Bold title + lighter subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text("Lead added")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("successfully")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Undo & Edit button with subtle background
            Button(action: {
                // Haptic on undo tap
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onUndo()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 10, weight: .semibold))
                    Text("UNDO & EDIT")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.3)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            // Softer green gradient (#2ECC71 to mint) - Premium depth
            LinearGradient(
                colors: [
                    adaptiveGreen,
                    adaptiveMint
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        // Multiple shadow layers for depth
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: adaptiveGreen.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 90) // Above tab bar
        .opacity(opacity)
        .onAppear {
            // Choreographed entrance animation
            // Haptic feedback on appear
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                checkmarkScale = 1.0
                checkmarkRotation = 0
            }
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    opacity = 0
                }
                
                // Dismiss after fade animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
    
    // MARK: - Dark Mode Adaptive Colors
    
    private var adaptiveGreen: Color {
        // Softer green in light mode, darker in dark mode
        colorScheme == .dark 
            ? Color(red: 0.15, green: 0.70, blue: 0.30) // Darker green
            : Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
    }
    
    private var adaptiveMint: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.60, blue: 0.40) // Darker mint
            : Color(red: 0.20, green: 0.89, blue: 0.65) // Lighter mint
    }
}

// MARK: - Premium Deleted Toast
/// Success notification for bulk deletion - matches "lead added" style
struct PremiumDeletedToast: View {
    let count: Int
    let onDismiss: () -> Void
    
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkRotation: Double = -90
    @State private var opacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 14) {
            // Large animated checkmark with scale & rotation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
                .rotationEffect(.degrees(checkmarkRotation))
            
            // Typography hierarchy: Bold count + Regular "successfully"
            VStack(alignment: .leading, spacing: 3) {
                Text("Deleted \(count) lead\(count == 1 ? "" : "s")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("successfully")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            // Softer green gradient (#2ECC71 to mint) - Premium depth
            LinearGradient(
                colors: [
                    adaptiveGreen,
                    adaptiveMint
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        // Multiple shadow layers for depth
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: adaptiveGreen.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 90) // Above tab bar
        .opacity(opacity)
        .onAppear {
            // Choreographed entrance animation
            // Haptic feedback on appear
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                opacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                checkmarkScale = 1.0
                checkmarkRotation = 0
            }
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    opacity = 0
                }
                
                // Dismiss after fade animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
    
    // MARK: - Dark Mode Adaptive Colors
    
    private var adaptiveGreen: Color {
        // Softer green in light mode, darker in dark mode
        colorScheme == .dark 
            ? Color(red: 0.15, green: 0.70, blue: 0.30) // Darker green
            : Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
    }
    
    private var adaptiveMint: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.60, blue: 0.40) // Darker mint
            : Color(red: 0.20, green: 0.89, blue: 0.65) // Lighter mint
    }
}

// MARK: - Premium Deletion Overlay
/// Enterprise-grade deletion progress overlay with Salesforce polish
struct PremiumDeletionOverlay: View {
    let current: Int
    let total: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var rotationAngle: Double = 0
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(colorScheme == .dark ? 0.7 : 0.4)
                .ignoresSafeArea()
            
            // Card with progress
            VStack(spacing: 24) {
                // Animated spinner
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.primaryBlue, Color.accentTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                    
                    // Checkmark icon with subtle rotation
                    Image(systemName: "trash.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                        .rotationEffect(.degrees(rotationAngle))
                }
                
                VStack(spacing: 8) {
                    // Title
                    Text("Deleting Leads")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Progress text
                    Text("\(current) of \(total)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Percentage
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(1.0)
        }
        .onAppear {
            // Subtle rotation animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct LeadListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var showAddLead = false
    @State private var showImportFromContacts = false
    @State private var selectedLead: Lead?
    @State private var showDeleteConfirm = false
    @State private var leadToDelete: Lead?
    @State private var importedContact: ImportedContact?
    @State private var deletedLead: Lead? // For undo functionality
    @State private var showUndoToast = false
    @State private var showSuccessToast = false
    @State private var lastAddedLead: Lead? // For undo & edit functionality
    @State private var isSelectionMode = false
    @State private var selectedLeadIds: Set<String> = []
    @State private var showBulkDeleteConfirm = false
    @State private var isDeletingBulk = false
    @State private var deletionProgress: (current: Int, total: Int) = (0, 0)
    @State private var showDeletedToast = false
    @State private var deletedCount = 0
    @State private var quickFollowUpSheet: FollowUpSheetData? // For quick follow-up from context menu
    @State private var followUpNotes = "" // Notes for quick follow-up
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background
                (colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.leads.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading leads...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.displayedLeads.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        // Plan limit banner
                        if viewModel.isOverLimit {
                            PlanLimitBanner(
                                gracePeriodDays: viewModel.gracePeriodDays,
                                isBlocked: viewModel.isBlocked
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        
                        ForEach(viewModel.displayedLeads) { lead in
                            HStack(spacing: 12) {
                                // Selection checkbox (only in selection mode)
                                if isSelectionMode {
                                    Button {
                                        toggleSelection(for: lead.id)
                                    } label: {
                                        Image(systemName: selectedLeadIds.contains(lead.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedLeadIds.contains(lead.id) ? .primaryBlue : .gray.opacity(0.3))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                LeadRowView(
                                    lead: lead,
                                    onStatusToggle: { newStatus in
                                        Task {
                                            await quickToggleStatus(lead: lead, newStatus: newStatus)
                                        }
                                    }
                                )
                                .environmentObject(viewModel)
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedLeadIds.contains(lead.id) ? Color.primaryBlue.opacity(0.08) : Color.cardBackground)
                                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                    .padding(.vertical, 4)
                            )
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isSelectionMode {
                                    toggleSelection(for: lead.id)
                                } else {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedLead = lead
                                }
                            }
                            .onAppear {
                                // Lazy loading - load more when approaching end
                                viewModel.loadMoreLeadsIfNeeded(currentLead: lead)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Delete action - Requires confirmation
                                Button(role: .destructive) {
                                    // Haptic feedback before showing confirmation
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.warning)
                                    
                                    leadToDelete = lead
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                // Edit action
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedLead = lead
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.primaryBlue)
                            }
                            .contextMenu {
                                // Quick Follow-Up Actions (matching cloud app)
                                Button {
                                    quickFollowUpSheet = FollowUpSheetData(lead: lead, days: 1)
                                } label: {
                                    Label("Follow up tomorrow", systemImage: "calendar.badge.plus")
                                }
                                
                                Button {
                                    quickFollowUpSheet = FollowUpSheetData(lead: lead, days: 3)
                                } label: {
                                    Label("Follow up in 3 days", systemImage: "calendar.badge.clock")
                                }
                                
                                Button {
                                    quickFollowUpSheet = FollowUpSheetData(lead: lead, days: 7)
                                } label: {
                                    Label("Follow up in 1 week", systemImage: "calendar.circle")
                                }
                                
                                Divider()
                                
                                Button {
                                    selectedLead = lead
                                } label: {
                                    Label("View Details", systemImage: "info.circle")
                                }
                            }
                        }
                        
                        // Loading indicator when fetching more
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.fetchLeads()
                    }
                }
            }
            .navigationTitle(isSelectionMode ? "\(selectedLeadIds.count) Selected" : "Leads (\(viewModel.filteredLeads.count))")
            .navigationBarTitleDisplayMode(.large)
            .tint(.primaryBlue)
            .background(
                LinearGradient(
                    colors: [Color.backgroundLight, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        Button("Done") {
                            exitSelectionMode()
                        }
                        .foregroundColor(.primaryBlue)
                        .font(.body.weight(.semibold))
                    } else {
                        Menu {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                showAddLead = true
                            } label: {
                                Label("Add Manually", systemImage: "square.and.pencil")
                            }
                            
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showImportFromContacts = true
                            } label: {
                                Label("Import from Contacts", systemImage: "person.crop.circle.badge.plus")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primaryBlue)
                        }
                        .disabled(viewModel.isBlocked)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode {
                        Button("Select All") {
                            selectAll()
                        }
                        .foregroundColor(.primaryBlue)
                        .font(.body)
                    } else {
                        Menu {
                            Button {
                                viewModel.statusFilter = nil
                                viewModel.applyFilters()
                            } label: {
                                Label("All Leads", systemImage: "line.3.horizontal.decrease")
                            }
                            
                            Divider()
                            
                            Button {
                                enterSelectionMode()
                            } label: {
                                Label("Select Leads", systemImage: "checkmark.circle")
                            }
                            
                            Divider()
                            
                            ForEach(["Cold", "Warm", "Hot", "Closed"], id: \.self) { status in
                                Button {
                                    viewModel.statusFilter = status
                                    viewModel.applyFilters()
                                } label: {
                                    Label(status, systemImage: statusIcon(status))
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Premium bulk delete button in selection mode
                if isSelectionMode && !selectedLeadIds.isEmpty {
                    VStack(spacing: 0) {
                        Button {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                            showBulkDeleteConfirm = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Delete \(selectedLeadIds.count) Lead\(selectedLeadIds.count == 1 ? "" : "s")")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.errorRed)
                                    .shadow(color: Color.errorRed.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                    .background(
                        // Subtle background with blur effect
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applyFilters()
            }
            .sheet(isPresented: $showAddLead) {
                AddLeadView()
                    .environmentObject(viewModel)
                    .onDisappear {
                        // Check if a new lead was added and show success toast
                        checkForNewLeadAndShowToast()
                    }
            }
            .sheet(item: $importedContact) { contact in
                // This creates a NEW view with the contact data
                AddLeadView(
                    prefilledName: contact.name,
                    prefilledEmail: contact.email,
                    prefilledPhone: contact.phone
                )
                .environmentObject(viewModel)
            }
            .sheet(isPresented: $showImportFromContacts) {
                ContactsPickerView { name, email, phone in
                    print("✅ Contact selected: \(name)")
                    
                    // Create ImportedContact item - this triggers the sheet
                    importedContact = ImportedContact(name: name, email: email, phone: phone)
                    
                    print("🔧 ImportedContact created: \(importedContact!.name)")
                }
            }
            .sheet(item: $selectedLead) { lead in
                LeadDetailView(lead: lead)
                    .environmentObject(viewModel)
            }
            .sheet(item: $quickFollowUpSheet) { data in
                QuickFollowUpNotesView(
                    lead: data.lead,
                    daysFromNow: data.days,
                    notes: $followUpNotes,
                    onSave: {
                        Task {
                            await saveQuickFollowUp(lead: data.lead, days: data.days)
                        }
                    },
                    onCancel: {
                        quickFollowUpSheet = nil
                        followUpNotes = ""
                    }
                )
            }
            .alert("Delete Lead", isPresented: $showDeleteConfirm, presenting: leadToDelete) { lead in
                Button("Cancel", role: .cancel) {
                    // Haptic feedback for cancel
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                Button("Delete", role: .destructive) {
                    Task {
                        await performDelete(lead: lead)
                    }
                }
            } message: { lead in
                Text("Are you sure you want to delete \(lead.name)?")
            }
            .alert("Delete Multiple Leads", isPresented: $showBulkDeleteConfirm) {
                Button("Cancel", role: .cancel) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                Button("Delete All", role: .destructive) {
                    Task {
                        await performBulkDelete()
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(selectedLeadIds.count) lead\(selectedLeadIds.count == 1 ? "" : "s")? This action cannot be undone.")
            }
            .overlay {
                // Premium deletion overlay
                if isDeletingBulk {
                    PremiumDeletionOverlay(
                        current: deletionProgress.current,
                        total: deletionProgress.total
                    )
                    .transition(.opacity)
                    .zIndex(1000)
                }
            }
            .overlay(alignment: .bottom) {
                // Priority: Deleted toast > Success toast > Undo delete > Status updates > Errors
                if showDeletedToast {
                    PremiumDeletedToast(
                        count: deletedCount,
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showDeletedToast = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showDeletedToast)
                    .zIndex(100)
                } else if showSuccessToast, let lead = lastAddedLead {
                    PremiumSuccessToast(
                        leadName: lead.name,
                        onUndo: {
                            undoAndEditLead(lead)
                        },
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showSuccessToast = false
                                lastAddedLead = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSuccessToast)
                    .zIndex(100)
                } else if showUndoToast, let deleted = deletedLead {
                    PremiumUndoToast(
                        leadName: deleted.name,
                        onUndo: {
                            Task {
                                await undoDelete(lead: deleted)
                            }
                        },
                        onDismiss: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showUndoToast = false
                                deletedLead = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showUndoToast)
                    .zIndex(100)
                } else if let message = viewModel.successMessage {
                    ToastView(message: message, isError: false)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: viewModel.successMessage)
                } else if let error = viewModel.error {
                    ToastView(message: error, isError: true)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: viewModel.error)
                        .onTapGesture {
                            viewModel.clearError()
                        }
                }
            }
        }
    }
    
    // MARK: - Quick Status Toggle
    private func quickToggleStatus(lead: Lead, newStatus: String) async {
        // Don't proceed if same status
        guard lead.status != newStatus else { return }
        
        // Haptic feedback for status change
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Update lead status - only send status field
        var updates = LeadUpdatePayload()
        updates.status = newStatus
        
        do {
            print("🔄 Updating lead \(lead.id) from \(lead.status) to \(newStatus)")
            
            // Update the lead via API (uses optimistic update internally)
            try await viewModel.updateLead(id: lead.id, updates: updates, optimistic: true)
            
            print("✅ Status updated successfully to \(newStatus)")
            
            // Success haptic
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)
            
            // Show brief success message
            viewModel.successMessage = "Status updated to \(newStatus)"
            
        } catch {
            print("❌ Status update failed: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(error.localizedDescription)")
            print("❌ Lead ID that failed: \(lead.id)")
            print("❌ Total leads in local cache: \(viewModel.leads.count)")
            
            // Error haptic
            let errorGenerator = UINotificationFeedbackGenerator()
            errorGenerator.notificationOccurred(.error)
            
            // Show helpful error message based on error type
            if let networkError = error as? NetworkError {
                switch networkError {
                case .serverError(let code, let message):
                    if code == 404 {
                        viewModel.error = "Lead not found. Please refresh and try again."
                        // Refresh leads to sync with server
                        Task {
                            await viewModel.fetchLeads()
                        }
                    } else {
                        viewModel.error = message ?? "Server error (\(code))"
                    }
                case .unauthorized:
                    viewModel.error = "Session expired. Please log in again."
                default:
                    viewModel.error = error.localizedDescription
                }
            } else {
                viewModel.error = "Failed to update: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Delete with Undo
    private func performDelete(lead: Lead) async {
        // Save lead for undo
        deletedLead = lead
        
        // Haptic feedback for deletion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Delete lead
        do {
            try await viewModel.deleteLead(id: lead.id)
            
            // Clear any viewModel success messages to prevent duplicates
            viewModel.successMessage = nil
            
            // Show undo toast
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showUndoToast = true
            }
            
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if showUndoToast {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showUndoToast = false
                        deletedLead = nil
                    }
                }
            }
        } catch {
            // Error haptic
            let errorGenerator = UINotificationFeedbackGenerator()
            errorGenerator.notificationOccurred(.error)
        }
    }
    
    // MARK: - Undo Delete
    private func undoDelete(lead: Lead) async {
        // Haptic feedback for undo
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Hide toast
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            showUndoToast = false
        }
        
        // Re-create the lead
        do {
            let payload = LeadCreatePayload(
                name: lead.name,
                email: lead.email,
                phone: lead.phone,
                company: lead.company,
                budget: lead.budget,
                sizeMin: lead.sizeMin,
                sizeMax: lead.sizeMax,
                propertyType: lead.propertyType,
                transactionType: lead.transactionType,
                moveTiming: lead.moveTiming,
                moveStartDate: lead.moveStartDate,
                moveEndDate: lead.moveEndDate,
                timelineStatus: lead.timelineStatus,
                daysUntilMove: lead.daysUntilMove,
                status: lead.status,
                preferredArea: lead.preferredArea,
                industry: lead.industry,
                leaseTerm: lead.leaseTerm,
                notes: lead.notes,
                followUpOn: lead.followUpOn,
                followUpNotes: lead.followUpNotes
            )
            
            try await viewModel.createLead(payload)
            
            // Success haptic
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)
            
            viewModel.successMessage = "✅ Lead restored"
            
            // Clear deleted lead
            deletedLead = nil
        } catch {
            viewModel.error = "Failed to restore lead"
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        switch status {
        case "Cold": return "snowflake"
        case "Warm": return "flame"
        case "Hot": return "flame.fill"
        case "Closed": return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    
    // MARK: - Selection Mode Functions
    
    private func enterSelectionMode() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSelectionMode = true
        }
    }
    
    private func exitSelectionMode() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSelectionMode = false
            selectedLeadIds.removeAll()
        }
    }
    
    private func toggleSelection(for leadId: String) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if selectedLeadIds.contains(leadId) {
            selectedLeadIds.remove(leadId)
        } else {
            selectedLeadIds.insert(leadId)
        }
    }
    
    private func selectAll() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Select all visible filtered leads
        let allVisibleIds = Set(viewModel.filteredLeads.map { $0.id })
        
        if selectedLeadIds == allVisibleIds {
            // Deselect all
            selectedLeadIds.removeAll()
        } else {
            // Select all
            selectedLeadIds = allVisibleIds
        }
    }
    
    // MARK: - Quick Follow-Up Save
    private func saveQuickFollowUp(lead: Lead, days: Int) async {
        // Calculate follow-up date (matching cloud app logic)
        let followUpDate = Date.addingDays(days)
        
        print("📅 Scheduling follow-up for \(lead.name) in \(days) days: \(followUpDate.toDisplayString())")
        
        // Prepare updates
        var updates = LeadUpdatePayload()
        updates.followUpOn = followUpDate.toISO8601String()
        updates.followUpNotes = followUpNotes.isEmpty ? nil : followUpNotes
        updates.needsAttention = false // Reset needs_attention when setting new follow-up (matches cloud)
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            
            print("✅ Follow-up scheduled successfully")
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Close sheet and reset
            quickFollowUpSheet = nil
            followUpNotes = ""
            
            // Show success message
            let dayLabel = days == 1 ? "tomorrow" : days == 7 ? "next week" : "in \(days) days"
            viewModel.successMessage = "✅ Follow-up scheduled for \(dayLabel)"
            
        } catch {
            print("❌ Failed to schedule follow-up: \(error)")
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            viewModel.error = "Failed to schedule follow-up"
        }
    }
    
    private func performBulkDelete() async {
        let idsToDelete = Array(selectedLeadIds)
        let countToDelete = idsToDelete.count
        
        // Start deletion process
        await MainActor.run {
            isDeletingBulk = true
            deletionProgress = (0, countToDelete)
        }
        
        // Initial haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        var successCount = 0
        var failedCount = 0
        
        // Delete with progress tracking
        for (index, leadId) in idsToDelete.enumerated() {
            do {
                try await viewModel.deleteLead(id: leadId)
                successCount += 1
                
                // Update progress
                await MainActor.run {
                    deletionProgress = (index + 1, countToDelete)
                }
                
                // Subtle haptic every 5 deletions for feedback
                if (index + 1) % 5 == 0 {
                    let lightGenerator = UIImpactFeedbackGenerator(style: .light)
                    lightGenerator.impactOccurred()
                }
                
            } catch {
                failedCount += 1
                print("Failed to delete lead \(leadId): \(error)")
            }
        }
        
        // Complete deletion
        await MainActor.run {
            isDeletingBulk = false
            
            // Success feedback
            if failedCount == 0 {
                let successGenerator = UINotificationFeedbackGenerator()
                successGenerator.notificationOccurred(.success)
                
                // Show premium deleted toast
                deletedCount = successCount
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showDeletedToast = true
                }
            } else {
                let warningGenerator = UINotificationFeedbackGenerator()
                warningGenerator.notificationOccurred(.warning)
                
                viewModel.error = "⚠️ Deleted \(successCount), \(failedCount) failed"
            }
            
            // Smooth exit from selection mode
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                isSelectionMode = false
                selectedLeadIds.removeAll()
            }
        }
    }
    
    // MARK: - Success Toast Integration
    
    private func checkForNewLeadAndShowToast() {
        // Check if a new lead was added (first lead in list with recent timestamp)
        guard let firstLead = viewModel.leads.first else { return }
        
        // Check if lead was added within the last 5 seconds
        if let createdDate = firstLead.createdDate,
           Date().timeIntervalSince(createdDate) < 5 {
            lastAddedLead = firstLead
            
            // Clear any ViewModel success messages to avoid conflicts
            viewModel.successMessage = nil
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showSuccessToast = true
            }
        }
    }
    
    private func undoAndEditLead(_ lead: Lead) {
        // Delete the lead
        Task {
            do {
                try await viewModel.deleteLead(id: lead.id)
                
                // Dismiss success toast
                withAnimation(.easeOut(duration: 0.2)) {
                    showSuccessToast = false
                }
                
                // Brief delay before opening edit modal
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                
                // Reopen AddLeadView with lead data pre-filled
                await MainActor.run {
                    // Create imported contact to trigger AddLeadView with data
                    importedContact = ImportedContact(
                        name: lead.name,
                        email: lead.email,
                        phone: lead.phone
                    )
                }
                
                // Success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
            } catch {
                viewModel.error = "Failed to undo: \(error.localizedDescription)"
            }
        }
    }
}

struct LeadRowView: View {
    let lead: Lead
    let onStatusToggle: (String) -> Void
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var showStatusMenu = false
    @State private var showFollowUpSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Avatar + Name + Status
            HStack(alignment: .top, spacing: 12) {
                // Avatar circle with initials (color-coded by status for consistency)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: avatarGradient(for: lead.status),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(getInitials(from: lead.name))
                        .font(.system(size: getInitials(from: lead.name).count == 1 ? 18 : 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(lead.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Company directly under name for better hierarchy
                    if let company = lead.company, !company.isEmpty {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Quick status toggle button
                Menu {
                    ForEach(["Cold", "Warm", "Hot", "Closed"], id: \.self) { status in
                        Button {
                            onStatusToggle(status)
                        } label: {
                            HStack {
                                Image(systemName: getStatusIcon(status))
                                Text(status)
                                if status == lead.status {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: getStatusIcon(lead.status))
                            .font(.system(size: 10, weight: .semibold))
                        Text(lead.status)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor(lead.status).opacity(0.15))
                    .foregroundColor(statusColor(lead.status))
                    .cornerRadius(12)
                }
            }
            
            // Key Details Row - More compact
            HStack(spacing: 12) {
                // Timeline badge
                if let timeline = lead.timelineStatus {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                        Text(timeline)
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(timelineColor(timeline).opacity(0.15))
                    .foregroundColor(timelineColor(timeline))
                    .cornerRadius(8)
                }
                
                // Area (condensed)
                if let area = lead.preferredArea, !area.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                        Text(area)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            // Follow-up Banner (if due) - with relative dates
            if lead.isFollowUpDue, let followUpDate = lead.followUpDate {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: followUpDate.isToday ? "calendar.badge.exclamationmark" : "exclamationmark.triangle.fill")
                            .foregroundColor(followUpDate.isPast ? .red : .orange)
                            .font(.system(size: 13))
                        Text(followUpDate.isToday ? "Follow up Today" : "Overdue (\(followUpDate.toRelativeString()))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(followUpDate.isPast ? .red : .orange)
                    }
                    
                    // Task notes preview
                    if let notes = lead.followUpNotes, !notes.isEmpty {
                        Text("Task: \(notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(followUpDate.isPast ? Color.red.opacity(0.1) : Color.orange.opacity(0.12))
                .cornerRadius(8)
            }
            
            // Action Buttons Row - VISIBLE & CLEAR with better spacing
            HStack(spacing: 10) {
                // Schedule Follow-Up Button (Primary Action)
                Button {
                    showFollowUpSheet = true
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: lead.followUpOn != nil ? "calendar.badge.clock" : "calendar.badge.plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text(lead.followUpOn != nil ? "Reschedule" : "Schedule")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(
                            colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.primaryBlue.opacity(0.25), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                
                // Quick Follow-Up Menu (Secondary Actions)
                Menu {
                    Button {
                        Task {
                            await scheduleQuickFollowUp(days: 1)
                        }
                    } label: {
                        Label("Tomorrow", systemImage: "1.circle.fill")
                    }
                    
                    Button {
                        Task {
                            await scheduleQuickFollowUp(days: 3)
                        }
                    } label: {
                        Label("In 3 days", systemImage: "3.circle.fill")
                    }
                    
                    Button {
                        Task {
                            await scheduleQuickFollowUp(days: 7)
                        }
                    } label: {
                        Label("In 1 week", systemImage: "7.circle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.primaryBlue.opacity(0.12))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                // Date Added (relative for recent, full date for old)
                if let createdDate = lead.createdDate {
                    let daysAgo = -createdDate.daysFromNow()
                    let dateText = daysAgo <= 7 ? createdDate.toRelativeString() : createdDate.toDisplayString()
                    Text("Added \(dateText)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .sheet(isPresented: $showFollowUpSheet) {
            FollowUpScheduleView(lead: lead)
                .environmentObject(viewModel)
        }
    }
    
    // Quick follow-up scheduling
    private func scheduleQuickFollowUp(days: Int) async {
        let followUpDate = Date.addingDays(days)
        
        var updates = LeadUpdatePayload()
        updates.followUpOn = followUpDate.toISO8601String()
        updates.needsAttention = false
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Show success message
            let dayLabel = days == 1 ? "tomorrow" : days == 7 ? "next week" : "in \(days) days"
            viewModel.successMessage = "✅ Follow-up scheduled for \(dayLabel)"
        } catch {
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            viewModel.error = "Failed to schedule follow-up"
        }
    }
    
    private func getStatusIcon(_ status: String) -> String {
        switch status {
        case "Cold": return "snowflake"
        case "Warm": return "flame"
        case "Hot": return "flame.fill"
        case "Closed": return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Cold": return .statusCold
        case "Warm": return .statusWarm
        case "Hot": return .statusHot
        case "Closed": return .statusClosed
        default: return .secondary
        }
    }
    
    private func timelineColor(_ timeline: String) -> Color {
        switch timeline {
        case "Immediate": return .timelineImmediate
        case "Heating Up": return .timelineHeating
        case "Upcoming": return .timelineUpcoming
        case "Overdue": return .timelineOverdue
        default: return .secondary
        }
    }
    
    // Generate purposeful color gradient based on lead STATUS
    // Matches CRM priority and ensures consistency across app
    private func avatarGradient(for status: String) -> [Color] {
        switch status {
        case "Cold":
            // Blue - calm, early stage (accessible contrast)
            return [Color.blue.opacity(0.85), Color.blue]
        case "Warm":
            // Orange - heating up, attention needed
            return [Color.orange.opacity(0.85), Color.orange]
        case "Hot":
            // Red - urgent, high priority
            return [Color.red.opacity(0.85), Color.red]
        case "Closed":
            // Green - success, completed
            return [Color.green.opacity(0.85), Color.green]
        default:
            // Gray - neutral/unknown
            return [Color.gray.opacity(0.8), Color.gray]
        }
    }
    
    // Get initials with smart fallback logic
    // Handles duplicates, long names, and edge cases
    private func getInitials(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let components = trimmed.split(separator: " ")
        
        if components.count >= 2 {
            // First + Last initial (e.g., "John Smith" → "JS")
            // Helps differentiate duplicates like "John Adams" vs "Jane Smith"
            let first = components.first?.prefix(1).uppercased() ?? ""
            let last = components.last?.prefix(1).uppercased() ?? ""
            return "\(first)\(last)"
        } else if trimmed.count >= 2 {
            // First two letters for single names (e.g., "Eli" → "EL")
            return trimmed.prefix(2).uppercased()
        } else {
            // Single letter fallback (e.g., "E" → "E")
            return trimmed.prefix(1).uppercased()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Premium illustration background
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.primaryBlue.opacity(0.6))
            }
            .padding(.bottom, 8)
            
            Text("No Leads Yet")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            
            Text("Tap the + button above to add your first lead and start tracking opportunities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct PlanLimitBanner: View {
    let gracePeriodDays: Int?
    let isBlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isBlocked ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(isBlocked ? .errorRed : .warningOrange)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(isBlocked ? "Lead Limit Reached" : "Over Plan Limit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isBlocked ? .errorRed : .warningOrange)
                
                if let days = gracePeriodDays, !isBlocked {
                    Text("\(days) days remaining to upgrade or remove leads")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                } else if isBlocked {
                    Text("Upgrade to Pro or remove excess leads to continue")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isBlocked ? Color.errorRed.opacity(0.1) : Color.warningOrange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isBlocked ? Color.errorRed.opacity(0.3) : Color.warningOrange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct ToastView: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 16))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isError ? Color.errorRed : Color.successGreen)
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .padding()
    }
}

// MARK: - Premium Undo Toast
struct PremiumUndoToast: View {
    let leadName: String
    let onUndo: () -> Void
    let onDismiss: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated checkmark with scale effect
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.0)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Lead deleted")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(leadName)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Undo button - Premium style
            Button(action: onUndo) {
                Text("UNDO")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // Salesforce success green with gradient
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.78, blue: 0.35), // #34C759
                    Color(red: 0.15, green: 0.68, blue: 0.30)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        .shadow(color: Color(red: 0.20, green: 0.78, blue: 0.35).opacity(0.4), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 90) // Above tab bar
        .onAppear {
            // Animate checkmark on appear
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

import SwiftUI

// MARK: - Follow-Up Sheet Data
struct FollowUpSheetData: Identifiable {
    let id = UUID()
    let lead: Lead
    let days: Int
}

// MARK: - Quick Follow-Up Notes View
struct QuickFollowUpNotesView: View {
    let lead: Lead
    let daysFromNow: Int
    @Binding var notes: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    private var dayLabel: String {
        switch daysFromNow {
        case 1: return "Tomorrow"
        case 3: return "In 3 Days"
        case 7: return "In 1 Week"
        default: return "In \(daysFromNow) Days"
        }
    }
    
    private var followUpDate: Date {
        // Match cloud app logic EXACTLY
        // Cloud uses: date.setDate(date.getDate() + days)
        // Using the new Date helper that matches cloud's addDaysToDate function
        return Date.addingDays(daysFromNow)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with lead info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Follow up with")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(lead.name)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    if let company = lead.company {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Date display with debug info
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.primaryBlue)
                        Text(dayLabel)
                            .fontWeight(.semibold)
                        Text("(\(followUpDate.toDisplayString()))")
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryBlue.opacity(0.05))
                )
                
                // Task/Notes input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you need to do?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Example: \"Send proposal\", \"Call about warehouse\", \"Follow up on budget\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if notes.isEmpty {
                                    Text("Enter your task or notes here...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 12)
                                        .padding(.top, 16)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.body.weight(.medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    Button("Schedule") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        onSave()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.primaryBlue)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding()
            }
            .navigationTitle("Schedule Follow-Up")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

