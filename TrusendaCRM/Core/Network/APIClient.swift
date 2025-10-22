import Foundation

/// Core HTTP client for all API requests
class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        // Output formatting for debugging
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    
    // MARK: - GET Request
    func get<T: Decodable>(
        endpoint: Endpoint,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
        }
        
        return try await performRequest(request)
    }
    
    // MARK: - POST Request
    func post<T: Decodable, Body: Encodable>(
        endpoint: Endpoint,
        body: Body,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try encoder.encode(body)
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
        }
        
        return try await performRequest(request)
    }
    
    // MARK: - POST Request (no response)
    func post<Body: Encodable>(
        endpoint: Endpoint,
        body: Body,
        requiresAuth: Bool = true
    ) async throws {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try encoder.encode(body)
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
        }
        
        let _: SuccessResponse = try await performRequest(request)
    }
    
    // MARK: - PUT Request
    func put<T: Decodable, Body: Encodable>(
        endpoint: Endpoint,
        body: Body,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try encoder.encode(body)
        
        #if DEBUG
        // Debug logging only in debug builds
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("📤 PUT \(url)")
            print("📦 Body: \(bodyString)")
        }
        #endif
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
            #if DEBUG
            // Log that auth header was added (not the token itself for security)
            print("🔐 Authorization header added")
            #endif
        }
        
        return try await performRequest(request)
    }
    
    // MARK: - DELETE Request
    func delete(
        endpoint: Endpoint,
        requiresAuth: Bool = true
    ) async throws {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
        }
        
        // Backend returns { ok: true } for delete operations
        struct DeleteResponse: Codable {
            let ok: Bool
        }
        
        let _: DeleteResponse = try await performRequest(request)
    }
    
    // MARK: - PATCH Request
    func patch<T: Decodable, Body: Encodable>(
        endpoint: Endpoint,
        body: Body,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try encoder.encode(body)
        
        #if DEBUG
        // Debug logging only in debug builds
        if let bodyString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
            print("📤 PATCH \(url)")
            print("📦 Body: \(bodyString)")
        }
        #endif
        
        if requiresAuth {
            try await addAuthHeader(to: &request)
            #if DEBUG
            // Log that auth header was added (not the token itself for security)
            print("🔐 Authorization header added")
            #endif
        }
        
        return try await performRequest(request)
    }
    
    // MARK: - Perform Request
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                do {
                    #if DEBUG
                    // Log the raw response for debugging (only in debug builds)
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📨 Raw response: \(responseString)")
                    }
                    #endif
                    
                    let decoded = try decoder.decode(T.self, from: data)
                    return decoded
                } catch {
                    #if DEBUG
                    print("❌ Decoding error:", error)
                    print("Response data:", String(data: data, encoding: .utf8) ?? "nil")
                    #endif
                    throw NetworkError.decodingError(error)
                }
                
            case 401:
                // Unauthorized - token expired
                throw NetworkError.unauthorized
                
            case 403:
                // Forbidden - account deleted or blocked
                let errorMsg = try? decoder.decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(403, errorMsg?.error)
                
            case 400...499:
                // Client error
                let errorMsg = try? decoder.decode(ErrorResponse.self, from: data)
                let errorMessage = errorMsg?.error ?? String(data: data, encoding: .utf8)
                #if DEBUG
                print("⚠️ Client error \(httpResponse.statusCode): \(errorMessage ?? "Unknown")")
                #endif
                throw NetworkError.serverError(httpResponse.statusCode, errorMsg?.error)
                
            case 500...599:
                // Server error
                let errorMsg = try? decoder.decode(ErrorResponse.self, from: data)
                throw NetworkError.serverError(httpResponse.statusCode, errorMsg?.error)
                
            default:
                throw NetworkError.serverError(httpResponse.statusCode, nil)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeout
            }
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Auth Header
    private func addAuthHeader(to request: inout URLRequest) async throws {
        // Get valid token (will refresh if needed)
        let token = try await AuthManager.shared.getValidToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

