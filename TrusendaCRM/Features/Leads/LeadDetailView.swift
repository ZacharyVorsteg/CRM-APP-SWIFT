import SwiftUI

struct LeadDetailView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    @State private var showEditSheet = false
    @State private var showFollowUpSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(lead.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let company = lead.company {
                            Text(company)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status badge
                        Text(lead.status)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor(lead.status).opacity(0.2))
                            .foregroundColor(statusColor(lead.status))
                            .cornerRadius(12)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    
                    // Contact Info
                    if lead.email != nil || lead.phone != nil {
                        GroupBox("Contact") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let email = lead.email, !email.isEmpty {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.blue)
                                        Text(email)
                                        Spacer()
                                    }
                                }
                                
                                if let phone = lead.phone, !phone.isEmpty {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.green)
                                        Text(phone)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Property Details
                    GroupBox("Property Details") {
                        VStack(alignment: .leading, spacing: 12) {
                            if let propertyType = lead.propertyType {
                                DetailRow(label: "Type", value: propertyType)
                            }
                            
                            if let transactionType = lead.transactionType {
                                DetailRow(label: "Transaction", value: transactionType)
                            }
                            
                            if let budget = lead.budget {
                                DetailRow(label: "Budget", value: "$\(budget)")
                            }
                            
                            if let timeline = lead.timelineStatus {
                                DetailRow(label: "Timeline", value: timeline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Follow-up
                    if lead.followUpOn != nil || lead.needsAttention {
                        GroupBox("Follow-Up") {
                            VStack(alignment: .leading, spacing: 12) {
                                if let followUpDate = lead.followUpDate {
                                    HStack {
                                        Image(systemName: lead.needsAttention ? "exclamationmark.triangle.fill" : "calendar")
                                            .foregroundColor(lead.needsAttention ? .orange : .blue)
                                        Text(followUpDate.toDisplayString())
                                        Spacer()
                                        if lead.needsAttention {
                                            Text("DUE")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                
                                if let notes = lead.followUpNotes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Quick actions
                                HStack(spacing: 12) {
                                    Button {
                                        showFollowUpSheet = true
                                    } label: {
                                        Label("Reschedule", systemImage: "calendar.badge.plus")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button {
                                        Task {
                                            try? await viewModel.markContacted(leadId: lead.id)
                                            dismiss()
                                        }
                                    } label: {
                                        Label("Mark Contacted", systemImage: "checkmark")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notes
                    if let notes = lead.notes, !notes.isEmpty {
                        GroupBox("Notes") {
                            Text(notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Metadata
                    GroupBox("Created") {
                        if let createdDate = lead.createdDate {
                            Text(createdDate.toDisplayString())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Text("Edit")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditLeadView(lead: lead)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showFollowUpSheet) {
                FollowUpScheduleView(lead: lead)
                    .environmentObject(viewModel)
            }
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

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct EditLeadView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var company: String
    @State private var status: String
    @State private var notes: String
    
    init(lead: Lead) {
        self.lead = lead
        _name = State(initialValue: lead.name)
        _email = State(initialValue: lead.email ?? "")
        _phone = State(initialValue: lead.phone ?? "")
        _company = State(initialValue: lead.company ?? "")
        _status = State(initialValue: lead.status)
        _notes = State(initialValue: lead.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Phone", text: $phone)
                TextField("Company", text: $company)
                
                Picker("Status", selection: $status) {
                    ForEach(["Cold", "Warm", "Hot", "Closed"], id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Lead")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveLead()
                        }
                    }
                }
            }
        }
    }
    
    private func saveLead() async {
        var updates = LeadUpdatePayload()
        updates.name = name
        updates.email = email.isEmpty ? nil : email
        updates.phone = phone.isEmpty ? nil : phone
        updates.company = company.isEmpty ? nil : company
        updates.status = status
        updates.notes = notes.isEmpty ? nil : notes
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            dismiss()
        } catch {
            print("Failed to update lead:", error)
        }
    }
}

struct FollowUpScheduleView: View {
    let lead: Lead
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    
    @State private var followUpDate = Date()
    @State private var followUpNotes = ""
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Follow-up Date", selection: $followUpDate, in: Date()..., displayedComponents: .date)
                
                Section("Notes") {
                    TextEditor(text: $followUpNotes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Schedule Follow-Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveFollowUp()
                        }
                    }
                }
            }
        }
    }
    
    private func saveFollowUp() async {
        var updates = LeadUpdatePayload()
        updates.followUpOn = followUpDate.toISO8601String()
        updates.followUpNotes = followUpNotes.isEmpty ? nil : followUpNotes
        updates.needsAttention = false
        
        do {
            try await viewModel.updateLead(id: lead.id, updates: updates)
            dismiss()
        } catch {
            print("Failed to schedule follow-up:", error)
        }
    }
}

