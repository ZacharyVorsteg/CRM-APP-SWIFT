import SwiftUI

struct PropertyShareSheet: View {
    let property: Property
    let matches: [LeadPropertyMatch]
    @Environment(\.dismiss) private var dismiss
    
    private var shareText: String {
        var text = "🏢 Property Listing\n\n"
        text += "\(property.title)\n"
        
        if let address = property.address {
            text += "\(address)\n"
        }
        if let city = property.city, let state = property.state {
            text += "\(city), \(state) \(property.zipCode ?? "")\n"
        }
        
        text += "\n📋 Details:\n"
        
        if let propertyType = property.propertyType {
            text += "• Type: \(propertyType)\n"
        }
        if let transactionType = property.transactionType {
            text += "• Transaction: \(transactionType)\n"
        }
        if let sizeMin = property.sizeMin, let sizeMax = property.sizeMax {
            text += "• Size: \(formatNumber(sizeMin)) - \(formatNumber(sizeMax)) SF\n"
        }
        if let budget = property.budget {
            text += "• Price: \(budget)\n"
        }
        if let leaseTerm = property.leaseTerm {
            text += "• Lease Term: \(leaseTerm)\n"
        }
        if let industry = property.industry {
            text += "• Best For: \(industry)\n"
        }
        
        if let description = property.description {
            text += "\n📝 Description:\n\(description)\n"
        }
        
        if let features = property.features {
            text += "\n✨ Key Features:\n\(features)\n"
        }
        
        if !matches.isEmpty {
            text += "\n🎯 Matched Leads (\(matches.count)):\n"
            for match in matches.prefix(3) {
                text += "• \(match.lead.name)"
                if let company = match.lead.company {
                    text += " - \(company)"
                }
                text += " (\(match.matchScore)% match)\n"
            }
        }
        
        text += "\n✅ Status: \(property.status)"
        
        return text
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Preview card
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share Preview")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(shareText)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryBlue.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .padding()
                }
                
                // Share buttons
                VStack(spacing: 12) {
                    ShareLink(item: shareText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share via...")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button {
                        copyToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                        .font(.headline)
                        .foregroundColor(.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primaryBlue.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Share Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
        }
    }
    
    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? value
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

