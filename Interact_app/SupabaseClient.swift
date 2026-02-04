//
//  SupabaseClient.swift
//  Interact_app
//
//  Created by admin56 on 10/12/25.
//

import Foundation

public struct SupabaseClient {
    public let baseURL: URL   // e.g. https://<project>.supabase.co
    public let anonKey: String

    public init(config: SupabaseConfig) {
        self.baseURL = config.url
        self.anonKey = config.anonKey
    }

    public func authURL(path: String) -> URL {
        // Supabase auth endpoints are under /auth/v1/...
        return baseURL.appendingPathComponent("/auth/v1").appendingPathComponent(path)
    }

    fileprivate func makeRequest(url: URL, method: String = "POST", body: Data? = nil, additionalHeaders: [String: String] = [:]) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // IMPORTANT: send the anon key raw in the 'apikey' header (no "Bearer " prefix)
        req.setValue(anonKey, forHTTPHeaderField: "apikey")

        // Optional but common: also send Authorization header with Bearer <anonKey>
        req.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        for (k, v) in additionalHeaders { req.setValue(v, forHTTPHeaderField: k) }
        req.httpBody = body
        return req
    }

    // MARK: - Auth endpoints helpers (used by AuthManager)

    // signup (email/password)
    public func makeSignUpRequest(email: String, password: String) -> URLRequest {
        let url = authURL(path: "signup")
        let payload = ["email": email, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])
        return makeRequest(url: url, method: "POST", body: body)
    }

    // sign in - using the token endpoint via grant_type=password
    // POST /auth/v1/token?grant_type=password
    public func makeSignInRequest(email: String, password: String) -> URLRequest {
        var components = URLComponents(url: authURL(path: "token"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "grant_type", value: "password")]
        let url = components.url!
        let payload = ["email": email, "password": password]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])
        return makeRequest(url: url, method: "POST", body: body)
    }

    // password recovery
    // POST /auth/v1/recover
    public func makeRecoverRequest(email: String) -> URLRequest {
        let url = authURL(path: "recover")
        let payload = ["email": email]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])
        return makeRequest(url: url, method: "POST", body: body)
    }

    // resend verification email
    // POST /auth/v1/resend
    public func makeResendVerificationRequest(email: String) -> URLRequest {
        let url = authURL(path: "resend")
        let payload: [String: Any] = [
            "type": "signup",
            "email": email
        ]
        let body = try? JSONSerialization.data(withJSONObject: payload, options: [])
        return makeRequest(url: url, method: "POST", body: body)
    }

    // sign out: there is a server-side logout but client-side we will remove tokens. If you need server revoke, call /logout with access token as Authorization
    public func makeSignOutRequest(accessToken: String) -> URLRequest {
        let url = authURL(path: "logout")
        var req = makeRequest(url: url, method: "POST")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return req
    }
}

// MARK: - OAuth helpers
public extension SupabaseClient {
    /// Build the /authorize URL for a given provider and redirect_to (deep link)
    /// Example final URL:
    /// https://<project>.supabase.co/auth/v1/authorize?provider=google&redirect_to=interact://auth/callback
    func makeAuthorizeURL(provider: String, redirectTo: String) -> URL? {
        guard var comps = URLComponents(url: baseURL.appendingPathComponent("/auth/v1/authorize"), resolvingAgainstBaseURL: false) else {
            return nil
        }
        var items: [URLQueryItem] = []
        items.append(URLQueryItem(name: "provider", value: provider))
        items.append(URLQueryItem(name: "redirect_to", value: redirectTo))
        comps.queryItems = items
        return comps.url
    }
}

// MARK: - PostgREST helpers
public extension SupabaseClient {
    /// Build the PostgREST base URL for a table (/rest/v1/<table>)
    func postgrestURL(for table: String) -> URL {
        return baseURL.appendingPathComponent("/rest/v1").appendingPathComponent(table)
    }

    /// Create a URLRequest for inserting JSON into a PostgREST table.
    /// - Parameters:
    ///   - table: table name (e.g. "profiles")
    ///   - body: JSON Data for the row to insert
    ///   - accessToken: the user's access token (must be provided)
    func makePostgrestInsertRequest(table: String, body: Data, accessToken: String) -> URLRequest {
        let url = postgrestURL(for: table)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // required headers for Supabase PostgREST when authenticating with user token
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        // Ask PostgREST to return the inserted record
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        return req
    }

