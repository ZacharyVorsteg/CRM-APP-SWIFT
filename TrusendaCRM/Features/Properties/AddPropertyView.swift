import SwiftUI
import PhotosUI

struct AddPropertyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: PropertyViewModel
    
    @State private var title = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var propertyType = ""
    @State private var transactionType = "Lease"
    @State private var sizeRange = ""
    @State private var sizeMin = ""
    @State private var sizeMax = ""
    @State private var price = ""
    @State private var budget = ""
    @State private var leaseTerm = ""
    @State private var industry = ""
    @State private var availableDate = ""
    @State private var description = ""
    @State private var features = ""
    @State private var status = "Available"
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var imageDataStrings: [String] = []
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Same options as Lead form (consistency)
    let propertyTypes = ["Warehouse", "Manufacturing", "Land", "Office", "Retail", "Mixed Use", "Industrial", "Flex", "Other"]
    let transactionTypes = ["Lease", "Purchase", "Lease-Purchase", "Other"]
    let statuses = ["Available", "Under Contract", "Leased", "Sold"]
    
    let budgetOptions = [
        "Under $2,000/mo",
        "$2,000 - $5,000/mo",
        "$5,000 - $10,000/mo",
        "$10,000 - $20,000/mo",
        "$20,000 - $50,000/mo",
        "$50,000+/mo",
        "Custom (enter in notes)"
    ]
    
    let sizeRangeOptions = [
        ("0-1000", "Less than 1,000 SF"),
        ("1000-2500", "1,000 - 2,500 SF"),
        ("2500-5000", "2,500 - 5,000 SF"),
        ("5000-10000", "5,000 - 10,000 SF"),
        ("10000-25000", "10,000 - 25,000 SF"),
        ("25000-50000", "25,000 - 50,000 SF"),
        ("50000+", "50,000+ SF")
    ]
    
    let industryOptions = [
        "Automotive & Transportation",
        "Construction & Contracting",
        "Distribution & Logistics",
        "E-commerce & Fulfillment",
        "Food & Beverage Production",
        "Healthcare & Medical",
        "Manufacturing",
        "Professional Services",
        "Retail Operations",
        "Technology & Software",
        "Warehousing & Storage",
        "Wholesale Trade",
        "Other"
    ]
    
    let leaseTermOptions = [
        "Month-to-Month",
        "3-6 Months",
        "1 Year",
        "2 Years",
        "3 Years",
        "5 Years",
        "7-10 Years",
        "10+ Years",
        "Flexible/TBD"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Title - Required
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            TextField("Property Title", text: $title)
                                .font(.body)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            title.isEmpty ? Color.errorRed.opacity(0.3) : Color.successGreen.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                    }
                    
                    // Address - Required
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.primaryBlue)
                                .font(.system(size: 18))
                                .frame(width: 24)
                            TextField("Street Address", text: $address)
                                .font(.body)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            address.isEmpty ? Color.errorRed.opacity(0.3) : Color.successGreen.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                    }
                    
                    // City, State, Zip - All Required
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            TextField("City", text: $city)
                                .font(.body)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                                .frame(width: 10)
                            
                            TextField("ST", text: $state)
                                .font(.body)
                                .frame(maxWidth: 60)
                                .textInputAutocapitalization(.characters)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                                .frame(width: 10)
                            
                            TextField("Zip", text: $zipCode)
                                .font(.body)
                                .frame(maxWidth: 80)
                                .keyboardType(.numberPad)
                            Text("*")
                                .foregroundColor(.errorRed)
                                .font(.title.bold())
                                .frame(width: 10)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            (city.isEmpty || state.isEmpty || !isValidZipCode(zipCode)) 
                                                ? Color.errorRed.opacity(0.3) 
                                                : Color.successGreen.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                        
                        if !isValidZipCode(zipCode) && !zipCode.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text("Please enter a valid 5-digit zip code")
                                    .font(.caption2)
                            }
                            .foregroundColor(.warningOrange)
                        }
                    }
                } header: {
                    Label("PROPERTY LOCATION", systemImage: "location.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                Section {
                    // Property Type - Required
                    HStack {
                        if !propertyType.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                                .font(.system(size: 16))
                        }
                        
                        Picker("Property Type", selection: $propertyType) {
                            Text("Select property type").tag("").foregroundColor(.secondary)
                            ForEach(propertyTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        
                        Text("*")
                            .foregroundColor(propertyType.isEmpty ? .errorRed : .successGreen)
                            .font(.title.bold())
                    }
                    
                    // Transaction Type (defaults to Lease, always has value)
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(transactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Size Range - Required for matching
                    HStack {
                        if !sizeRange.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                                .font(.system(size: 16))
                        }
                        
                        Picker("Size Range (SF)", selection: $sizeRange) {
                            Text("Select size...").tag("")
                            ForEach(sizeRangeOptions, id: \.0) { value, label in
                                Text(label).tag(value)
                            }
                        }
                        .onChange(of: sizeRange) { newValue in
                            if newValue.contains("-") {
                                let parts = newValue.split(separator: "-")
                                sizeMin = String(parts[0])
                                sizeMax = String(parts[1])
                            } else if newValue.contains("+") {
                                sizeMin = newValue.replacingOccurrences(of: "+", with: "")
                                sizeMax = ""
                            }
                        }
                        
                        Text("*")
                            .foregroundColor(sizeRange.isEmpty ? .errorRed : .successGreen)
                            .font(.title.bold())
                    }
                    
                    // Price/Budget - Required for matching
                    HStack {
                        if !budget.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                                .font(.system(size: 16))
                        }
                        
                        Picker("Price Range", selection: $budget) {
                            Text("Select price range...").tag("")
                            ForEach(budgetOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        
                        Text("*")
                            .foregroundColor(budget.isEmpty ? .errorRed : .successGreen)
                            .font(.title.bold())
                    }
                    
                    // Lease Term (optional but recommended)
                    Picker("Lease Term", selection: $leaseTerm) {
                        Text("Select term...").tag("")
                        ForEach(leaseTermOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .tint(.primaryBlue)
                    
                    // Best Suited Industry - Required for matching
                    HStack {
                        if !industry.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                                .font(.system(size: 16))
                        }
                        
                        Picker("Best Suited For", selection: $industry) {
                            Text("Select industry...").tag("")
                            ForEach(industryOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        
                        Text("*")
                            .foregroundColor(industry.isEmpty ? .errorRed : .successGreen)
                            .font(.title.bold())
                    }
                } header: {
                    Label("PROPERTY DETAILS (REQUIRED FOR MATCHING)", systemImage: "building.2.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                } footer: {
                    Text("Complete property details ensure accurate matching with potential leads")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    // Photos picker - Required
                    HStack {
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 6, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(loadedImages.isEmpty ? .errorRed : .successGreen)
                                Text("Add Photos")
                                    .foregroundColor(loadedImages.isEmpty ? .errorRed : .successGreen)
                                Spacer()
                                if !loadedImages.isEmpty {
                                    Text("\(loadedImages.count) selected")
                                        .font(.caption)
                                        .foregroundColor(.successGreen)
                                }
                            }
                        }
                        .onChange(of: selectedPhotos) { newItems in
                            Task {
                                await loadPhotos(from: newItems)
                            }
                        }
                        
                        Text("*")
                            .foregroundColor(.errorRed)
                            .font(.title.bold())
                    }
                    
                    // Photo preview
                    if !loadedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            Button {
                                                loadedImages.remove(at: index)
                                                imageDataStrings.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                            }
                                            .frame(width: 24, height: 24)
                                            .offset(x: -4, y: 4),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                        }
                    }
                    
                    // Description
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Property description, key highlights, recent improvements...")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                    
                    // Features
                    TextEditor(text: $features)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if features.isEmpty {
                                    Text("Key features: Loading docks, office space, parking, etc.")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                } header: {
                    Label("DESCRIPTION & MEDIA (PHOTO REQUIRED)", systemImage: "text.alignleft")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                } footer: {
                    Text("At least one property photo is required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .tint(.primaryBlue)
                } header: {
                    Label("AVAILABILITY", systemImage: "calendar.circle.fill")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundColor(.primaryBlue)
                        .textCase(.uppercase)
                        .tracking(1.0)
                }
                
                // Submit button
                Section {
                    Button {
                        Task {
                            await submitProperty()
                        }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Adding Property...")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Property")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .disabled(!isFormValid || isSubmitting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Validation errors summary
                    if !isFormValid && hasInteractedWithForm {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Please complete required fields:")
                                .font(.caption.bold())
                                .foregroundColor(.errorRed)
                            
                            ForEach(validationErrors, id: \.self) { error in
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 10))
                                    Text(error)
                                        .font(.caption2)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.errorRed.opacity(0.1))
                        )
                        .listRowBackground(Color.clear)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !address.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        isValidZipCode(zipCode) &&
        !propertyType.isEmpty &&
        !sizeRange.isEmpty &&
        !budget.isEmpty &&
        !industry.isEmpty &&
        !loadedImages.isEmpty
    }
    
    private var hasInteractedWithForm: Bool {
        // Show errors only after user has started filling the form
        !title.isEmpty || !address.isEmpty || !city.isEmpty
    }
    
    private var validationErrors: [String] {
        var errors: [String] = []
        
        if title.isEmpty { errors.append("Property title") }
        if address.isEmpty { errors.append("Street address") }
        if city.isEmpty { errors.append("City") }
        if state.isEmpty { errors.append("State") }
        if zipCode.isEmpty { errors.append("Zip code") }
        else if !isValidZipCode(zipCode) { errors.append("Valid zip code (5 digits)") }
        if propertyType.isEmpty { errors.append("Property type") }
        if sizeRange.isEmpty { errors.append("Size range") }
        if budget.isEmpty { errors.append("Price range") }
        if industry.isEmpty { errors.append("Best suited industry") }
        if loadedImages.isEmpty { errors.append("At least one property photo") }
        
        return errors
    }
    
    private func isValidZipCode(_ zip: String) -> Bool {
        // US zip code: 5 digits
        let zipRegex = "^[0-9]{5}$"
        let zipPredicate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        return zipPredicate.evaluate(with: zip)
    }
    
    private func submitProperty() async {
        // Final validation before submit
        guard isFormValid else {
            errorMessage = "Please complete all required fields"
            showError = true
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        isSubmitting = true
        
        // All required fields are guaranteed to be filled by validation
        let payload = PropertyCreatePayload(
            title: title,
            address: address, // Required
            city: city, // Required
            state: state.uppercased(), // Required - uppercase for consistency
            zipCode: zipCode, // Required and validated
            propertyType: propertyType, // Required
            transactionType: transactionType, // Required (defaults to Lease)
            size: nil,
            sizeMin: sizeMin, // Required (set from sizeRange)
            sizeMax: sizeMax.isEmpty ? nil : sizeMax, // May be empty for "50000+"
            price: price.isEmpty ? nil : price,
            budget: budget, // Required
            leaseTerm: leaseTerm.isEmpty ? nil : leaseTerm,
            industry: industry, // Required
            availableDate: availableDate.isEmpty ? nil : availableDate,
            images: imageDataStrings.isEmpty ? nil : imageDataStrings,
            primaryImage: imageDataStrings.first,
            description: description.isEmpty ? nil : description,
            features: features.isEmpty ? nil : features,
            status: status
        )
        
        do {
            try await viewModel.addProperty(payload)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                dismiss()
            }
        } catch {
            print("❌ Failed to add property:", error)
            errorMessage = error.localizedDescription
            showError = true
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        isSubmitting = false
    }
    
    // Load and convert photos to base64 for storage
    private func loadPhotos(from items: [PhotosPickerItem]) async {
        loadedImages.removeAll()
        imageDataStrings.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                // Resize image to reasonable size (max 800px width)
                let resizedImage = resizeImage(image: image, maxWidth: 800)
                loadedImages.append(resizedImage)
                
                // Convert to base64 for storage
                if let jpegData = resizedImage.jpegData(compressionQuality: 0.7) {
                    let base64String = "data:image/jpeg;base64," + jpegData.base64EncodedString()
                    imageDataStrings.append(base64String)
                    print("📸 Image converted: \(jpegData.count / 1024)KB")
                }
            }
        }
        
        print("✅ Loaded \(loadedImages.count) photos")
    }
    
    // Resize image to max width while maintaining aspect ratio
    private func resizeImage(image: UIImage, maxWidth: CGFloat) -> UIImage {
        guard image.size.width > maxWidth else { return image }
        
        let ratio = maxWidth / image.size.width
        let newHeight = image.size.height * ratio
        let newSize = CGSize(width: maxWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

