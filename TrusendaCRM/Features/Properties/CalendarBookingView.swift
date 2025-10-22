import SwiftUI
import WebKit

struct CalendarBookingView: View {
    let url: String
    let propertyTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var loadError: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // WebView
                WebViewContainer(url: url, isLoading: $isLoading, loadError: $loadError)
                
                // Loading overlay
                if isLoading && loadError == nil {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.primaryBlue)
                        Text("Loading calendar...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground).opacity(0.95))
                }
                
                // Error state
                if let error = loadError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Couldn't Load Calendar")
                            .font(.title2.bold())
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            // Retry
                            loadError = nil
                            isLoading = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.primaryBlue)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationTitle("Schedule Tour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                            Text("Close")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.primaryBlue)
                    }
                }
            }
        }
    }
}

// MARK: - WebView UIViewRepresentable

struct WebViewContainer: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool
    @Binding var loadError: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load if not already loaded
        if webView.url == nil || webView.url?.absoluteString != url {
            if let url = URL(string: url) {
                print("📄 Loading calendar URL:", url.absoluteString)
                webView.load(URLRequest(url: url))
            } else {
                print("❌ Invalid calendar URL:", url)
                loadError = "Invalid calendar URL"
                isLoading = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, loadError: $loadError)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var loadError: String?
        
        init(isLoading: Binding<Bool>, loadError: Binding<String?>) {
            _isLoading = isLoading
            _loadError = loadError
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("📄 Started loading calendar page...")
            isLoading = true
            loadError = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Calendar page loaded successfully")
            isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Calendar page failed to load:", error.localizedDescription)
            isLoading = false
            loadError = "Failed to load calendar. Please check your connection."
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ Calendar page failed provisional navigation:", error.localizedDescription)
            isLoading = false
            loadError = "Unable to connect to calendar service."
        }
        
        // Handle redirects (important for OAuth flows in calendar services)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print("🔗 Navigation to:", navigationAction.request.url?.absoluteString ?? "unknown")
            decisionHandler(.allow)
        }
    }
}

// MARK: - Preview

struct CalendarBookingView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarBookingView(
            url: "https://calendly.com/example/30min",
            propertyTitle: "Modern Warehouse - 10,000 SF"
        )
    }
}

