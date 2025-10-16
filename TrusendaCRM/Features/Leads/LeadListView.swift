import SwiftUI

struct LeadListView: View {
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var showAddLead = false
    @State private var selectedLead: Lead?
    @State private var showDeleteConfirm = false
    @State private var leadToDelete: Lead?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.leads.isEmpty {
                    ProgressView("Loading leads...")
                } else if viewModel.filteredLeads.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        // Plan limit banner
                        if viewModel.isOverLimit {
                            PlanLimitBanner(
                                gracePeriodDays: viewModel.gracePeriodDays,
                                isBlocked: viewModel.isBlocked
                            )
                            .listRowSeparator(.hidden)
                        }
                        
                        ForEach(viewModel.filteredLeads) { lead in
                            LeadRowView(lead: lead)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedLead = lead
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        leadToDelete = lead
                                        showDeleteConfirm = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        selectedLead = lead
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchLeads()
                    }
                }
            }
            .navigationTitle("Leads (\(viewModel.filteredLeads.count))")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddLead = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.isBlocked)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            viewModel.statusFilter = nil
                            viewModel.applyFilters()
                        } label: {
                            Label("All Leads", systemImage: "line.3.horizontal.decrease")
                        }
                        
                        Divider()
                        
                        ForEach(["Cold", "Warm", "Hot", "Closed"], id: \.self) { status in
                            Button {
                                viewModel.statusFilter = status
                                viewModel.applyFilters()
                            } label: {
                                Label(status, systemImage: statusIcon(status))
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applyFilters()
            }
            .sheet(isPresented: $showAddLead) {
                AddLeadView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedLead) { lead in
                LeadDetailView(lead: lead)
                    .environmentObject(viewModel)
            }
            .alert("Delete Lead", isPresented: $showDeleteConfirm, presenting: leadToDelete) { lead in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        try? await viewModel.deleteLead(id: lead.id)
                    }
                }
            } message: { lead in
                Text("Are you sure you want to delete \(lead.name)?")
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.successMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: viewModel.successMessage)
                }
            }
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
}

struct LeadRowView: View {
    let lead: Lead
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lead.name)
                    .font(.headline)
                
                Spacer()
                
                // Status badge
                Text(lead.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(lead.status).opacity(0.2))
                    .foregroundColor(statusColor(lead.status))
                    .cornerRadius(8)
            }
            
            if let company = lead.company {
                Text(company)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if let propertyType = lead.propertyType {
                    Label(propertyType, systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let timeline = lead.timelineStatus {
                    Label(timeline, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Follow-up indicator
            if lead.needsAttention, let followUpDate = lead.followUpDate {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Follow-up: \(followUpDate.toDisplayString())")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Leads Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first lead using the + button")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PlanLimitBanner: View {
    let gracePeriodDays: Int?
    let isBlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isBlocked ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isBlocked ? .red : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isBlocked ? "Lead Limit Reached" : "Over Plan Limit")
                    .font(.headline)
                    .foregroundColor(isBlocked ? .red : .orange)
                
                if let days = gracePeriodDays, !isBlocked {
                    Text("\(days) days remaining to upgrade or remove leads")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if isBlocked {
                    Text("Please upgrade to Pro or remove excess leads")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(isBlocked ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 10)
            .padding()
    }
}

