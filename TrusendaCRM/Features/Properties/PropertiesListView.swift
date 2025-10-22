import SwiftUI

struct PropertiesListView: View {
    @EnvironmentObject var viewModel: PropertyViewModel
    @EnvironmentObject var leadViewModel: LeadViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddProperty = false
    @State private var selectedProperty: Property?
    @State private var showMatches = false
    @State private var currentMatches: [LeadPropertyMatch] = []
    @State private var matchesProperty: Property?
    @State private var selectedFilter: PropertyFilter = .all
    @State private var selectionMode = false
    @State private var selectedProperties: Set<String> = []
    @State private var showDeleteAlert = false
    
    enum PropertyFilter: String, CaseIterable {
        case all = "All Properties"
        case available = "Available"
        case underContract = "Under Contract"
        case leased = "Leased"
        case warehouse = "Warehouse"
        case office = "Office"
        case industrial = "Industrial"
        case retail = "Retail"
        
        var icon: String {
            switch self {
            case .all: return "building.2"
            case .available: return "checkmark.circle"
            case .underContract: return "clock"
            case .leased: return "doc.text"
            case .warehouse: return "shippingbox.fill"
            case .office: return "building.2.fill"
            case .industrial: return "wrench.and.screwdriver.fill"
            case .retail: return "storefront.fill"
            }
        }
    }
    
    var filteredProperties: [Property] {
        switch selectedFilter {
        case .all:
            return viewModel.properties
        case .available:
            return viewModel.properties.filter { $0.status == "Available" }
        case .underContract:
            return viewModel.properties.filter { $0.status == "Under Contract" }
        case .leased:
            return viewModel.properties.filter { $0.status == "Leased" }
        case .warehouse:
            return viewModel.properties.filter { $0.propertyType?.lowercased() == "warehouse" }
        case .office:
            return viewModel.properties.filter { $0.propertyType?.lowercased() == "office" }
        case .industrial:
            return viewModel.properties.filter { $0.propertyType?.lowercased() == "industrial" }
        case .retail:
            return viewModel.properties.filter { $0.propertyType?.lowercased() == "retail" }
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            contentView
        }
    }
    
    private var contentView: some View {
        mainContent
            .navigationTitle("Properties")
            .navigationBarTitleDisplayMode(.large)
            .background(colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
            .tint(.primaryBlue)
            .toolbar { toolbarContent }
            .overlay(alignment: .bottom) { deleteOverlay }
            .alert("Delete Properties?", isPresented: $showDeleteAlert, actions: alertActions, message: alertMessage)
            .sheet(isPresented: $showAddProperty, content: addPropertySheet)
            .sheet(item: $selectedProperty, content: propertyDetailSheet)
            .sheet(isPresented: $showMatches, content: matchesSheet)
    }
    
    @ViewBuilder
    private func alertActions() -> some View {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
            Task {
                await deleteSelectedProperties()
            }
        }
    }
    
    @ViewBuilder
    private func alertMessage() -> some View {
        Text("Are you sure you want to delete \(selectedProperties.count) property(ies)? This cannot be undone.")
    }
    
    @ViewBuilder
    private func addPropertySheet() -> some View {
        AddPropertyView()
            .environmentObject(viewModel)
    }
    
    @ViewBuilder
    private func propertyDetailSheet(property: Property) -> some View {
        PropertyDetailView(property: property)
            .environmentObject(viewModel)
            .environmentObject(leadViewModel)
    }
    
