import SwiftUI

struct AddLeadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var viewModel: LeadViewModel
    
    // Initialize with prefilled contact data
    let prefilledName: String?
    let prefilledEmail: String?
    let prefilledPhone: String?
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var company = ""
    @State private var budget = ""
    @State private var sizeRange = "" // Combined size range like web app
    @State private var sizeMin = ""
    @State private var sizeMax = ""
    @State private var propertyType = ""
    @State private var transactionType = "Lease"
    @State private var status = "Cold"
    @State private var preferredArea = ""
    @State private var industry = ""
    @State private var leaseTerm = ""
    @State private var moveTiming = "" // NEW: Move timeline selection
    @State private var moveStartDate = "" // NEW: Calculated start date
    @State private var moveEndDate = "" // NEW: Calculated end date
    @State private var notes = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    @State private var showDraftAlert = false
    @State private var pendingDraft: LeadDraft?
    
    // EXACT values from cloud site for backend integrity
    let budgetOptions = [
        "Under $2,000/mo",
        "$2,000 - $5,000/mo",
        "$5,000 - $10,000/mo",
        "$10,000 - $20,000/mo",
        "$20,000 - $50,000/mo",
        "$50,000+/mo",
        "Custom (enter in notes)"
    ]
    
    let sizeRangeOptions = [
        ("1000-2500", "1,000 - 2,500 SF"),
        ("2500-5000", "2,500 - 5,000 SF"),
        ("5000-10000", "5,000 - 10,000 SF"),
        ("10000-25000", "10,000 - 25,000 SF"),
        ("25000-50000", "25,000 - 50,000 SF"),
        ("50000+", "50,000+ SF")
    ]
    
    // COMPLETE industry list from cloud site
    let industryOptions = [
        "Automotive & Transportation",
        "Construction & Contracting",
        "Creative & Media Production",
        "Distribution & Logistics",
        "E-commerce & Fulfillment",
        "Education & Training",
        "Financial Services",
        "Food & Beverage Production",
        "Healthcare & Medical",
        "Light Industrial",
        "Manufacturing",
        "Professional Services",
        "Research & Development",
        "Retail Operations",
        "Technology & Software",
        "Warehousing & Storage",
        "Wholesale Trade",
        "Other (please specify)"
    ]
    
    // EXACT lease term options from cloud site
    let leaseTermOptions = [
        "Month-to-Month",
        "3-6 Months",
        "1 Year",
        "2 Years",
        "3 Years",
        "5 Years",
        "7-10 Years",
        "10+ Years",
        "Flexible/TBD"
    ]
    
    let propertyTypes = ["Warehouse", "Manufacturing", "Land", "Office", "Retail", "Mixed Use", "Industrial", "Flex", "Other"]
    let transactionTypes = ["Lease", "Purchase", "Lease-Purchase", "Renewal/Expansion", "Other"]
    let statuses = ["Cold", "Warm", "Hot", "Closed"]
    
    // Move Timeline options - INTUITIVE: All dates are FORWARD-LOOKING from today
    var moveTimelineOptions: [(value: String, label: String, startDate: String, endDate: String)] {
        let now = Date()
        let calendar = Calendar.current
        
        // Immediate = 0-30 days (matches cloud definition exactly)
        let immediateStart = now
        let immediateEnd = calendar.date(byAdding: .day, value: 30, to: now)!
        let immediateRange = formatDateRangeForTimeline(immediateStart, immediateEnd)
        
        // 1-3 months from TODAY
        let oneMonthOut = calendar.date(byAdding: .month, value: 1, to: now)!
        let threeMonthsOut = calendar.date(byAdding: .month, value: 3, to: now)!
        let range13 = formatDateRangeForTimeline(oneMonthOut, threeMonthsOut)
        
        // 3-6 months from TODAY
        let sixMonthsOut = calendar.date(byAdding: .month, value: 6, to: now)!
        let range36 = formatDateRangeForTimeline(threeMonthsOut, sixMonthsOut)
        
        // 6-12 months from TODAY
        let twelveMonthsOut = calendar.date(byAdding: .month, value: 12, to: now)!
        let range612 = formatDateRangeForTimeline(sixMonthsOut, twelveMonthsOut)
        
        // 12+ months from TODAY
        let eighteenMonthsOut = calendar.date(byAdding: .month, value: 18, to: now)!
        let range12plus = formatDateRangeForTimeline(twelveMonthsOut, eighteenMonthsOut)
        
        let splitsImmediate = immediateRange.split(separator: " - ")
        let splits13 = range13.split(separator: " - ")
        let splits36 = range36.split(separator: " - ")
        let splits612 = range612.split(separator: " - ")
        let splits12plus = range12plus.split(separator: " - ")
        
        return [
            (immediateRange, "Immediate (0-30 Days)", String(splitsImmediate.first ?? ""), String(splitsImmediate.last ?? "")),
            (range13, "1-3 Months Out", String(splits13.first ?? ""), String(splits13.last ?? "")),
            (range36, "3-6 Months Out", String(splits36.first ?? ""), String(splits36.last ?? "")),
            (range612, "6-12 Months Out", String(splits612.first ?? ""), String(splits612.last ?? "")),
            (range12plus, "12+ Months Out", String(splits12plus.first ?? ""), String(splits12plus.last ?? "")),
            ("Flexible", "Flexible / TBD", "", "")
        ]
    }
    
    // Format date range as MM/YY - MM/YY (matches cloud)
    private func formatDateRangeForTimeline(_ startDate: Date, _ endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }
    
    // Initializer to handle prefilled data
    init(prefilledName: String? = nil, prefilledEmail: String? = nil, prefilledPhone: String? = nil) {
        self.prefilledName = prefilledName
        self.prefilledEmail = prefilledEmail
        self.prefilledPhone = prefilledPhone
        
        // Initialize state with prefilled values
        _name = State(initialValue: prefilledName ?? "")
        _email = State(initialValue: prefilledEmail ?? "")
        _phone = State(initialValue: prefilledPhone ?? "")
        
        print("🔧 AddLeadView initialized with: name=\(prefilledName ?? "nil"), email=\(prefilledEmail ?? "nil"), phone=\(prefilledPhone ?? "nil")")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Name - Required with prominent red asterisk & validation
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            TextField("Name", text: $name)
                                .font(.body)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            name.isEmpty ? Color.errorRed.opacity(0.3) : Color.primaryBlue.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                    }
                    
                    // Email with icon & validation
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .font(.body)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        !email.isEmpty && !Validation.isValidEmail(email) ? Color.errorRed.opacity(0.5) : Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )
                    
                    // Phone with unified blue icon
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        TextField("Phone", text: $phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .font(.body)
                            .onChange(of: phone) { newValue in
                                phone = PhoneFormatter.format(newValue)
                            }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )
                    
                    // Company with icon
                    HStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        TextField("Company", text: $company)
                            .font(.body)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )
                } header: {
                    Label("CONTACT INFORMATION", systemImage: "person.text.rectangle")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                Section {
                    // Property Type - With valid SF Symbol
                    Picker("Property Type", selection: $propertyType) {
                        Text("Select property type").tag("").foregroundColor(.secondary)
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Transaction Type - With valid SF Symbol
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Budget - Dropdown matching cloud site EXACTLY
                    Picker("Budget", selection: $budget) {
                        Text("Select budget...").tag("")
                        ForEach(budgetOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Size Range - Dropdown matching cloud site EXACTLY
                    Picker("Size Range (SF)", selection: $sizeRange) {
                        Text("Select size...").tag("")
                        ForEach(sizeRangeOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .tint(.primaryBlue)
                    .onChange(of: sizeRange) { newValue in
                        // Parse size range for backend storage
                        if newValue.contains("-") {
                            let parts = newValue.split(separator: "-")
                            sizeMin = String(parts[0])
                            sizeMax = String(parts[1])
                        } else if newValue.contains("+") {
                            sizeMin = newValue.replacingOccurrences(of: "+", with: "")
                            sizeMax = ""
                        }
                    }
                    
                    // Move Timeline - NEW! Matches cloud exactly
                    Picker("Move Timeline", selection: $moveTiming) {
                        Text("Select timeline...").tag("")
                        ForEach(moveTimelineOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    .tint(.primaryBlue)
                    .onChange(of: moveTiming) { newValue in
                        // Auto-calculate dates when timeline selected (matches cloud logic)
                        if let selected = moveTimelineOptions.first(where: { $0.value == newValue }) {
                            moveStartDate = selected.startDate
                            moveEndDate = selected.endDate
                            print("📅 Move timeline selected: \(newValue)")
                            print("   Start: \(moveStartDate), End: \(moveEndDate)")
                        }
                    }
                    
                    // Preferred Area
                    TextField("Preferred Area / Radius (e.g., Miami, FL)", text: $preferredArea)
                        .font(.body)
                    
                    // Lease Term - Dropdown matching cloud site
                    Picker("Desired Lease Term", selection: $leaseTerm) {
                        Text("Select term...").tag("")
                        ForEach(leaseTermOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Industry - Dropdown matching cloud site EXACTLY
                    Picker("Industry / Business Type", selection: $industry) {
                        Text("Select industry...").tag("")
                        ForEach(industryOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Status - Prominent picker with color preview
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(.primaryBlue)
                            .frame(width: 24)
                        Picker("Status", selection: $status) {
                            ForEach(statuses, id: \.self) { status in
                                HStack {
                                    Text(status)
                                    Circle()
                                        .fill(statusColor(for: status))
                                        .frame(width: 8, height: 8)
                                }
                                .tag(status)
                            }
                        }
                        .tint(.primaryBlue)
                    }
                } header: {
                    Label("PROPERTY DETAILS", systemImage: "building.2")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                } footer: {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("All fields are optional except Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Additional notes about this lead...")
                                .foregroundColor(.secondary.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                            )
                            .padding(4)
                    }
                } header: {
                    Label("NOTES", systemImage: "note.text")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
            }
            .navigationTitle("Add Lead")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.primaryBlue)
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight,
                        colorScheme == .dark ? Color.backgroundDark.opacity(0.8) : Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Save draft before dismissing
                        saveDraftIfNeeded()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        Task {
                            await saveLead()
                        }
                    } label: {
                        if isSubmitting {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                                Text("Saving...")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.primaryBlue.opacity(0.6))
                            )
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Save")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.primaryBlue, Color.primaryBlueDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Color.primaryBlue.opacity(0.4), radius: 6, x: 0, y: 3)
                            )
                        }
                    }
                    .disabled(isSubmitting || !isValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    // Error dismissed haptic
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Debug: Verify prefilled data is present
                print("📋 AddLeadView appeared with:")
                print("   Name: \(name)")
                print("   Email: \(email)")
                print("   Phone: \(phone)")
                
                // Check for existing draft (only if no prefilled data)
                if prefilledName == nil && prefilledEmail == nil && prefilledPhone == nil {
                    loadDraftIfAvailable()
                }
                
                // Smooth fade-in animation
                withAnimation(.easeIn(duration: 0.3)) {
                    // Modal appeared
                }
            }
            .onChange(of: scenePhase) { newPhase in
                // Auto-save draft when app goes to background or inactive
                if newPhase == .background || newPhase == .inactive {
                    saveDraftIfNeeded()
                }
            }
            .alert("Resume Draft?", isPresented: $showDraftAlert, presenting: pendingDraft) { draft in
                Button("Discard", role: .destructive) {
                    DraftManager.shared.clearDraft()
                    pendingDraft = nil
                }
                Button("Resume") {
                    restoreDraft(draft)
                    pendingDraft = nil
                }
            } message: { draft in
                Text("You have an unsaved lead from \(formatDraftTime(draft.savedAt)). Would you like to resume?")
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Cold": return .statusCold
        case "Warm": return .statusWarm
        case "Hot": return .statusHot
        case "Closed": return .statusClosed
        default: return .secondary
        }
    }
    
    // Calculate timeline status from move start date (matches cloud app exactly)
    private func calculateTimelineStatus(moveStartDate: String) -> (status: String, days: Int)? {
        guard !moveStartDate.isEmpty, moveStartDate.contains("/") else { return nil }
        
        // Parse MM/YY format (e.g., "01/26")
        let components = moveStartDate.split(separator: "/")
        guard components.count == 2,
              let month = Int(components[0]),
              let year = Int(components[1]) else {
            return nil
        }
        
        // Create date from MM/YY (first day of that month)
        let fullYear = year < 100 ? 2000 + year : year
        var dateComponents = DateComponents()
        dateComponents.year = fullYear
        dateComponents.month = month
        dateComponents.day = 1
        
        guard let moveDate = Calendar.current.date(from: dateComponents) else {
            return nil
        }
        
        // Calculate days until move
        let today = Calendar.current.startOfDay(for: Date())
        let moveDateStart = Calendar.current.startOfDay(for: moveDate)
        let daysUntilMove = Calendar.current.dateComponents([.day], from: today, to: moveDateStart).day ?? 0
        
        // Determine status (matches cloud logic)
        let status: String
        if daysUntilMove < 0 {
            status = "Overdue"
        } else if daysUntilMove <= 30 {
            status = "Immediate"
        } else if daysUntilMove <= 90 {
            status = "Heating Up"
        } else {
            status = "Upcoming"
        }
        
        print("📊 Timeline calculated: \(status) (\(daysUntilMove)d)")
        return (status, daysUntilMove)
    }
    
    private func saveLead() async {
        isSubmitting = true
        
        // Calculate timeline status and days (matches cloud app logic)
        let timelineCalc = calculateTimelineStatus(moveStartDate: moveStartDate)
        
        let payload = LeadCreatePayload(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            company: company.isEmpty ? nil : company,
            budget: budget.isEmpty ? nil : budget,
            sizeMin: sizeMin.isEmpty ? nil : sizeMin,
            sizeMax: sizeMax.isEmpty ? nil : sizeMax,
            propertyType: propertyType.isEmpty ? nil : propertyType,
            transactionType: transactionType,
            moveTiming: moveTiming.isEmpty ? nil : moveTiming,
            moveStartDate: moveStartDate.isEmpty ? nil : moveStartDate,
            moveEndDate: moveEndDate.isEmpty ? nil : moveEndDate,
            timelineStatus: timelineCalc?.status,
            daysUntilMove: timelineCalc?.days,
            status: status,
            preferredArea: preferredArea.isEmpty ? nil : preferredArea,
            industry: industry.isEmpty ? nil : industry,
            leaseTerm: leaseTerm.isEmpty ? nil : leaseTerm,
            notes: notes.isEmpty ? nil : notes,
            followUpOn: nil,
            followUpNotes: nil
        )
        
        do {
            try await viewModel.createLead(payload)
            
            // Clear draft on successful save
            DraftManager.shared.clearDraft()
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Smooth dismiss with animation
            withAnimation(.easeOut(duration: 0.3)) {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSubmitting = false
    }
    
    // MARK: - Draft Management
    
    private func saveDraftIfNeeded() {
        // Only save if there's meaningful content
        guard !name.isEmpty || !email.isEmpty || !phone.isEmpty || 
              !company.isEmpty || !notes.isEmpty else {
            return
        }
        
        let draft = LeadDraft(
            name: name,
            email: email,
            phone: phone,
            company: company,
            budget: budget,
            sizeRange: sizeRange,
            sizeMin: sizeMin,
            sizeMax: sizeMax,
            propertyType: propertyType,
            transactionType: transactionType,
            status: status,
            preferredArea: preferredArea,
            industry: industry,
            leaseTerm: leaseTerm,
            notes: notes
        )
        
        DraftManager.shared.saveDraft(draft)
        
        // Optional: Show brief notification about draft save
        print("💾 Draft auto-saved")
    }
    
    private func loadDraftIfAvailable() {
        guard let draft = DraftManager.shared.loadDraft() else { return }
        
        // Show alert asking user if they want to resume
        pendingDraft = draft
        showDraftAlert = true
    }
    
    private func restoreDraft(_ draft: LeadDraft) {
        name = draft.name
        email = draft.email
        phone = draft.phone
        company = draft.company
        budget = draft.budget
        sizeRange = draft.sizeRange
        sizeMin = draft.sizeMin
        sizeMax = draft.sizeMax
        propertyType = draft.propertyType
        transactionType = draft.transactionType
        status = draft.status
        preferredArea = draft.preferredArea
        industry = draft.industry
        leaseTerm = draft.leaseTerm
        notes = draft.notes
        
        print("✅ Draft restored")
    }
    
    private func formatDraftTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}