    /// Create a URLRequest for updating a specific row in PostgREST table by user ID
    /// PATCH /rest/v1/profiles?id=eq.<userId>
    /// - Parameters:
    ///   - table: table name (e.g. "profiles")
    ///   - userId: the user's ID to filter by
    ///   - body: JSON Data with fields to update
    ///   - accessToken: the user's access token
    func makePostgrestUpdateRequest(table: String, userId: String, body: Data, accessToken: String) -> URLRequest {
        var components = URLComponents(url: postgrestURL(for: table), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "id", value: "eq.\(userId)")]
        
        let url = components.url!
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("return=representation", forHTTPHeaderField: "Prefer")
        return req
    }

    /// Create a URLRequest for fetching a profile by user ID
    /// GET /rest/v1/profiles?id=eq.<userId>&select=*
    /// - Parameters:
    ///   - userId: the user's ID
    ///   - accessToken: the user's access token
    func makeGetProfileRequest(userId: String, accessToken: String) -> URLRequest {
        var components = URLComponents(url: postgrestURL(for: "profiles"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "id", value: "eq.\(userId)"),
            URLQueryItem(name: "select", value: "*")
        ]
        
        let url = components.url!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return req
    }

    /// Create a URLRequest for updating profile (used for role update)
    /// PATCH /rest/v1/profiles?id=eq.<userId>
    func makeUpdateProfileRequest(userId: String, body: Data, accessToken: String) -> URLRequest {
        return makePostgrestUpdateRequest(table: "profiles", userId: userId, body: body, accessToken: accessToken)
    }
}

// MARK: - GET /auth/v1/user helper
public extension SupabaseClient {
    /// Build GET /auth/v1/user request using user's access token
    func makeGetUserRequest(accessToken: String) -> URLRequest {
        let url = authURL(path: "user") // /auth/v1/user
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return req
    }
}


// MARK: - Universal RPC Helper
public extension SupabaseClient {

    /// Universal RPC Caller: Handles Strings, UUIDs, Bools, or Custom Structs
    func callRPC<T: Decodable>(
        name: String,
        params: [String: Any],
        accessToken: String? = nil
    ) async throws -> T {
        
        let url = postgrestURL(for: "rpc/\(name)")
        let body = try? JSONSerialization.data(withJSONObject: params)
        
        // 1. Prepare Headers
        var headers = ["Content-Type": "application/json"]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        // 2. Make Request
        // Ensure your makeRequest helper handles 'additionalHeaders'.
        // If not, use request.setValue(...) manually here.
        let request = makeRequest(url: url, method: "POST", body: body, additionalHeaders: headers)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 3. Validation Step 1: Ensure it is an HTTP Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }
        
        // 4. Validation Step 2: Check Status Code
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown DB Error"
            
            // Handle your specific "Already in Team" check
            if errorText.contains("User already belongs to a team") {
                throw NSError(domain: "TeamService", code: 409, userInfo: [NSLocalizedDescriptionKey: "You have already joined a team for this event."])
            }
            
            // ✅ NOW 'httpResponse' is in scope, so this works:
            throw NSError(domain: "SupabaseClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        // 5. Universal Decoding
        do {
            // This magic line converts the JSON to whatever Type (T) you asked for
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("⚠️ Decoding Error for RPC '\(name)': \(error)")
            
            // Fallback: If T is String, maybe the DB returned raw text?
            if T.self == String.self, let rawString = String(data: data, encoding: .utf8) as? T {
                return rawString
            }
            throw error
        }
    }
}


// MARK: - Generic Fetch Extension
public extension SupabaseClient {
    
    /// Generic helper to fetch data from any table
    /// - Parameters:
    ///   - table: The table name (e.g. "events")
    ///   - queryItems: The URLQueryItems for filtering/sorting
    /// - Returns: An array of the requested type [T]
    func fetch<T: Decodable>(from table: String, queryItems: [URLQueryItem]) async throws -> [T] {
        
        // 1. Build URL
        var components = URLComponents(url: postgrestURL(for: table), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            throw NSError(domain: "SupabaseClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        // 2. Create Request using your existing helper
        // We manually add the Accept header for JSON
        var request = makeRequest(url: finalURL, method: "GET")
        
        // 3. Network Call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 4. Validate
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("❌ Fetch Error on \(table): \(errorText)")
            throw NSError(domain: "SupabaseClient", code: 1, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        // 5. Decode
        do {
            let decoder = JSONDecoder()
            // Configure dates to handle standard ISO8601 (which Supabase uses)
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // Supabase sometimes sends fractional seconds, so .iso8601 strategy is safest
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode([T].self, from: data)
        } catch {
            print("❌ Decoding Error for \(table): \(error)")
            throw error
        }
    }
}
