import SwiftUI

/// Premium document viewer for Terms & Conditions and Privacy Policy
/// Maintains enterprise aesthetic with proper formatting and accessibility
struct LegalDocumentView: View {
    let documentType: LegalDocumentType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    enum LegalDocumentType {
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
        
        var version: String {
            switch self {
            case .terms: return LegalDocuments.termsVersion
            case .privacy: return LegalDocuments.privacyVersion
            }
        }
        
        var effectiveDate: String {
            switch self {
            case .terms: return LegalDocuments.termsEffectiveDate
            case .privacy: return LegalDocuments.privacyEffectiveDate
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background matching app aesthetic
                (colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header card with metadata
                        VStack(alignment: .leading, spacing: 12) {
                            Text(documentType.title)
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Version")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(documentType.version)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primaryBlue)
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Effective Date")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(documentType.effectiveDate)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primaryBlue)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Document content with proper formatting
                        VStack(alignment: .leading, spacing: 16) {
                            FormattedDocumentText(content: documentType.content)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Contact information footer
                        ContactFooter()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 24)
                    }
                    .padding(.bottom, 24)
                }
            }
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

/// Formatted text component with proper styling for legal documents
struct FormattedDocumentText: View {
    let content: String
    
    var body: some View {
        // Split into sections for better formatting
        let sections = content.components(separatedBy: "\n\n")
        
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                FormatSection(section: section)
            }
        }
    }
}

/// Format individual sections with hierarchical styling
struct FormatSection: View {
    let section: String
    
    var body: some View {
        let trimmedSection = section.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Detect section type by format
        if isMainHeading(trimmedSection) {
            // Main heading (ALL CAPS)
            Text(trimmedSection)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.top, 8)
        } else if isSectionHeading(trimmedSection) {
            // Section heading (starts with number)
            Text(trimmedSection)
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.top, 12)
        } else if isSubsection(trimmedSection) {
            // Subsection (e.g., "1.1 Title")
            Text(trimmedSection)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.top, 8)
        } else if isBulletPoint(trimmedSection) {
            // Bullet point
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                Text(trimmedSection.replacingOccurrences(of: "• ", with: ""))
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 8)
        } else if isImportantNotice(trimmedSection) {
            // Important notice (ALL CAPS or IMPORTANT LEGAL NOTICE)
            Text(trimmedSection)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.errorRed)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.errorRed.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.errorRed.opacity(0.3), lineWidth: 1)
                        )
                )
        } else {
            // Regular paragraph
            Text(trimmedSection)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func isMainHeading(_ text: String) -> Bool {
        return text == text.uppercased() && 
               text.count < 100 &&
               !text.contains("IMPORTANT") &&
               !text.contains("SHALL") &&
               !text.starts(with: "•")
    }
    
    private func isSectionHeading(_ text: String) -> Bool {
        // Matches patterns like "1. TITLE" or "12. TITLE"
        let pattern = "^[0-9]{1,2}\\. [A-Z]"
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isSubsection(_ text: String) -> Bool {
        // Matches patterns like "1.1 Title" or "12.3 Title"
        let pattern = "^[0-9]{1,2}\\.[0-9]{1,2} "
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isBulletPoint(_ text: String) -> Bool {
        return text.starts(with: "• ") || text.starts(with: "* ")
    }
    
    private func isImportantNotice(_ text: String) -> Bool {
        return text.contains("IMPORTANT") ||
               text.contains("PLEASE READ") ||
               text.contains("WAIVING YOUR RIGHT") ||
               (text == text.uppercased() && text.contains("SHALL"))
    }
}

/// Contact information footer
struct ContactFooter: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Questions or Concerns?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ContactLink(
                    icon: "envelope.fill",
                    title: "Email Support",
                    subtitle: "support@trusenda.com",
                    url: URL(string: "mailto:support@trusenda.com")!
                )
                
                ContactLink(
                    icon: "envelope.fill",
                    title: "Privacy Inquiries",
                    subtitle: "privacy@trusenda.com",
                    url: URL(string: "mailto:privacy@trusenda.com")!
                )
                
                ContactLink(
                    icon: "envelope.fill",
                    title: "Legal Questions",
                    subtitle: "legal@trusenda.com",
                    url: URL(string: "mailto:legal@trusenda.com")!
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

/// Contact link component
struct ContactLink: View {
    let icon: String
    let title: String
    let subtitle: String
    let url: URL
    
    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primaryBlue.opacity(0.6))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryBlue.opacity(0.05))
            )
        }
    }
}

/// Compact summary view for signup flow
struct LegalSummaryView: View {
    @Binding var showTerms: Bool
    @Binding var showPrivacy: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.primaryBlue)
                Text("Legal Agreement Summary")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(LegalDocuments.getSummary())
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                Button {
                    showTerms = true
                } label: {
                    Text("Read Terms")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Button {
                    showPrivacy = true
                } label: {
                    Text("Read Privacy Policy")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryBlue)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primaryBlue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    LegalDocumentView(documentType: .terms)
}

