import SwiftUI

/// Full-screen photo gallery with swipe navigation
/// Allows users to tap property images and swipe through all photos
struct PropertyPhotoGalleryView: View {
    let images: [String] // Array of base64 image strings
    @Binding var isPresented: Bool
    @State private var currentIndex: Int = 0
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Photos with swipe gesture
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageString in
                    GeometryReader { geometry in
                        ZStack {
                            if let image = ImageCache.shared.getImage(base64String: imageString) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .scaleEffect(scale)
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
                                    .onTapGesture(count: 2) {
                                        // Double tap to zoom
                                        withAnimation(.spring(response: 0.3)) {
                                            if scale > 1.0 {
                                                scale = 1.0
                                            } else {
                                                scale = 2.5
                                            }
                                        }
                                    }
                            } else {
                                // Loading placeholder
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
                }
            }
            
            // Top bar with close button
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
}

/// Thumbnail grid view for property images with tap to expand
struct PropertyPhotoGridView: View {
    let images: [String]
    @State private var showGallery = false
    @State private var selectedIndex = 0
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PHOTOS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(0.8)
                
                Spacer()
                
                Text("\(images.count) photo\(images.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageString in
                    Button {
                        selectedIndex = index
                        showGallery = true
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            if let image = ImageCache.shared.getImage(base64String: imageString) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 120)
                                    .overlay(
                                        ProgressView()
                                    )
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
        }
        .fullScreenCover(isPresented: $showGallery) {
            PropertyPhotoGalleryView(images: images, isPresented: $showGallery)
                .onAppear {
                    // Set initial index (not working properly with TabView binding)
                    // TabView will always start at first image
                }
        }
    }
}

