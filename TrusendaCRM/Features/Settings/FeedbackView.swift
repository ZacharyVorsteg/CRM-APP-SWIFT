import SwiftUI

/// Premium feedback submission matching cloud website
/// Allows users to report bugs, request features, and share feedback
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthManager
    
    @State private var feedbackType: FeedbackCategory = .none
    @State private var feedbackMessage = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    
    enum FeedbackCategory: String, CaseIterable {
        case none = ""
        case bug = "bug"
        case feature = "feature"
        case improvement = "improvement"
        case question = "question"
        case general = "general"
        
        var displayName: String {
            switch self {
            case .none: return "Select a category..."
            case .bug: return "🐛 Bug Report - Something isn't working"
            case .feature: return "✨ Feature Request - I'd like to see..."
            case .improvement: return "📈 Improvement - Make this better"
            case .question: return "❓ Question - How do I...?"
            case .general: return "💭 General Feedback"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "questionmark.circle"
            case .bug: return "ladybug.fill"
            case .feature: return "sparkles"
            case .improvement: return "chart.line.uptrend.xyaxis"
            case .question: return "questionmark.circle.fill"
            case .general: return "bubble.left.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .none: return .secondary
            case .bug: return .errorRed
            case .feature: return .primaryBlue
            case .improvement: return .successGreen
            case .question: return .warningOrange
            case .general: return .accentTeal
            }
        }
    }
    
    var isValid: Bool {
        feedbackType != .none && !feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Premium header card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.primaryBlue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Send Feedback")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Help us improve Trusenda!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text("Share bugs, feature requests, or general feedback. We read every submission.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.top, 8)
                    
                    // Category picker
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("What is this regarding?")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: feedbackType.icon)
                                .foregroundColor(feedbackType.color)
                        }
                        
                        Menu {
                            ForEach(FeedbackCategory.allCases.dropFirst(), id: \.self) { category in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        feedbackType = category
                                    }
                                } label: {
                                    Label(category.displayName, systemImage: category.icon)
                                }
                            }
                        } label: {
                            HStack {
                                Text(feedbackType.displayName)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(feedbackType == .none ? .secondary : .primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: Color.black.opacity(isTextFieldFocused ? 0 : 0.04), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(feedbackType != .none ? feedbackType.color.opacity(0.3) : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Message field
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Your Feedback")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "pencil")
                                .foregroundColor(.primaryBlue)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if feedbackMessage.isEmpty {
                                Text("Tell us what's on your mind...\n\nBe specific and detailed to help us understand your feedback better.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.top, 16)
                                    .padding(.leading, 16)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $feedbackMessage)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 180)
                                .padding(12)
                                .focused($isTextFieldFocused)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(isTextFieldFocused ? 0.08 : 0.04), radius: isTextFieldFocused ? 8 : 4, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isTextFieldFocused ? Color.primaryBlue : Color.clear, lineWidth: 2)
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                        
                        // Character counter
                        HStack {
                            Spacer()
                            Text("\(feedbackMessage.count) characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Submit button
                    Button {
                        Task {
                            await submitFeedback()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Sending...")
                            } else if showSuccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Sent Successfully!")
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                                Text("Send Feedback")
                            }
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isValid ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    showSuccess 
                                        ? LinearGradient(colors: [.successGreen, Color(red: 0.2, green: 0.65, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : isValid
                                            ? LinearGradient(colors: [.primaryBlue, Color(red: 0, green: 0.35, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color(UIColor.systemGray5), Color(UIColor.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: isValid ? Color.primaryBlue.opacity(0.3) : Color.clear, radius: isValid ? 12 : 0, x: 0, y: isValid ? 6 : 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showSuccess ? Color.successGreen.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                    }
                    .disabled(!isValid || isSubmitting || showSuccess)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Help text
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.accentTeal)
                            Text("Your feedback helps us build a better CRM")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("We typically respond within 24-48 hours. For urgent issues, email support@trusenda.com")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentTeal.opacity(0.08))
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
            .background(colorScheme == .dark ? Color.backgroundDark : Color.backgroundLight)
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(showSuccess ? "Close" : "Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
            .alert("Error Sending Feedback", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
                Button("Email Support") {
                    if let url = URL(string: "mailto:support@trusenda.com?subject=Feedback%20Submission%20Failed") {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func submitFeedback() async {
        guard isValid, let _ = authManager.currentUser?.email else { return }
        
        isSubmitting = true
        
        do {
            print("📤 Submitting feedback: \(feedbackType.rawValue)")
            
            // Get valid token
            guard let token = try? await authManager.getValidToken() else {
                throw FeedbackError.unauthorized
            }
            
            // Prepare request
            guard let url = URL(string: "https://trusenda.com/.netlify/functions/submit-feedback") else {
                throw FeedbackError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload = [
                "feedbackType": feedbackType.rawValue,
                "message": feedbackMessage
            ]
            request.httpBody = try JSONEncoder().encode(payload)
            
            // Submit feedback
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FeedbackError.networkError
            }
            
            if httpResponse.statusCode == 200 {
                print("✅ Feedback sent successfully!")
                
                // Success state
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showSuccess = true
                }
                
                // Success haptic
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Clear form
                feedbackMessage = ""
                feedbackType = .none
                
                // Auto-dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    dismiss()
                }
                
            } else {
                let errorData = try? JSONDecoder().decode([String: String].self, from: data)
                throw FeedbackError.serverError(errorData?["error"] ?? "Unknown error")
            }
            
        } catch {
            print("❌ Feedback submission error: \(error)")
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            // Show error
            if let feedbackError = error as? FeedbackError {
                errorMessage = feedbackError.userMessage
            } else {
                errorMessage = "Unable to send feedback. Please try again or email support@trusenda.com"
            }
            showError = true
        }
        
        isSubmitting = false
    }
}

// MARK: - Feedback Error Types
enum FeedbackError: LocalizedError {
    case unauthorized
    case invalidURL
    case networkError
    case serverError(String)
    
    var userMessage: String {
        switch self {
        case .unauthorized:
            return "Please log in to submit feedback"
        case .invalidURL:
            return "Invalid feedback endpoint. Please contact support."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - Preview
#Preview {
    FeedbackView()
        .environmentObject(AuthManager.shared)
}

