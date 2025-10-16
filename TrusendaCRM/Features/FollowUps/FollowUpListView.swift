import SwiftUI

struct FollowUpListView: View {
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var selectedLead: Lead?
    
    var followUpLeads: [Lead] {
        viewModel.leads
            .filter { $0.needsAttention }
            .sorted { lead1, lead2 in
                guard let date1 = lead1.followUpDate, let date2 = lead2.followUpDate else {
                    return false
                }
                return date1 < date2
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if followUpLeads.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("All Caught Up!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("No follow-ups needed right now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(followUpLeads) { lead in
                            FollowUpRowView(lead: lead)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedLead = lead
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchLeads()
                    }
                }
            }
            .navigationTitle("Follow-Ups")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedLead) { lead in
                LeadDetailView(lead: lead)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct FollowUpRowView: View {
    let lead: Lead
    @EnvironmentObject var viewModel: LeadViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lead.name)
                        .font(.headline)
                    
                    if let company = lead.company {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Urgency indicator
                if let followUpDate = lead.followUpDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        if followUpDate.isPast {
                            Text("OVERDUE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        } else if followUpDate.isToday {
                            Text("TODAY")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        } else {
                            Text(followUpDate.toDisplayString())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        let days = followUpDate.daysFromNow()
                        if days < 0 {
                            Text("\(abs(days))d overdue")
                                .font(.caption2)
                                .foregroundColor(.red)
                        } else if days == 0 {
                            Text("Due today")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        } else {
                            Text("in \(days)d")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if let notes = lead.followUpNotes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Quick actions
            HStack(spacing: 8) {
                Button {
                    Task {
                        try? await viewModel.markContacted(leadId: lead.id)
                    }
                } label: {
                    Label("Contacted", systemImage: "checkmark")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Menu {
                    Button {
                        Task {
                            try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 1)
                        }
                    } label: {
                        Label("1 Day", systemImage: "clock")
                    }
                    
                    Button {
                        Task {
                            try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 3)
                        }
                    } label: {
                        Label("3 Days", systemImage: "clock")
                    }
                    
                    Button {
                        Task {
                            try? await viewModel.snoozeFollowUp(leadId: lead.id, days: 7)
                        }
                    } label: {
                        Label("1 Week", systemImage: "clock")
                    }
                } label: {
                    Label("Snooze", systemImage: "clock")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

