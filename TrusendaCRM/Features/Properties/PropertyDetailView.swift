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
    @State private var showShareSheet = false
    @State private var matches: [LeadPropertyMatch] = []
    @State private var showPhotoGallery = false
    @State private var selectedPhotoIndex = 0
    
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
                    
                    // Photo Gallery (if images exist) - Tap to expand fullscreen
                    if let images = property.images, !images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(images.enumerated()), id: \.offset) { index, imageString in
                                    Button {
                                        selectedPhotoIndex = index
                                        showPhotoGallery = true
                                        
                                        // Haptic feedback
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                    } label: {
                                        ZStack(alignment: .topTrailing) {
                                            if let image = loadBase64Image(imageString) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 300, height: 200)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                            }
                                            
                                            // Expand icon overlay
                                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(
                                                    Circle()
                                                        .fill(Color.black.opacity(0.6))
                                                )
                                                .padding(8)
                                        }
                                    }
                                    .buttonStyle(.plain)
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
                    
                    // Matching Leads Section - Enhanced with tap-to-expand
                    if !matches.isEmpty {
                        Button {
                            showMatchesSheet = true
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.successGreen)
                                        Text("MATCHED LEADS")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .tracking(0.8)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 6) {
                                        Text("\(matches.count)")
                                            .font(.caption.bold())
                                            .foregroundColor(.successGreen)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.successGreen)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.successGreen.opacity(0.15))
                                    .cornerRadius(8)
                                }
                                
                                // Top 3 matches preview
                                VStack(spacing: 8) {
                                    ForEach(matches.prefix(3)) { match in
                                        HStack(spacing: 12) {
                                            // Avatar
                                            ZStack {
                                                Circle()
                                                    .fill(Color.primaryBlue.opacity(0.12))
                                                    .frame(width: 36, height: 36)
                                                Text(match.lead.name.prefix(1).uppercased())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.primaryBlue)
                                            }
                                            
                                            // Info
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(match.lead.name)
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(.primary)
                                                
                                                if let company = match.lead.company {
                                                    Text(company)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(.primary.opacity(0.8))
                                                }
                                                
                                                // First match reason
                                                if let firstReason = match.matchReasons.first {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.successGreen)
                                                        Text(firstReason)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .padding(.top, 2)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // Match score
                                            Text("\(match.matchScore)%")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(match.matchQuality == .excellent ? .successGreen : .primaryBlue)
                                        }
                                        .padding(.vertical, 6)
                                        
                                        if match.id != matches.prefix(3).last?.id {
                                            Divider()
                                        }
                                    }
                                }
                                
                                // Tap to view all hint
                                if matches.count > 0 {
                                    HStack {
                                        Spacer()
                                        Text("Tap to view details, match reasons, and send")
                                            .font(.system(size: 11))
                                            .foregroundColor(.primaryBlue)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.primaryBlue)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(16)
                        }
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
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit Property", systemImage: "pencil")
                        }
                        
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share Property", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete Property", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
            .alert("Delete Property?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteProperty()
                    }
                }
            } message: {
                Text("Are you sure you want to delete \"\(property.title)\"? This cannot be undone.")
            }
            .sheet(isPresented: $showEditSheet) {
                EditPropertyView(property: property)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showMatchesSheet) {
                PropertyMatchesSheet(matches: matches, property: property)
                    .environmentObject(leadViewModel)
            }
            .sheet(isPresented: $showShareSheet) {
                PropertyShareSheet(property: property, matches: matches)
            }
            .fullScreenCover(isPresented: $showPhotoGallery) {
                if let images = property.images, !images.isEmpty {
                    FullscreenPhotoGalleryView(
                        images: images,
                        currentIndex: $selectedPhotoIndex,
                        isPresented: $showPhotoGallery
                    )
                }
            }
            .onAppear {
                // Calculate matches on appear
                matches = viewModel.calculateMatches(for: property, with: leadViewModel.leads)
                print("🎯 Calculated \(matches.count) matches for \(property.title)")
            }
        }
    }
    
    private func deleteProperty() async {
        do {
            try await viewModel.deleteProperty(id: property.id)
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            dismiss()
        } catch {
            print("❌ Failed to delete property:", error)
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
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

// MARK: - Fullscreen Photo Gallery
struct FullscreenPhotoGalleryView: View {
    let images: [String]
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Photo viewer with swipe
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageString in
                    GeometryReader { geometry in
                        ZStack {
                            if let image = loadBase64Image(imageString) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .scaleEffect(scale)
                                    .offset(offset)
                                    .gesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                // Prevent division by zero / NaN
                                                guard lastScale > 0 else {
                                                    lastScale = 1.0
                                                    return
                                                }
                                                let delta = value / lastScale
                                                lastScale = value
                                                scale *= delta
                                            }
                                            .onEnded { _ in
                                                lastScale = 1.0
                                                // Reset to 1.0 if zoomed out too far
                                                if scale < 1.0 {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        scale = 1.0
                                                        offset = .zero
                                                    }
                                                }
                                                // Limit max zoom
                                                if scale > 4.0 {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        scale = 4.0
                                                    }
                                                }
                                            }
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                // Only allow pan when zoomed in
                                                if scale > 1.0 {
                                                    offset = CGSize(
                                                        width: lastOffset.width + value.translation.width,
                                                        height: lastOffset.height + value.translation.height
                                                    )
                                                }
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                                // Reset if zoomed out
                                                if scale <= 1.0 {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        offset = .zero
                                                        lastOffset = .zero
                                                    }
                                                }
                                            }
                                    )
                                    .onTapGesture(count: 2) {
                                        // Double tap to zoom
                                        withAnimation(.spring(response: 0.3)) {
                                            if scale > 1.0 {
                                                scale = 1.0
                                                offset = .zero
                                                lastOffset = .zero
                                            } else {
                                                scale = 2.5
                                            }
                                        }
                                    }
                            } else {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentIndex) { _ in
                // Reset zoom when swiping to next photo
                withAnimation(.spring(response: 0.3)) {
                    scale = 1.0
                    offset = .zero
                    lastOffset = .zero
                }
            }
            
            // Top bar with close button and counter
            VStack {
                HStack {
                    // Close button
                    Button {
                        isPresented = false
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Photo counter
                    Text("\(currentIndex + 1) of \(images.count)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                        )
                }
                .padding()
                
                Spacer()
                
                // Bottom navigation dots (if more than 1 image)
                if images.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                                .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .statusBar(hidden: true)
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

