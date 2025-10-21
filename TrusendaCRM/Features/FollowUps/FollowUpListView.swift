import SwiftUI

struct FollowUpListView: View {
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var selectedLead: Lead?
    @State private var showAddFollowUpPicker = false
    @State private var leadToSchedule: Lead?
    
    var followUpLeads: [Lead] {
        // ENHANCED: Show ALL follow-ups (not just due ones) - acts like a queue
        // Sort by date (soonest first) so users can see their full pipeline
        let allFollowUps = viewModel.leads.filter { lead in
            lead.followUpOn != nil  // Has a follow-up scheduled
        }
        
        // Sort by follow-up date (soonest first = top of queue)
        let sorted = allFollowUps.sorted { lead1, lead2 in
            guard let date1 = lead1.followUpDate, let date2 = lead2.followUpDate else {
                return false
            }
            return date1 < date2  // Earliest dates first
        }
        
        return sorted
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if followUpLeads.isEmpty {
                    // Enhanced empty state with warmth and personality
                    VStack(spacing: 24) {
                        // Illustration - Checked calendar with gentle animation
                        ZStack {
                            // Background circle with gradient
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.primaryBlue.opacity(0.1), Color.successGreen.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            // Calendar icon
                            Image(systemName: "calendar.badge.checkmark")
                                .font(.system(size: 70, weight: .regular))
                                .foregroundColor(.successGreen)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 12) {
                            Text("All Caught Up!")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text("You have no follow-ups scheduled right now.\nTap the + button above to add one.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 40)
                        }
                        
                        // Helpful tip - Matches top gradient aesthetic
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            Text("Tip: Use quick actions on leads to schedule follow-ups")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.primaryBlue.opacity(0.1), Color.successGreen.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 60)
                } else {
                    List {
                        ForEach(followUpLeads) { lead in
                            FollowUpRowView(lead: lead)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.cardBackground)
                                        .overlay(
                                            // Subtle urgency border - left edge accent
                                            HStack {
                                                if lead.isOverdue {
                                                    Rectangle()
                                                        .fill(Color.errorRed)
                                                        .frame(width: 4)
                                                } else if lead.isFollowUpDue {
                                                    Rectangle()
                                                        .fill(Color.warningOrange)
                                                        .frame(width: 4)
                                                }
                                                Spacer()
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    lead.isOverdue ? Color.errorRed.opacity(0.3) :
                                                    lead.isFollowUpDue ? Color.warningOrange.opacity(0.25) :
                                                    Color.gray.opacity(0.12),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(
                                            color: lead.isFollowUpDue ? Color.orange.opacity(0.12) : Color.black.opacity(0.05),
                                            radius: 6,
                                            x: 0,
                                            y: 3
                                        )
                                        .padding(.vertical, 4)
                                )
                                .listRowSeparator(.hidden)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedLead = lead
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        // Success haptic feedback
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                        
                                        Task {
                                            try? await viewModel.markContacted(leadId: lead.id)
                                        }
                                    } label: {
                                        Label("Done", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.successGreen)
                                }
                                // Smooth animations for list updates
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top)),
                                    removal: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .leading))
                                ))
                                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: followUpLeads.count)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.fetchLeads()
                    }
                }
            }
            .navigationTitle("Follow-Ups")
            .navigationBarTitleDisplayMode(.large)
            .tint(.primaryBlue)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            // Filter: Today only
                        } label: {
                            Label("Due Today", systemImage: "calendar")
                        }
                        
                        Button {
                            // Filter: Overdue
                        } label: {
                            Label("Overdue", systemImage: "exclamationmark.triangle")
                        }
                        
                        Divider()
                        
                        Button {
                            // Show all
                        } label: {
                            Label("All Follow-Ups", systemImage: "list.bullet")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        showAddFollowUpPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.05), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .sheet(item: $selectedLead) { lead in
                LeadDetailView(lead: lead)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showAddFollowUpPicker) {
                SearchableLeadPickerView(selectedLead: $leadToSchedule)
                    .environmentObject(viewModel)
            }
            .sheet(item: $leadToSchedule) { lead in
                FollowUpScheduleView(lead: lead)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - Searchable Lead Picker
struct SearchableLeadPickerView: View {
    @EnvironmentObject var viewModel: LeadViewModel
    @Binding var selectedLead: Lead?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    // Alphabetically sorted leads
    var sortedLeads: [Lead] {
        viewModel.leads.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    // Filtered leads based on search
    var filteredLeads: [Lead] {
        if searchText.isEmpty {
            return sortedLeads
        } else {
            return sortedLeads.filter { lead in
                lead.name.localizedCaseInsensitiveContains(searchText) ||
                lead.company?.localizedCaseInsensitiveContains(searchText) ?? false ||
                lead.email?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredLeads) { lead in
                    Button {
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        selectedLead = lead
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            // Lead avatar (color-coded by status for consistency)
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: avatarGradientForLead(lead),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 42)
                                
                                Text(getInitialsForLead(lead.name))
                                    .font(.system(size: getInitialsForLead(lead.name).count == 1 ? 17 : 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lead.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                if let company = lead.company, !company.isEmpty {
                                    Text(company)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Show if already has follow-up
                                if let followUpDate = lead.followUpDate {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 10))
                                        Text("Follow-up: \(followUpDate.toDisplayString())")
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            // Status badge
                            Text(lead.status)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor(lead.status).opacity(0.15))
                                .foregroundColor(statusColor(lead.status))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search leads by name, company, or email")
            .navigationTitle("Schedule Follow-Up For")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
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
    
    // Helper functions for avatar (matches LeadRowView logic)
    private func avatarGradientForLead(_ lead: Lead) -> [Color] {
        switch lead.status {
        case "Cold": return [Color.blue.opacity(0.85), Color.blue]
        case "Warm": return [Color.orange.opacity(0.85), Color.orange]
        case "Hot": return [Color.red.opacity(0.85), Color.red]
        case "Closed": return [Color.green.opacity(0.85), Color.green]
        default: return [Color.gray.opacity(0.8), Color.gray]
        }
    }
    
    private func getInitialsForLead(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let components = trimmed.split(separator: " ")
        
        if components.count >= 2 {
            let first = components.first?.prefix(1).uppercased() ?? ""
            let last = components.last?.prefix(1).uppercased() ?? ""
            return "\(first)\(last)"
        } else if trimmed.count >= 2 {
            return trimmed.prefix(2).uppercased()
        } else {
            return trimmed.prefix(1).uppercased()
        }
    }
}

struct FollowUpRowView: View {
    let lead: Lead
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var isProcessing = false
    @State private var showEditTask = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with avatar, name and date
            HStack(alignment: .top, spacing: 12) {
                // Avatar circle with initials (color-coded by status)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: avatarGradient(for: lead.name),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(getInitials(from: lead.name))
                        .font(.system(size: getInitials(from: lead.name).count == 1 ? 18 : 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lead.name)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                    
                    if let company = lead.company, !company.isEmpty {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer(minLength: 8)
                
                // Urgency indicator with relative dates
                if let followUpDate = lead.followUpDate {
                    VStack(alignment: .trailing, spacing: 3) {
                        if followUpDate.isPast {
                            Text("OVERDUE")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.errorRed)
                                        .shadow(color: Color.errorRed.opacity(0.3), radius: 3, x: 0, y: 2)
                                )
                        } else if followUpDate.isToday {
                            Text("TODAY")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.warningOrange)
                                        .shadow(color: Color.warningOrange.opacity(0.3), radius: 3, x: 0, y: 2)
                                )
                        } else {
                            // Future follow-ups - compact
                            Text(followUpDate.toRelativeString())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        // Full date as subtitle
                        Text(followUpDate.toDisplayString())
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let notes = lead.followUpNotes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Task:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                .padding(.top, 4)
            }
            
            // Quick actions - Responsive for all screen sizes
            VStack(spacing: 8) {
                // Primary Action Row - Prominent green button with animation
                Button {
                    isProcessing = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    Task {
                        do {
                            try await viewModel.markContacted(leadId: lead.id)
                        } catch {
                            print("Error marking contacted:", error)
                            let errorGenerator = UINotificationFeedbackGenerator()
                            errorGenerator.notificationOccurred(.error)
                        }
                        isProcessing = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        if isProcessing {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Mark Contacted")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.successGreen, Color.successGreen.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.successGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isProcessing)
                .scaleEffect(isProcessing ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isProcessing)
                
                // Secondary Actions Row
                HStack(spacing: 8) {
                    // Edit Task Button
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        showEditTask = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 13))
                            Text("Edit Task")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primaryBlue.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)
                    
                    // Snooze Menu with clearer labels
                    Menu {
                        Button {
                            Task {
                                try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 1)
                            }
                        } label: {
                            Label("Add 1 day", systemImage: "plus.circle")
                        }
                        
                        Button {
                            Task {
                                try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 3)
                            }
                        } label: {
                            Label("Add 3 days", systemImage: "plus.circle")
                        }
                        
                        Button {
                            Task {
                                try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 7)
                            }
                        } label: {
                            Label("Add 1 week", systemImage: "plus.circle")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 13))
                            Text("Snooze")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .opacity(isProcessing ? 0.6 : 1.0)
        .sheet(isPresented: $showEditTask) {
            EditTaskView(lead: lead)
                .environmentObject(viewModel)
        }
    }
    
    // Generate purposeful color gradient based on lead STATUS
    // Matches CRM priority: Cold (blue), Warm (orange), Hot (red), Closed (green)
    // Accessible colors with good contrast for color-blind users
    private func avatarGradient(for name: String) -> [Color] {
        switch lead.status {
        case "Cold":
            // Blue - calm, early stage
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
    // Handles: duplicates, long names, single names, edge cases
    private func getInitials(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let components = trimmed.split(separator: " ")
        
        if components.count >= 2 {
            // First + Last initial (e.g., "John Smith" → "JS")
            // This helps differentiate duplicates: "Zach Adams" vs "Zach Brown"
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

// MARK: - Edit Task View
struct EditTaskView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var taskNotes: String
    @State private var isSaving = false
    
    init(lead: Lead) {
        self.lead = lead
        _taskNotes = State(initialValue: lead.followUpNotes ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit Task for")
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
                    
                    // Current follow-up date
                    if let followUpDate = lead.followUpDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.primaryBlue)
                            Text("Due: \(followUpDate.toRelativeString())")
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryBlue.opacity(0.08))
                )
                
                // Task Notes Editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Details")
                        .font(.headline)
                    
                    Text("What do you need to do?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $taskNotes)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if taskNotes.isEmpty {
                                    Text("e.g., 'Call about warehouse options' or 'Send updated proposal'")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 16)
                                        .padding(.top, 20)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                }
                
                Spacer()
                
                // Save Button
                Button {
                    Task {
                        await saveTask()
                    }
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Saving...")
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Update Task")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .disabled(isSaving)
            }
            .padding()
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
    
    private func saveTask() async {
        isSaving = true
        
        var updates = LeadUpdatePayload()
        updates.followUpNotes = taskNotes.isEmpty ? nil : taskNotes
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dismiss()
            }
        } catch {
            print("❌ Failed to update task:", error)
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSaving = false
    }
}