    @ViewBuilder
    private func matchesSheet() -> some View {
        if let property = matchesProperty {
            PropertyMatchesSheet(matches: currentMatches, property: property)
                .environmentObject(leadViewModel)
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - View Components
    
    private var mainContent: some View {
        ZStack {
            if filteredProperties.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                propertiesGridView
            }
            
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }
    
    private var propertiesGridView: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(filteredProperties) { property in
                        PropertyGridCell(
                            property: property,
                            gridWidth: geometry.size.width,
                            isSelected: selectedProperties.contains(property.id)
                        )
                        .environmentObject(viewModel)
                        .environmentObject(leadViewModel)
                        .onTapGesture {
                            handlePropertyTap(property)
                        }
                        .onLongPressGesture {
                            handlePropertyLongPress(property)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .refreshable {
                await viewModel.fetchProperties()
            }
        }
    }
    
    private var loadingOverlay: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if !viewModel.properties.isEmpty {
                filterMenu
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            trailingToolbarButtons
        }
    }
    
    private var filterMenu: some View {
        Menu {
            ForEach(PropertyFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Label(filter.rawValue, systemImage: filter.icon)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
                if selectedFilter != .all {
                    Text(selectedFilter.rawValue)
                        .font(.caption.bold())
                }
            }
            .foregroundColor(.primaryBlue)
        }
    }
    
    private var trailingToolbarButtons: some View {
        HStack(spacing: 12) {
            if !viewModel.properties.isEmpty {
                Button {
                    selectionMode.toggle()
                    if !selectionMode {
                        selectedProperties.removeAll()
                    }
                } label: {
                    Text(selectionMode ? "Done" : "Select")
                        .foregroundColor(.primaryBlue)
                }
            }
            
            Button {
                showAddProperty = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primaryBlue)
            }
        }
    }
    
    @ViewBuilder
    private var deleteOverlay: some View {
        if selectionMode && !selectedProperties.isEmpty {
            HStack(spacing: 16) {
                Button {
                    showDeleteAlert = true
                } label: {
                    Label("Delete \(selectedProperties.count)", systemImage: "trash")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.errorRed)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.cardBackground.opacity(0.95))
        }
    }
    
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryBlue.opacity(0.1), Color.successGreen.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 70, weight: .regular))
                    .foregroundColor(.primaryBlue)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                Text("No Properties Yet")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Add your first property listing and we'll automatically match it with potential leads.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("Tip: Properties are matched with leads based on type, size, and location")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
            )
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Helper Functions
    
    private func handlePropertyTap(_ property: Property) {
        if selectionMode {
            if selectedProperties.contains(property.id) {
                selectedProperties.remove(property.id)
            } else {
                selectedProperties.insert(property.id)
            }
        } else {
            selectedProperty = property
        }
    }
    
    private func handlePropertyLongPress(_ property: Property) {
        if !selectionMode {
            let matches = viewModel.calculateMatches(for: property, with: leadViewModel.leads)
            currentMatches = matches
            matchesProperty = property
            showMatches = true
            
            print("🎯 Long press: Found \(matches.count) matches for \(property.title)")
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func deleteSelectedProperties() async {
        for propertyId in selectedProperties {
            do {
                try await viewModel.deleteProperty(id: propertyId)
            } catch {
                print("❌ Failed to delete property:", error)
            }
        }
        selectedProperties.removeAll()
        selectionMode = false
    }
}

struct PropertyGridCell: View {
    let property: Property
    let gridWidth: CGFloat
    var isSelected: Bool = false
    @EnvironmentObject var viewModel: PropertyViewModel
    @EnvironmentObject var leadViewModel: LeadViewModel
    
    private var cellWidth: CGFloat {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 4
        let availableWidth = gridWidth - totalSpacing
        // Prevent NaN by ensuring positive width
        guard availableWidth > 0 else { return 100 }
        return max(100, availableWidth / 3)
    }
    
    // Fixed uniform dimensions
    private let imageHeight: CGFloat = 120
    private let detailsHeight: CGFloat = 60
    
    // PERFORMANCE OPTIMIZED: Cache match count to avoid recalculation on every render
    // This computed property now benefits from PropertyViewModel's internal caching
    var matchCount: Int {
        viewModel.calculateMatches(for: property, with: leadViewModel.leads).count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Image with fixed height
                if let primaryImage = property.primaryImage, !primaryImage.isEmpty {
                    if let imageData = loadBase64Image(primaryImage) {
                        Image(uiImage: imageData)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cellWidth, height: imageHeight)
                            .clipped()
                    } else {
                        placeholderImage
                    }
                } else {
                    placeholderImage
                }
                
                // Overlays
                VStack {
                    HStack {
                        // Status Toggle Button (top left)
                        statusToggleButton
                        
                        Spacer()
                        
                        // Status Badge (top right) - Optimized for longer text
                        Text(property.status)
                            .font(.system(size: property.status.count > 9 ? 7 : 9, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, property.status.count > 9 ? 6 : 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(statusColor.opacity(0.95))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                    }
                    
                    Spacer()
                    
                    // Match Badge (bottom right) - only if matches exist
                    if matchCount > 0 {
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("\(matchCount)")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.orange)
                            )
                            .padding(6)
                        }
                    }
                }
            }
            .frame(width: cellWidth, height: imageHeight)
            .clipped()
            
            // Details section with fixed height
            VStack(alignment: .leading, spacing: 2) {
                Text(property.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let city = property.city, !city.isEmpty {
                    Text(city)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let budget = property.budget, !budget.isEmpty {
                    Text(budget)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.successGreen)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .frame(width: cellWidth, height: detailsHeight, alignment: .topLeading)
            .background(Color.cardBackground.opacity(0.95))
        }
        .frame(width: cellWidth, height: imageHeight + detailsHeight)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 3)
        )
        .overlay(
            Group {
                if isSelected {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primaryBlue)
                                .background(Circle().fill(Color.white))
                                .padding(8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        )
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.primaryBlue.opacity(0.15), Color.successGreen.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: cellWidth, height: imageHeight)
            .overlay(
                Image(systemName: propertyTypeIcon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.primaryBlue.opacity(0.6))
            )
    }
    
    private var statusToggleButton: some View {
        Button {
            toggleStatus()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 32, height: 32)
                
                Image(systemName: property.status == "Available" ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(statusColor)
            }
        }
        .padding(6)
    }
    
    private func toggleStatus() {
        Task {
            let newStatus = property.status == "Available" ? "Unavailable" : "Available"
            
            // Create update payload
            var updates = PropertyUpdatePayload()
            updates.status = newStatus
            
            // Update in view model
            do {
                try await viewModel.updateProperty(id: property.id, updates: updates)
                #if DEBUG
                print("✅ Property status toggled to: \(newStatus)")
                #endif
            } catch {
                #if DEBUG
                print("❌ Failed to toggle property status:", error)
                #endif
            }
        }
    }
    
    private var propertyTypeIcon: String {
        switch property.propertyType?.lowercased() {
        case "warehouse": return "shippingbox.fill"
        case "office": return "building.2.fill"
        case "industrial": return "wrench.and.screwdriver.fill"
        case "retail": return "storefront.fill"
        case "land": return "map.fill"
        case "flex": return "rectangle.3.group.fill"
        default: return "building.2.fill"
        }
    }
    
    private var statusColor: Color {
        switch property.status {
        case "Available": return .successGreen
        case "Under Contract": return .orange
        case "Leased": return .blue
        case "Sold": return .gray
        default: return .primaryBlue
        }
    }
    
    // Load base64 encoded image
    private func loadBase64Image(_ base64String: String) -> UIImage? {
        var imageString = base64String
        if imageString.hasPrefix("data:image") {
            if let commaRange = imageString.range(of: ",") {
                imageString = String(imageString[commaRange.upperBound...])
            }
        }
        
        guard let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
}

