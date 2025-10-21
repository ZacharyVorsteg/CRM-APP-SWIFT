import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: PropertyViewModel
    @EnvironmentObject var leadViewModel: LeadViewModel
    @State private var showEditSheet = false
    @State private var showMatchesSheet = false
    @State private var showDeleteAlert = false
    @State private var matches: [LeadPropertyMatch] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header Card - Premium Salesforce-style
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(property.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Status badge
                            Text(property.status)
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(statusColor.opacity(0.15))
                                )
                                .foregroundColor(statusColor)
                        }
                        
                        if let address = property.address {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Text(address)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let city = property.city, let state = property.state {
                            Text("\(city), \(state) \(property.zipCode ?? "")")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
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
                    
                    // Photo Gallery (if images exist)
                    if let images = property.images, !images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(images.enumerated()), id: \.offset) { index, imageString in
                                    if let image = loadBase64Image(imageString) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Property Details Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("PROPERTY DETAILS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(0.8)
                        
                        VStack(spacing: 10) {
                            if let propertyType = property.propertyType, !propertyType.isEmpty {
                                DetailRow(label: "Type", value: propertyType, icon: "building.2")
                                Divider()
                            }
                            
                            if let transactionType = property.transactionType {
                                DetailRow(label: "Transaction", value: transactionType, icon: "doc.text")
                                Divider()
                            }
                            
                            if let sizeMin = property.sizeMin, let sizeMax = property.sizeMax {
                                let sizeDisplay = "\(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF"
                                DetailRow(label: "Size", value: sizeDisplay, icon: "ruler")
                                Divider()
                            }
                            
                            if let budget = property.budget, !budget.isEmpty {
                                DetailRow(label: "Price", value: budget, icon: "dollarsign.circle")
                                Divider()
                            }
                            
                            if let industry = property.industry {
                                DetailRow(label: "Best For", value: industry, icon: "briefcase")
                                Divider()
                            }
                            
                            if let leaseTerm = property.leaseTerm {
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
                    
                    // Matching Leads Section
                    if !matches.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("MATCHED LEADS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .tracking(0.8)
                                
                                Spacer()
                                
                                Text("\(matches.count) matches")
                                    .font(.caption.bold())
                                    .foregroundColor(.successGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.successGreen.opacity(0.15))
                                    .cornerRadius(6)
                            }
                            
                            // Top 3 matches preview
                            ForEach(matches.prefix(3)) { match in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(match.lead.name)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        if let company = match.lead.company {
                                            Text(company)
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Match score
                                    Text("\(match.matchScore)%")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(match.matchQuality == .excellent ? .successGreen : .primaryBlue)
                                }
                                .padding(.vertical, 8)
                                
                                if match.id != matches.prefix(3).last?.id {
                                    Divider()
                                }
                            }
                            
                            if matches.count > 3 {
                                Button {
                                    showMatchesSheet = true
                                } label: {
                                    Text("View All \(matches.count) Matches")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primaryBlue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.successGreen.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.successGreen.opacity(0.2), lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Description
                    if let description = property.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(0.8)
                            
                            Text(description)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cardBackground)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Features
                    if let features = property.features, !features.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("KEY FEATURES")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(0.8)
                            
                            Text(features)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cardBackground)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
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
                        showEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditPropertyView(property: property)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showMatchesSheet) {
                PropertyMatchesSheet(matches: matches)
            }
            .onAppear {
                // Calculate matches on appear
                matches = viewModel.calculateMatches(for: property, with: leadViewModel.leads)
                print("🎯 Calculated \(matches.count) matches for \(property.title)")
            }
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
    
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
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

