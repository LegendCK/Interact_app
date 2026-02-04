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

    fileprivate func authURL(path: String) -> URL {
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
    
    public func makeGetProfileByQRTokenRequest(token: String) -> URLRequest {
        var components = URLComponents(url: postgrestURL(for: "profiles"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "qr_public_token", value: "eq.\(token)"),
            URLQueryItem(name: "select", value: "*")
        ]

        let url = components.url!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
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

// MARK: - Storage helpers
public extension SupabaseClient {
    
    /// Build the Storage upload URL for a specific bucket and file path
    /// POST /storage/v1/object/<bucket>/<filePath>
    func storageUploadURL(bucket: String, filePath: String) -> URL {
        return baseURL
            .appendingPathComponent("/storage/v1/object")
            .appendingPathComponent(bucket)
            .appendingPathComponent(filePath)
    }
    
    /// Build the public URL for an uploaded file
    /// https://<project>.supabase.co/storage/v1/object/public/<bucket>/<filePath>
    func storagePublicURL(bucket: String, filePath: String) -> URL {
        return baseURL
            .appendingPathComponent("/storage/v1/object/public")
            .appendingPathComponent(bucket)
            .appendingPathComponent(filePath)
    }
    
    /// Create a URLRequest for uploading a file to Supabase Storage
    /// - Parameters:
    ///   - bucket: bucket name (e.g. "profile-photos")
    ///   - filePath: path in bucket (e.g. "user_id/avatar.jpg")
    ///   - fileData: image data to upload
    ///   - contentType: MIME type (e.g. "image/jpeg")
    ///   - accessToken: user's access token
    ///   - upsert: if true, will overwrite existing file
    func makeStorageUploadRequest(
        bucket: String,
        filePath: String,
        fileData: Data,
        contentType: String,
        accessToken: String,
        upsert: Bool = true
    ) -> URLRequest {
        let url = storageUploadURL(bucket: bucket, filePath: filePath)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = fileData
        req.setValue(contentType, forHTTPHeaderField: "Content-Type")
        req.setValue(anonKey, forHTTPHeaderField: "apikey")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if upsert {
            // x-upsert header tells Supabase to overwrite if file exists
            req.setValue("true", forHTTPHeaderField: "x-upsert")
        }
        
        return req
    }
}
