import SwiftUI

/// Premium full-length legal document viewer with enterprise formatting
/// Uses complete T&Cs and Privacy Policy from LegalDocuments.swift
struct FullLegalDocumentView: View {
    let documentType: LegalDocType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    enum LegalDocType {
        case terms
        case privacy
        
        var title: String {
            switch self {
            case .terms: return "Terms & Conditions"
            case .privacy: return "Privacy Policy"
            }
        }
        
        var content: String {
            switch self {
            case .terms: return LegalDocuments.termsAndConditions
            case .privacy: return LegalDocuments.privacyPolicy
            }
        }
        
        var icon: String {
            switch self {
            case .terms: return "doc.text.fill"
            case .privacy: return "lock.shield.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Premium header card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: documentType.icon)
                                .font(.system(size: 28))
                                .foregroundColor(.primaryBlue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(documentType.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 12) {
                                    Text("Version \(LegalDocuments.termsVersion)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    
                                    Text("Effective \(LegalDocuments.termsEffectiveDate)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Document content with premium formatting
                    VStack(alignment: .leading, spacing: 16) {
                        Text(documentType.content)
                            .font(.system(size: 14, design: .default))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Contact footer
                    LegalContactFooter()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                }
                .padding(.bottom, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

/// Contact footer for legal documents
struct LegalContactFooter: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONTACT INFORMATION")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(0.8)
            
            VStack(spacing: 12) {
                LegalContactRow(
                    icon: "envelope.fill",
                    title: "General Support",
                    value: "support@trusenda.com",
                    url: "mailto:support@trusenda.com"
                )
                
                Divider()
                
                LegalContactRow(
                    icon: "shield.fill",
                    title: "Privacy Inquiries",
                    value: "privacy@trusenda.com",
                    url: "mailto:privacy@trusenda.com"
                )
                
                Divider()
                
                LegalContactRow(
                    icon: "doc.text.fill",
                    title: "Legal Questions",
                    value: "legal@trusenda.com",
                    url: "mailto:legal@trusenda.com"
                )
                
                Divider()
                
                LegalContactRow(
                    icon: "person.badge.shield.checkmark.fill",
                    title: "Data Protection Officer",
                    value: "dpo@trusenda.com",
                    url: "mailto:dpo@trusenda.com"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

/// Individual contact row
struct LegalContactRow: View {
    let icon: String
    let title: String
    let value: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FullLegalDocumentView(documentType: .terms)
}

