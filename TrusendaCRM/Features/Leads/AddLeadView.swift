import SwiftUI

struct AddLeadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LeadViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var company = ""
    @State private var budget = ""
    @State private var propertyType = ""
    @State private var transactionType = "Lease"
    @State private var status = "Cold"
    @State private var notes = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    
    let propertyTypes = ["Office", "Retail", "Warehouse", "Industrial", "Flex", "Land"]
    let transactionTypes = ["Lease", "Purchase"]
    let statuses = ["Cold", "Warm", "Hot", "Closed"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Lead Information") {
                    TextField("Name *", text: $name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: phone) { newValue in
                            phone = PhoneFormatter.format(newValue)
                        }
                    
                    TextField("Company", text: $company)
                }
                
                Section("Property Details") {
                    Picker("Property Type", selection: $propertyType) {
                        Text("Select type").tag("")
                        ForEach(propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Budget", text: $budget)
                        .keyboardType(.numberPad)
                        .onChange(of: budget) { newValue in
                            budget = Validation.formatBudget(newValue)
                        }
                    
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Lead")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await saveLead()
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSubmitting || !isValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveLead() async {
        isSubmitting = true
        
        let payload = LeadCreatePayload(
            name: name,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            company: company.isEmpty ? nil : company,
            budget: budget.isEmpty ? nil : budget,
            sizeMin: nil,
            sizeMax: nil,
            propertyType: propertyType.isEmpty ? nil : propertyType,
            transactionType: transactionType,
            moveTiming: nil,
            moveStartDate: nil,
            moveEndDate: nil,
            timelineStatus: nil,
            daysUntilMove: nil,
            status: status,
            preferredArea: nil,
            industry: nil,
            leaseTerm: nil,
            notes: notes.isEmpty ? nil : notes,
            followUpOn: nil,
            followUpNotes: nil
        )
        
        do {
            try await viewModel.createLead(payload)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isSubmitting = false
    }
}

