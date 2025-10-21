import SwiftUI

struct PropertiesListView: View {
    @EnvironmentObject var viewModel: PropertyViewModel
    @EnvironmentObject var leadViewModel: LeadViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddProperty = false
    @State private var selectedProperty: Property?
    @State private var showMatches = false
    @State private var currentMatches: [LeadPropertyMatch] = []
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
            case .industrial: return "factory.fill"
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
            ZStack {
                // Match notification badge
                if let lastProperty = viewModel.properties.first,
                   !viewModel.calculateMatches(for: lastProperty, with: leadViewModel.leads).isEmpty,
                   !UserDefaults.standard.bool(forKey: "seen_property_\(lastProperty.id)") {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                selectedProperty = lastProperty
                                UserDefaults.standard.set(true, forKey: "seen_property_\(lastProperty.id)")
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.badge.fill")
                                        .font(.title3)
                                    Text("New Match!")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .cornerRadius(20)
                                .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                    .zIndex(100)
                }
                
                if filteredProperties.isEmpty && !viewModel.isLoading {
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
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(filteredProperties) { property in
                                    PropertyGridCell(
                                        property: property,
                                        gridWidth: geometry.size.width,
                                        isSelected: selectedProperties.contains(property.id)
                                    )
                                    .onTapGesture {
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
                                    .onLongPressGesture {
                                        if !selectionMode {
                                            let matches = viewModel.calculateMatches(for: property, with: leadViewModel.leads)
                                            currentMatches = matches
                                            showMatches = true
                                            
                                            print("🎯 Long press: Found \(matches.count) matches for \(property.title)")
                                            
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                        }
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationTitle("Properties")
            .navigationBarTitleDisplayMode(.large)
            .background(colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
            .tint(.primaryBlue)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.properties.isEmpty {
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
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
            }
            .overlay(alignment: .bottom) {
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
            .alert("Delete Properties?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteSelectedProperties()
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(selectedProperties.count) property(ies)? This cannot be undone.")
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedProperty) { property in
                PropertyDetailView(property: property)
                    .environmentObject(viewModel)
                    .environmentObject(leadViewModel)
            }
            .sheet(isPresented: $showMatches) {
                PropertyMatchesSheet(matches: currentMatches)
                    .presentationDetents([.medium, .large])
            }
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
    
    private var cellWidth: CGFloat {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 4
        let availableWidth = gridWidth - totalSpacing
        return availableWidth / 3
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let primaryImage = property.primaryImage, !primaryImage.isEmpty {
                    // Display base64 encoded image
                    if let imageData = loadBase64Image(primaryImage) {
                        Image(uiImage: imageData)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cellWidth, height: cellWidth)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: cellWidth, height: cellWidth)
                    }
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryBlue.opacity(0.15), Color.successGreen.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: cellWidth, height: cellWidth)
                        .overlay(
                            Image(systemName: propertyTypeIcon)
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.primaryBlue.opacity(0.6))
                        )
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Text(property.status)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(statusColor.opacity(0.95))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                    }
                    Spacer()
                }
            }
            .frame(width: cellWidth, height: cellWidth)
            .clipped()
            
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground.opacity(0.95))
        }
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
    
    private var propertyTypeIcon: String {
        switch property.propertyType?.lowercased() {
        case "warehouse": return "shippingbox.fill"
        case "office": return "building.2.fill"
        case "industrial": return "factory.fill"
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
        // Remove data URI prefix if present
        var imageString = base64String
        if imageString.hasPrefix("data:image") {
            if let commaRange = imageString.range(of: ",") {
                imageString = String(imageString[commaRange.upperBound...])
            }
        }
        
        guard let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) else {
            print("❌ Failed to decode base64 image")
            return nil
        }
        
        return UIImage(data: imageData)
    }
}

struct PropertyMatchesSheet: View {
    let matches: [LeadPropertyMatch]
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var leadViewModel: LeadViewModel
    @State private var selectedLead: Lead?
    @State private var showShareSheet = false
    @State private var leadToShare: Lead?
    @State private var expandedMatchId: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    leadsList
                }
                .padding()
            }
            .navigationTitle("Matched Leads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
        VStack(spacing: 8) {
            Text("\(matches.count) Matching Leads")
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text("Tap any lead to view details or send property")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var leadsList: some View {
        VStack(spacing: 16) {
            ForEach(matches) { match in
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
                    }
                )
            }
        }
    }
    
    private var propertyURL: String {
        return "https://trusenda.com/property/\(property.id.uuidString.replacingOccurrences(of: "\u{2011}", with: "-"))"
    }
    
    private var shareText: String {
        return "Check out this property that might be a good fit for you:\n\n\(property.title)\n\n\(propertyURL)"
    }
    
    private func trackedURL(for lead: Lead) -> String {
        return "\(propertyURL)?leadId=\(lead.id.uuidString)&leadName=\(lead.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")\(lead.email != nil ? "&leadEmail=\(lead.email!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : "")\(lead.phone != nil ? "&leadPhone=\(lead.phone!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : "")"
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
    
    var body: some View {
        VStack(spacing: 0) {
            leadCardHeader
            if isExpanded {
                expandedContent
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var leadCardHeader: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Lead Avatar/Initial
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Text(match.lead.name.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryBlue)
                }
                
                // Lead Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.lead.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let company = match.lead.company {
                        Text(company)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                matchScoreBadge
                
                // Chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var matchScoreBadge: some View {
        VStack(spacing: 2) {
            Text("\(match.matchScore)%")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(matchScoreColor)
            Text("MATCH")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(matchScoreColor.opacity(0.12))
        )
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Why This Matches:")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            ForEach(match.matchReasons, id: \.self) { reason in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.successGreen)
                    Text(reason)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var leadDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let email = match.lead.email, !email.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primaryBlue)
                    Text(email)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            if let phone = match.lead.phone, !phone.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primaryBlue)
                    Text(phone)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onViewDetails) {
                HStack {
                    Image(systemName: "person.circle")
                    Text("View Details")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.primaryBlue.opacity(0.1))
                )
            }
            
            Button(action: onSend) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Send Property")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    private var matchScoreColor: Color {
        switch match.matchScore {
        case 80...100: return .successGreen
        case 60..<80: return .primaryBlue
        case 40..<60: return .orange
        default: return .secondary
        }
    }
}


