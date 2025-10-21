import SwiftUI

struct PropertiesListView: View {
    @StateObject private var viewModel = PropertyViewModel()
    @EnvironmentObject var leadViewModel: LeadViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddProperty = false
    @State private var selectedProperty: Property?
    @State private var showMatches = false
    @State private var currentMatches: [LeadPropertyMatch] = []
    
    // Instagram-style 3-column grid layout
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.properties.isEmpty && !viewModel.isLoading {
                    // Empty state - matches app aesthetic
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
                        
                        // Helpful tip
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
                    // Instagram-style 3-column grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(viewModel.properties) { property in
                                PropertyGridCell(property: property)
                                    .onTapGesture {
                                        selectedProperty = property
                                    }
                                    .onLongPressGesture {
                                        // Show matches for this property
                                        let matches = viewModel.calculateMatches(for: property, with: leadViewModel.leads)
                                        if !matches.isEmpty {
                                            currentMatches = matches
                                            showMatches = true
                                            
                                            // Haptic feedback
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
                
                // Loading overlay
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProperty = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primaryBlue)
                    }
                }
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
            .task {
                await viewModel.fetchProperties()
            }
        }
    }
}

// MARK: - Property Grid Cell (Instagram Style)
struct PropertyGridCell: View {
    let property: Property
    
    var body: some View {
        VStack(spacing: 0) {
            // Image (square aspect ratio like Instagram)
            ZStack {
                if let primaryImage = property.primaryImage, !primaryImage.isEmpty {
                    // TODO: Load actual image from URL/data
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                } else {
                    // Placeholder with property type icon
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryBlue.opacity(0.15), Color.successGreen.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: propertyTypeIcon)
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(.primaryBlue.opacity(0.6))
                        )
                }
                
                // Status badge (top right)
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
            .aspectRatio(1, contentMode: .fill)  // Square like Instagram
            .clipped()
            
            // Info overlay at bottom
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
                
                if let price = property.price, !price.isEmpty {
                    Text(price)
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
}

// MARK: - Property Matches Sheet
struct PropertyMatchesSheet: View {
    let matches: [LeadPropertyMatch]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(matches) { match in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(match.lead.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let company = match.lead.company {
                                    Text(company)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Match score badge
                            VStack(spacing: 2) {
                                Text("\(match.matchScore)%")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(match.matchQuality == .excellent ? .successGreen : .primaryBlue)
                                Text(match.matchQuality.label)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primaryBlue.opacity(0.1))
                            )
                        }
                        
                        // Match reasons
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(match.matchReasons, id: \.self) { reason in
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.successGreen)
                                    Text(reason)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Matching Leads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
}

