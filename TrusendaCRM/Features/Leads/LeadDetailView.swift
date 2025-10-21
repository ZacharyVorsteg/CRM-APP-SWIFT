import SwiftUI

struct LeadDetailView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var showEditSheet = false
    @State private var showFollowUpSheet = false
    
    // Get live lead data from viewModel
    private var currentLead: Lead {
        viewModel.leads.first(where: { $0.id == lead.id }) ?? lead
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header Card - Premium Salesforce-style
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(currentLead.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Status badge (larger for detail view)
                            Text(currentLead.status)
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(statusColor(currentLead.status).opacity(0.15))
                                )
                                .foregroundColor(statusColor(currentLead.status))
                        }
                        
                        if let company = currentLead.company {
                            HStack(spacing: 6) {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text(company)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Contact Info Card - Premium with tappable links or placeholder
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CONTACT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        if lead.email == nil && lead.phone == nil {
                            // Empty state
                            HStack(spacing: 10) {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                Text("No contact information")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            
                            if let email = lead.email, !email.isEmpty {
                                Link(destination: URL(string: "mailto:\(email)")!) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.primaryBlue.opacity(0.1))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "envelope.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.primaryBlue)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Email")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text(email)
                                                .font(.system(size: 15))
                                                .foregroundColor(.primaryBlue)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.forward")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if let phone = lead.phone, !phone.isEmpty {
                                Link(destination: URL(string: "tel:\(phone.filter { $0.isNumber })")!) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.successGreen.opacity(0.1))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "phone.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.successGreen)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Phone")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text(phone)
                                                .font(.system(size: 15))
                                                .foregroundColor(.successGreen)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.forward")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // Property Details (matches web app table)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("PROPERTY DETAILS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        VStack(spacing: 10) {
                            if let propertyType = lead.propertyType, !propertyType.isEmpty {
                                DetailRow(label: "Type", value: propertyType, icon: "building.2")
                                Divider()
                            } else {
                                DetailRow(label: "Type", value: "Not specified", icon: "building.2")
                                    .opacity(0.6)
                                Divider()
                            }
                            
                            if let transactionType = lead.transactionType {
                                DetailRow(label: "Transaction", value: transactionType, icon: "doc.text")
                                Divider()
                            }
                            
                            // Size (Square Footage) - NEW!
                            if let sizeMin = lead.sizeMin, let sizeMax = lead.sizeMax, !sizeMin.isEmpty, !sizeMax.isEmpty {
                                let sizeDisplay = "\(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF"
                                DetailRow(label: "Size", value: sizeDisplay, icon: "ruler")
                                Divider()
                            } else if let sizeMin = lead.sizeMin, !sizeMin.isEmpty {
                                let sizeDisplay = "\(formatNumber(sizeMin))+ SF"
                                DetailRow(label: "Size", value: sizeDisplay, icon: "ruler")
                                Divider()
                            }
                            
                            if let budget = lead.budget, !budget.isEmpty {
                                // Only add $ if budget doesn't already start with it
                                let displayBudget = budget.hasPrefix("$") ? budget : "$\(budget)"
                                DetailRow(label: "Budget", value: displayBudget, icon: "dollarsign.circle")
                                Divider()
                            }
                            
                            // Timeline with context (days until move)
                            if let timeline = lead.timelineStatus {
                                let timelineDisplay = formatTimelineWithContext(timeline: timeline, days: lead.daysUntilMove, moveTiming: lead.moveTiming)
                                DetailRow(label: "Timeline", value: timelineDisplay, icon: "clock")
                                Divider()
                            } else if let moveTiming = lead.moveTiming, !moveTiming.isEmpty, moveTiming != "Flexible" {
                                // Show move timing even if timeline status not calculated
                                DetailRow(label: "Move Timing", value: moveTiming, icon: "calendar")
                                Divider()
                            }
                            
                            if let area = lead.preferredArea, !area.isEmpty {
                                DetailRow(label: "Area", value: area, icon: "mappin.circle")
                                Divider()
                            }
                            
                            if let industry = lead.industry, !industry.isEmpty {
                                DetailRow(label: "Industry", value: industry, icon: "briefcase")
                                Divider()
                            }
                            
                            if let leaseTerm = lead.leaseTerm, !leaseTerm.isEmpty {
                                DetailRow(label: "Lease Term", value: leaseTerm, icon: "calendar.badge.clock")
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // Follow-up Section (matches web app)
                    if lead.followUpOn != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("FOLLOW-UP")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .tracking(0.8)
                                
                                Spacer()
                                
                                if lead.isFollowUpDue {
                                    Text("DUE")
                                        .font(.caption.bold())
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.orange.opacity(0.15))
                                        .cornerRadius(6)
                                }
                            }
                            
                            if let followUpDate = lead.followUpDate {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(lead.isFollowUpDue ? .orange : .blue)
                                    Text(followUpDate.toDisplayString())
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(lead.isFollowUpDue ? .orange : .primary)
                                }
                            }
                            
                            if let notes = lead.followUpNotes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notes:")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                    Text(notes)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                .padding(.top, 4)
                            }
                            
                            Divider()
                            
                            // Quick actions
                            HStack(spacing: 12) {
                                Button {
                                    showFollowUpSheet = true
                                } label: {
                                    Label("Reschedule", systemImage: "calendar.badge.plus")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .buttonStyle(.bordered)
                                .tint(.primaryBlue)
                                
                                Button {
                                    Task {
                                        do {
                                            try await viewModel.markContacted(leadId: lead.id)
                                            dismiss()
                                        } catch {
                                            print("Failed to mark contacted:", error)
                                        }
                                    }
                                } label: {
                                    Label("Mark Contacted", systemImage: "checkmark.circle.fill")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .buttonStyle(.bordered)
                                .tint(.successGreen)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(lead.isFollowUpDue ? Color.orange.opacity(0.08) : Color.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lead.isFollowUpDue ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Notes
                    if let notes = lead.notes, !notes.isEmpty {
                        GroupBox("Notes") {
                            Text(notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Metadata - Date Added to CRM (Salesforce-style)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ADDED TO CRM")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 16))
                            
                            if let createdDate = lead.createdDate {
                                Text(createdDate.toDisplayString())
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            } else {
                                // Fallback: Show raw string
                                Text(lead.createdAt)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
            .tint(.primaryBlue)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditLeadView(lead: lead)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showFollowUpSheet) {
                FollowUpScheduleView(lead: lead)
                    .environmentObject(viewModel)
            }
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Cold": return .blue
        case "Warm": return .orange
        case "Hot": return .red
        case "Closed": return .green
        default: return .gray
        }
    }
    
    // Format number with commas (e.g., "2500" → "2,500")
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
    
    // Format timeline with clear context - show WHEN they need the space
    // DYNAMIC: Updates based on current date vs move date
    private func formatTimelineWithContext(timeline: String, days: Int?, moveTiming: String?) -> String {
        // For OVERDUE leads: Show clear past date
        if let days = days, days < 0 {
            // Truly overdue - move date has passed
            let daysAgo = abs(days)
            if let moveTiming = moveTiming, !moveTiming.isEmpty, moveTiming != "Flexible" {
                return "Target was \(moveTiming) (\(daysAgo)d ago)"
            } else {
                return "Target date passed (\(daysAgo)d ago)"
            }
        }
        
        // For CURRENT/FUTURE timelines: Show clear, actionable information
        if let moveTiming = moveTiming, !moveTiming.isEmpty, moveTiming != "Flexible" {
            // Parse move date to check if it's truly current month
            let isCurrentMonth = checkIfCurrentMonth(moveTiming)
            
            if let days = days {
                switch timeline {
                case "Immediate":
                    // DYNAMIC CHECK: Only show "THIS MONTH!" if move date is actually current month
                    if days <= 7 && isCurrentMonth {
                        return "Move: \(moveTiming) (THIS MONTH!)"
                    } else if days == 0 {
                        return "Move: \(moveTiming) (today!)"
                    } else {
                        return "Move: \(moveTiming) (\(days)d)"
                    }
                case "Heating Up":
                    return "Move: \(moveTiming) (\(days)d)"
                case "Upcoming":
                    return "Move: \(moveTiming) (\(days)d)"
                case "Overdue":
                    // Backend says overdue but days >= 0, show as current
                    return "Move: \(moveTiming) (soon)"
                default:
                    return "Move: \(moveTiming)"
                }
            } else {
                // No days calculation but has move timing
                return "Target: \(moveTiming)"
            }
        }
        
        // No move timing - show based on days count
        if let days = days {
            switch timeline {
            case "Immediate":
                if days == 0 {
                    return "Needs space today"
                } else if days <= 7 {
                    return "Needs space in \(days) days (urgent!)"
                } else {
                    return "Needs space in \(days) days"
                }
            case "Heating Up":
                return "Needs space in \(days) days"
            case "Upcoming":
                return "Needs space in \(days) days"
            default:
                return timeline
            }
        }
        
        // Fallback: Show status with explanation
        switch timeline {
        case "Immediate":
            return "Needs space soon (0-30 days)"
        case "Heating Up":
            return "Needs space in 30-90 days"
        case "Upcoming":
            return "Needs space in 90+ days"
        default:
            return timeline
        }
    }
    
    // Check if move date string is in current month/year
    private func checkIfCurrentMonth(_ moveTiming: String) -> Bool {
        // Parse "MM/YY - MM/YY" format and check if start date is current month
        let components = moveTiming.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let startDate = components.first else { return false }
        
        let parts = startDate.split(separator: "/")
        guard parts.count == 2,
              let month = Int(parts[0]),
              let year = Int(parts[1]) else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now) % 100 // Get last 2 digits
        
        return month == currentMonth && year == currentYear
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(.primaryBlue)
                        .frame(width: 20)
                }
                Text(label)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct EditLeadView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    
    // ALL editable fields (matching AddLeadView)
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var company: String
    @State private var budget: String
    @State private var sizeMin: String
    @State private var sizeMax: String
    @State private var propertyType: String
    @State private var transactionType: String
    @State private var status: String
    @State private var preferredArea: String
    @State private var industry: String
    @State private var leaseTerm: String
    @State private var moveTiming: String // NEW: Move timeline
    @State private var moveStartDate: String // NEW: Start date
    @State private var moveEndDate: String // NEW: End date
    @State private var notes: String
    @State private var sizeRange: String = "" // Size range dropdown
    
    // Options (matching cloud app exactly)
    let propertyTypes = ["Warehouse", "Manufacturing", "Land", "Office", "Retail", "Mixed Use", "Industrial", "Flex", "Other"]
    let transactionTypes = ["Lease", "Purchase", "Lease-Purchase", "Renewal/Expansion", "Other"]
    let statuses = ["Cold", "Warm", "Hot", "Closed"]
    let budgetOptions = ["Under $2,000/mo", "$2,000 - $5,000/mo", "$5,000 - $10,000/mo", "$10,000 - $20,000/mo", "$20,000 - $50,000/mo", "$50,000+/mo", "Custom"]
    let industryOptions = ["Automotive & Transportation", "Construction & Contracting", "Distribution & Logistics", "E-commerce & Fulfillment", "Food & Beverage Production", "Healthcare & Medical", "Manufacturing", "Professional Services", "Retail Operations", "Technology & Software", "Warehousing & Storage", "Wholesale Trade", "Other"]
    let leaseTermOptions = ["Month-to-Month", "3-6 Months", "1 Year", "2 Years", "3 Years", "5 Years", "7-10 Years", "10+ Years", "Flexible/TBD"]
    
    // Size range options (matching AddLeadView)
    let sizeRangeOptions = [
        ("1000-2500", "1,000 - 2,500 SF"),
        ("2500-5000", "2,500 - 5,000 SF"),
        ("5000-10000", "5,000 - 10,000 SF"),
        ("10000-25000", "10,000 - 25,000 SF"),
        ("25000-50000", "25,000 - 50,000 SF"),
        ("50000+", "50,000+ SF")
    ]
    
    // Move Timeline options (same as AddLeadView)
    var moveTimelineOptions: [(value: String, label: String)] {
        [
            ("Immediate", "Immediate (0-30 Days)"),
            ("1-3 Months", "1-3 Months Out"),
            ("3-6 Months", "3-6 Months Out"),
            ("6-12 Months", "6-12 Months Out"),
            ("12+ Months", "12+ Months Out"),
            ("Flexible", "Flexible / TBD")
        ]
    }
    
    init(lead: Lead) {
        self.lead = lead
        _name = State(initialValue: lead.name)
        _email = State(initialValue: lead.email ?? "")
        _phone = State(initialValue: lead.phone ?? "")
        _company = State(initialValue: lead.company ?? "")
        _budget = State(initialValue: lead.budget ?? "")
        _sizeMin = State(initialValue: lead.sizeMin ?? "")
        _sizeMax = State(initialValue: lead.sizeMax ?? "")
        _propertyType = State(initialValue: lead.propertyType ?? "")
        _transactionType = State(initialValue: lead.transactionType ?? "Lease")
        _status = State(initialValue: lead.status)
        _preferredArea = State(initialValue: lead.preferredArea ?? "")
        _industry = State(initialValue: lead.industry ?? "")
        _leaseTerm = State(initialValue: lead.leaseTerm ?? "")
        _moveStartDate = State(initialValue: lead.moveStartDate ?? "")
        _moveEndDate = State(initialValue: lead.moveEndDate ?? "")
        _notes = State(initialValue: lead.notes ?? "")
        
        // Initialize sizeRange from existing sizeMin/sizeMax
        let sizeMinVal = lead.sizeMin ?? ""
        let sizeMaxVal = lead.sizeMax ?? ""
        if !sizeMinVal.isEmpty && !sizeMaxVal.isEmpty {
            _sizeRange = State(initialValue: "\(sizeMinVal)-\(sizeMaxVal)")
        } else if !sizeMinVal.isEmpty {
            _sizeRange = State(initialValue: "\(sizeMinVal)+")
        } else {
            _sizeRange = State(initialValue: "")
        }
        
        // Initialize moveTiming - display the actual date range stored
        // (not the dropdown category since date ranges change daily)
        _moveTiming = State(initialValue: lead.moveTiming ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("CONTACT INFORMATION") {
                    TextField("Name *", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Company", text: $company)
                }
                
                Section("PROPERTY REQUIREMENTS") {
                    Picker("Property Type", selection: $propertyType) {
                        Text("Select Type").tag("")
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    Picker("Budget", selection: $budget) {
                        Text("Select Budget").tag("")
                        ForEach(budgetOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    // Size Range - Dropdown matching Add Lead form
                    Picker("Size Range (SF)", selection: $sizeRange) {
                        Text("Select size...").tag("")
                        ForEach(sizeRangeOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .tint(.primaryBlue)
                    .onChange(of: sizeRange) { newValue in
                        // Parse size range for backend storage (matches AddLeadView)
                        if newValue.contains("-") {
                            let parts = newValue.split(separator: "-")
                            sizeMin = String(parts[0])
                            sizeMax = String(parts[1])
                        } else if newValue.contains("+") {
                            sizeMin = newValue.replacingOccurrences(of: "+", with: "")
                            sizeMax = ""
                        }
                    }
                    
                    // Move Timeline with current value displayed
                    VStack(alignment: .leading, spacing: 0) {
                        Picker("Move Timeline", selection: $moveTiming) {
                            // Show current value first if it exists
                            if let currentTiming = lead.moveTiming, !currentTiming.isEmpty {
                                Text(currentTiming).tag(currentTiming)
                            }
                            Text("Select new timeline...").tag("")
                            ForEach(moveTimelineOptions, id: \.value) { option in
                                Text(option.label).tag(option.value)
                            }
                        }
                    }
                }
                
                Section("BUSINESS DETAILS") {
                    TextField("Preferred Area", text: $preferredArea)
                    
                    Picker("Industry", selection: $industry) {
                        Text("Select Industry").tag("")
                        ForEach(industryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    
                    Picker("Lease Term", selection: $leaseTerm) {
                        Text("Select Lease Term").tag("")
                        ForEach(leaseTermOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section("STATUS & NOTES") {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Lead")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { 
                        dismiss() 
                    }
                    .foregroundColor(.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveLead()
                        }
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveLead() async {
        guard !name.isEmpty else { return }
        
        var updates = LeadUpdatePayload()
        updates.name = name
        updates.email = email.isEmpty ? nil : email
        updates.phone = phone.isEmpty ? nil : phone
        updates.company = company.isEmpty ? nil : company
        updates.budget = budget.isEmpty ? nil : budget
        updates.sizeMin = sizeMin.isEmpty ? nil : sizeMin
        updates.sizeMax = sizeMax.isEmpty ? nil : sizeMax
        updates.propertyType = propertyType.isEmpty ? nil : propertyType
        updates.transactionType = transactionType.isEmpty ? nil : transactionType
        updates.status = status
        updates.preferredArea = preferredArea.isEmpty ? nil : preferredArea
        updates.industry = industry.isEmpty ? nil : industry
        updates.leaseTerm = leaseTerm.isEmpty ? nil : leaseTerm
        updates.moveTiming = moveTiming.isEmpty ? nil : moveTiming
        updates.moveStartDate = moveStartDate.isEmpty ? nil : moveStartDate
        updates.moveEndDate = moveEndDate.isEmpty ? nil : moveEndDate
        // Note: Timeline status will be recalculated by backend based on move dates
        updates.notes = notes.isEmpty ? nil : notes
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.easeOut(duration: 0.3)) {
                dismiss()
            }
        } catch {
            print("Failed to update lead:", error)
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

struct FollowUpScheduleView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    
    @State private var followUpDate = Date.addingDays(1) // Default to tomorrow (matches cloud)
    @State private var followUpNotes = ""
    @State private var isSaving = false
    @State private var showCustomDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Lead Info Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schedule Follow-Up")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Text(lead.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if let company = lead.company {
                            Text(company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Show previous follow-up date if exists
                        if let previousDate = lead.followUpDate {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption)
                                Text("Previous: \(previousDate.toDisplayString())")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryBlue.opacity(0.08))
                    )
                    
                    // Task Notes (matching cloud app)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What do you need to do?")
                            .font(.headline)
                        
                        Text("Example: \"Send proposal\", \"Call about warehouse\", \"Follow up on budget\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $followUpNotes)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if followUpNotes.isEmpty {
                                        Text("e.g., 'Call to discuss warehouse options near Miami airport' or 'Send updated budget proposal for 5,000 SF flex space'")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .font(.body)
                                            .padding(.leading, 12)
                                            .padding(.top, 16)
                                            .allowsHitTesting(false)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                    }
                    
                    // Quick Action Buttons (matching cloud app)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Schedule")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            // Tomorrow (1 day)
                            QuickFollowUpButton(
                                title: "Tomorrow",
                                date: Date.addingDays(1),
                                color: .blue,
                                isSelected: Calendar.current.isDate(followUpDate, inSameDayAs: Date.addingDays(1))
                            ) {
                                followUpDate = Date.addingDays(1)
                                showCustomDatePicker = false
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                            
                            // In 3 Days
                            QuickFollowUpButton(
                                title: "In 3 Days",
                                date: Date.addingDays(3),
                                color: .orange,
                                isSelected: Calendar.current.isDate(followUpDate, inSameDayAs: Date.addingDays(3))
                            ) {
                                followUpDate = Date.addingDays(3)
                                showCustomDatePicker = false
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                            
                            // In 1 Week (7 days)
                            QuickFollowUpButton(
                                title: "In 1 Week",
                                date: Date.addingDays(7),
                                color: .green,
                                isSelected: Calendar.current.isDate(followUpDate, inSameDayAs: Date.addingDays(7))
                            ) {
                                followUpDate = Date.addingDays(7)
                                showCustomDatePicker = false
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                    
                    // Custom Date Picker (matching cloud app)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.primaryBlue)
                            Text("Or Pick a Custom Date")
                                .font(.headline)
                        }
                        
                        DatePicker(
                            "Follow-up Date",
                            selection: $followUpDate,
                            in: Date.minimumFollowUpDate()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .frame(height: 350) // Fix UICalendarView height warning
                        .onChange(of: followUpDate) { _ in
                            showCustomDatePicker = true
                        }
                    }
                    
                    // Save Button (matching cloud app style)
                    Button {
                        Task {
                            await saveFollowUp()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Saving...")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Schedule Follow-Up")
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
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Set Follow-Up")
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
        .onAppear {
            // Pre-fill notes if editing existing follow-up
            if let existingNotes = lead.followUpNotes {
                followUpNotes = existingNotes
            }
            // Pre-fill date if editing existing follow-up
            if let existingDate = lead.followUpDate, existingDate >= Date() {
                followUpDate = existingDate
            }
        }
    }
    
    private func saveFollowUp() async {
        // Validate date is not in the past (matches cloud validation)
        let calendar = Calendar.current
        let selectedDay = calendar.startOfDay(for: followUpDate)
        let today = calendar.startOfDay(for: Date())
        
        if selectedDay < today {
            print("⚠️ Follow-up date cannot be in the past")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        isSaving = true
        
        var updates = LeadUpdatePayload()
        updates.followUpOn = followUpDate.toISO8601String()
        updates.followUpNotes = followUpNotes.isEmpty ? nil : followUpNotes
        updates.needsAttention = false // Reset needs_attention when setting new follow-up (matches cloud)
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            
            print("✅ Follow-up scheduled for \(followUpDate.toDisplayString())")
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dismiss()
            }
        } catch {
            print("❌ Failed to schedule follow-up:", error)
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSaving = false
    }
}

// MARK: - Quick Follow-Up Button Component
struct QuickFollowUpButton: View {
    let title: String
    let date: Date
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.bold())
                    Text(date.toDisplayString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? color.opacity(0.15) : Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