struct PropertyMatchesSheet: View {
    let matches: [LeadPropertyMatch]
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var leadViewModel: LeadViewModel
    @State private var selectedLead: Lead?
    @State private var showShareSheet = false
    @State private var leadToShare: Lead?
    @State private var expandedMatchId: String?
    @State private var dismissedLeadIds: Set<String> = []
    
    // Filter out dismissed leads
    private var visibleMatches: [LeadPropertyMatch] {
        matches.filter { !dismissedLeadIds.contains($0.lead.id) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sophisticated gradient background (deep navy to dark slate)
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.12, blue: 0.20),  // Deep navy
                        Color(red: 0.12, green: 0.14, blue: 0.18)   // Dark slate
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        leadsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Matched Leads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(item: $selectedLead) { lead in
                NavigationView {
                    LeadDetailView(lead: lead)
                }
            }
            .sheet(item: $leadToShare) { lead in
                LeadShareActionSheet(
                    lead: lead,
                    propertyText: shareText,
                    propertyURL: propertyURL,
                    trackedURL: trackedURL(for: lead)
                )
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Count with gradient accent
            Text("\(visibleMatches.count) Matching Lead\(visibleMatches.count == 1 ? "" : "s")")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Swipe left to dismiss • Tap to expand")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.3)
            
            if dismissedLeadIds.count > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("\(dismissedLeadIds.count) lead\(dismissedLeadIds.count == 1 ? "" : "s") dismissed")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.4, green: 0.8, blue: 0.5).opacity(0.15))
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private var leadsList: some View {
        VStack(spacing: 16) {
            ForEach(visibleMatches) { match in
                LeadMatchCard(
                    match: match,
                    property: property,
                    isExpanded: expandedMatchId == match.id,
                    onToggle: {
                        withAnimation(.spring(response: 0.3)) {
                            if expandedMatchId == match.id {
                                expandedMatchId = nil
                            } else {
                                expandedMatchId = match.id
                            }
                        }
                    },
                    onViewDetails: {
                        selectedLead = match.lead
                    },
                    onSend: {
                        leadToShare = match.lead
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.3)) {
                            dismissedLeadIds.insert(match.lead.id)
                            
                            // Haptic feedback
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }
                )
            }
            
            // Show message if all matches dismissed - Sophisticated empty state
            if visibleMatches.isEmpty && matches.count > 0 {
                VStack(spacing: 20) {
                    // Premium checkmark with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.85, blue: 0.5),
                                        Color(red: 0.2, green: 0.75, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color(red: 0.3, green: 0.85, blue: 0.5).opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text("All Leads Reviewed")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("You've dismissed all matched leads for this property")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 30)
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dismissedLeadIds.removeAll()
                        }
                        
                        // Haptic
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Show Dismissed Leads")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 50)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var propertyURL: String {
        return "https://trusenda.com/property/\(property.id.replacingOccurrences(of: "\u{2011}", with: "-"))"
    }
    
    private var shareText: String {
        return "Check out this property that might be a good fit for you:\n\n\(property.title)\n\n\(propertyURL)"
    }
    
    private func trackedURL(for lead: Lead) -> String {
        return "\(propertyURL)?leadId=\(lead.id)&leadName=\(lead.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")\(lead.email != nil ? "&leadEmail=\(lead.email!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : "")\(lead.phone != nil ? "&leadPhone=\(lead.phone!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : "")"
    }
}

// MARK: - Lead Match Card Component
struct LeadMatchCard: View {
    let match: LeadPropertyMatch
    let property: Property
    let isExpanded: Bool
    let onToggle: () -> Void
    let onViewDetails: () -> Void
    let onSend: () -> Void
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            leadCardHeader
            if isExpanded {
                expandedContent
            }
        }
        .background(
            // Sophisticated card with subtle gradient
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.98, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        // Multi-layer shadow for depth (modern iOS style)
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(white: 1.0, opacity: 0.2), lineWidth: 1)
        )
        .offset(x: offset)
        .opacity(isDragging ? 0.9 : 1.0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow left swipe (negative offset)
                    if value.translation.width < 0 {
                        isDragging = true
                        offset = value.translation.width
                    }
                }
                .onEnded { value in
                    isDragging = false
                    
                    // If swiped far enough, dismiss
                    if offset < -100 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = -500
                        }
                        
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // Dismiss after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismiss()
                        }
                    } else {
                        // Spring back
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
                }
        )
        .overlay(alignment: .trailing) {
            // Dismiss icon appears when swiping
            if offset < -20 {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                    Text("Dismiss")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .opacity(min(1.0, abs(offset) > 0 ? Double(abs(offset)) / 100.0 : 0.0))
            }
        }
    }
    
    private var leadCardHeader: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Premium avatar with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),  // Bright blue
                                    Color(red: 0.1, green: 0.4, blue: 0.9)   // Deep blue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text(match.lead.name.prefix(1).uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Lead Info with better typography
                VStack(alignment: .leading, spacing: 5) {
                    Text(match.lead.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    if let company = match.lead.company {
                        Text(company)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                matchScoreBadge
                
                // Chevron with better styling
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .padding(.leading, 4)
            }
            .padding(18)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var matchScoreBadge: some View {
        VStack(spacing: 3) {
            Text("\(match.matchScore)%")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(matchScoreColor)
            Text("MATCH")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(matchScoreColor.opacity(0.7))
                .tracking(0.8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            matchScoreColor.opacity(0.15),
                            matchScoreColor.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(matchScoreColor.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(color: matchScoreColor.opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            matchReasonsSection
            leadDetailsSection
            actionButtons
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var matchReasonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why This Matches")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.black.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(match.matchReasons, id: \.self) { reason in
                    HStack(spacing: 10) {
                        // Premium checkmark with gradient
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.85, blue: 0.5),  // Bright green
                                            Color(red: 0.2, green: 0.75, blue: 0.4)   // Deeper green
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 22, height: 22)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(reason)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.85))
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.3, green: 0.85, blue: 0.5).opacity(0.06))
        )
        .padding(.horizontal, 16)
    }
    
    private var leadDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Contact Info with modern styling
            if let email = match.lead.email, !email.isEmpty, let phone = match.lead.phone, !phone.isEmpty {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                        }
                        
                        Text(email)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.75))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.3, green: 0.85, blue: 0.5).opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "phone.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.3, green: 0.85, blue: 0.5))
                        }
                        
                        Text(phone)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.75))
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.02))
                )
                .padding(.horizontal, 16)
                
                Divider()
                    .padding(.horizontal, 16)
            }
            
            // Lead Requirements with premium styling
            VStack(alignment: .leading, spacing: 14) {
                Text("Lead Requirements")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                VStack(alignment: .leading, spacing: 12) {
                    if let budget = match.lead.budget, !budget.isEmpty {
                        requirementRow(
                            icon: "dollarsign.circle.fill",
                            iconColor: Color(red: 0.3, green: 0.85, blue: 0.5),
                            label: "Budget",
                            value: budget
                        )
                    }
                    
                    if let sizeMin = match.lead.sizeMin, let sizeMax = match.lead.sizeMax, !sizeMin.isEmpty, !sizeMax.isEmpty {
                        requirementRow(
                            icon: "ruler.fill",
                            iconColor: Color(red: 0.2, green: 0.5, blue: 1.0),
                            label: "Size",
                            value: "\(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF"
                        )
                    } else if let sizeMin = match.lead.sizeMin, !sizeMin.isEmpty {
                        requirementRow(
                            icon: "ruler.fill",
                            iconColor: Color(red: 0.2, green: 0.5, blue: 1.0),
                            label: "Size",
                            value: "\(formatNumber(sizeMin))+ SF"
                        )
                    }
                    
                    if let timeline = match.lead.timelineStatus {
                        requirementRow(
                            icon: "clock.fill",
                            iconColor: timelineColor(timeline),
                            label: "Timeline",
                            value: timeline
                        )
                    }
                    
                    // Lead Status
                    requirementRow(
                        icon: statusIcon(match.lead.status),
                        iconColor: statusColor(match.lead.status),
                        label: "Status",
                        value: match.lead.status
                    )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.02))
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func requirementRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
    
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
    
    private func timelineColor(_ timeline: String) -> Color {
        switch timeline {
        case "Immediate": return Color(red: 1.0, green: 0.3, blue: 0.3)     // Vibrant red
        case "Heating Up": return Color(red: 1.0, green: 0.6, blue: 0.2)   // Warm orange
        case "Upcoming": return Color(red: 0.2, green: 0.5, blue: 1.0)     // Bright blue
        default: return Color.gray
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Cold": return Color(red: 0.4, green: 0.7, blue: 1.0)         // Cool blue
        case "Warm": return Color(red: 1.0, green: 0.6, blue: 0.2)        // Warm orange
        case "Hot": return Color(red: 1.0, green: 0.3, blue: 0.3)         // Hot red
        case "Closed": return Color(red: 0.3, green: 0.85, blue: 0.5)     // Success green
        default: return Color.gray
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
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // View Details - Elegant secondary button
                Button(action: onViewDetails) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 16))
                        Text("View")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 1.0))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Send Property - Premium gradient button
                Button(action: onSend) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                        Text("Send")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.5, blue: 1.0),
                                        Color(red: 0.1, green: 0.4, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 0.2, green: 0.5, blue: 1.0).opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                }
            }
            
            // Dismiss button - Subtle but clear
            Button(action: onDismiss) {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsdown.fill")
                        .font(.system(size: 14))
                    Text("Not a Good Fit")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.black.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var matchScoreColor: Color {
        switch match.matchScore {
        case 80...100: return Color(red: 0.3, green: 0.85, blue: 0.5)  // Vibrant green
        case 60..<80: return Color(red: 0.2, green: 0.5, blue: 1.0)    // Bright blue
        case 40..<60: return Color(red: 1.0, green: 0.6, blue: 0.2)    // Warm orange
        default: return Color.gray
        }
    }
}


