import SwiftUI

struct RecentActivityView: View {
    @EnvironmentObject var viewModel: LeadViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: ActivityFilter = .all
    
    enum ActivityFilter: String, CaseIterable {
        case all = "All Activity"
        case created = "Created"
        case contacted = "Contacted"
        case statusChanged = "Status Changed"
        case followUpsScheduled = "Follow-Ups"
        case updated = "Updated"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .created: return "plus.circle.fill"
            case .contacted: return "checkmark.circle.fill"
            case .statusChanged: return "arrow.triangle.2.circlepath"
            case .followUpsScheduled: return "calendar.badge.plus"
            case .updated: return "pencil.circle.fill"
            }
        }
    }
    
    // Generate activity items from leads
    var activityItems: [ActivityItem] {
        var items: [ActivityItem] = []
        
        // Get all leads sorted by most recent first
        let sortedLeads = viewModel.leads.sorted { lead1, lead2 in
            let date1 = parseDate(lead1.updatedAt) ?? Date.distantPast
            let date2 = parseDate(lead2.updatedAt) ?? Date.distantPast
            return date1 > date2
        }
        
        // Generate activity items for each lead
        for lead in sortedLeads {
            // Lead created activity
            if let createdDate = lead.createdDate {
                items.append(ActivityItem(
                    id: "\(lead.id)-created",
                    leadId: lead.id,
                    leadName: lead.name,
                    company: lead.company,
                    type: .created,
                    date: createdDate,
                    details: "Added to CRM",
                    status: lead.status
                ))
            }
            
            // Follow-up scheduled
            if let followUpDate = lead.followUpDate {
                items.append(ActivityItem(
                    id: "\(lead.id)-followup",
                    leadId: lead.id,
                    leadName: lead.name,
                    company: lead.company,
                    type: .followUpsScheduled,
                    date: followUpDate,
                    details: lead.followUpNotes ?? "Follow-up scheduled",
                    status: lead.status
                ))
            }
        }
        
        // Sort all activities by date (most recent first)
        items.sort { $0.date > $1.date }
        
        // Apply filter
        if selectedFilter != .all {
            items = items.filter { $0.type == selectedFilter }
        }
        
        // Limit to last 50 activities for performance
        return Array(items.prefix(50))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if activityItems.isEmpty {
                    // Empty state - matches Follow-Ups aesthetic
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
                            
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 70, weight: .regular))
                                .foregroundColor(.primaryBlue)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 12) {
                            Text("No Recent Activity")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text("Your CRM activity will appear here as you add and manage leads.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 40)
                        }
                    }
                    .padding(.vertical, 60)
                } else {
                    List {
                        ForEach(activityItems) { item in
                            ActivityRowView(item: item)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.cardBackground)
                                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.fetchLeads()
                    }
                }
            }
            .navigationTitle("Recent Activity")
            .navigationBarTitleDisplayMode(.large)
            .background(colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
            .tint(.primaryBlue)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(ActivityFilter.allCases, id: \.self) { filter in
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
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = customFormatter.date(from: dateString) {
            return date
        }
        
        customFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return customFormatter.date(from: dateString)
    }
}

// MARK: - Activity Item Model
struct ActivityItem: Identifiable {
    let id: String
    let leadId: String
    let leadName: String
    let company: String?
    let type: RecentActivityView.ActivityFilter
    let date: Date
    let details: String
    let status: String
}

// MARK: - Activity Row View
struct ActivityRowView: View {
    let item: ActivityItem
    
    var body: some View {
        HStack(spacing: 14) {
            // Activity icon with color-coded background
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.type.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(activityColor)
            }
            
            // Activity details
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(item.leadName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    // Status badge
                    Text(item.status)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(statusColor(item.status).opacity(0.15))
                        )
                        .foregroundColor(statusColor(item.status))
                }
                
                if let company = item.company, !company.isEmpty {
                    Text(company)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                // Activity type and details
                HStack(spacing: 6) {
                    Text(activityTypeText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(activityColor)
                    
                    if !item.details.isEmpty && item.details != activityTypeText {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(item.details)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                // Timestamp
                Text(item.date.toRelativeString())
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
    
    private var activityColor: Color {
        switch item.type {
        case .all: return .primaryBlue
        case .created: return .successGreen
        case .contacted: return .blue
        case .statusChanged: return .purple
        case .followUpsScheduled: return .orange
        case .updated: return .primaryBlue
        }
    }
    
    private var activityTypeText: String {
        switch item.type {
        case .all: return "Activity"
        case .created: return "Lead Created"
        case .contacted: return "Marked as Contacted"
        case .statusChanged: return "Status Updated"
        case .followUpsScheduled: return "Follow-Up Scheduled"
        case .updated: return "Lead Updated"
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
}

// MARK: - Date Extensions
extension Date {
    func toRelativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

