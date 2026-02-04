//
//  ConnectionService.swift
//  Interact_app
//
//  Created by admin73 on 14/01/26.
//

import Foundation

class ConnectionService {
    
    static let shared = ConnectionService()
    var client: SupabaseClient? // Inject this in SceneDelegate
    
    private init() {}
    
    // MARK: - Helpers to get Token
    // ⚠️ REPLACE THIS with your actual AuthManager logic
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "supabase_access_token")
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "supabase_user_id")
    }
    
    // MARK: - Fetch Connections (Smart Fetch)
        // Fetches connections AND the profile details for both sides (sender/receiver)
        func fetchMyConnections(status: String? = nil) async throws -> [Connection] {
            guard let client = client, let token = accessToken, let myId = currentUserId else {
                print("Error: Client, Token, or User ID missing")
                return []
            }
            
            // 1. Construct the Query
            // We use Supabase syntax to "join" the profiles table twice:
            // - Once for the sender_id column (aliased as 'sender')
            // - Once for the receiver_id column (aliased as 'receiver')
            var queryItems = [
                URLQueryItem(name: "select", value: "*,sender:sender_id(id,first_name,last_name,primary_role,avatar_url),receiver:receiver_id(id,first_name,last_name,primary_role,avatar_url)"),
                URLQueryItem(name: "or", value: "(sender_id.eq.\(myId),receiver_id.eq.\(myId))")
            ]
            
            // 2. Apply Optional Status Filter (e.g., "accepted")
            if let specificStatus = status {
                queryItems.append(URLQueryItem(name: "status", value: "eq.\(specificStatus)"))
            }
            
            // 3. Build URL
            var urlComponents = URLComponents(url: client.postgrestURL(for: "connections"), resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = queryItems
            
            // 4. Create Request
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // 5. Execute & Decode
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let errorText = String(data: data, encoding: .utf8) {
                    print("❌ Supabase Error: \(errorText)")
                }
                throw NSError(domain: "ConnectionService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch connections"])
            }
            
            // Decodes into the new 'Connection' struct with nested 'sender' and 'receiver' objects
            return try JSONDecoder().decode([Connection].self, from: data)
        }
    
    
    // MARK: - Fetch Friends Only (Returns [ProfileLite])
            // 🚀 Use this for your Invite List. It handles the logic so your UI is simple.
            func fetchAcceptedFriends() async throws -> [ProfileLite] {
                guard let client = client, let token = accessToken, let myId = currentUserId else { return [] }
                
                // 1. Fetch the Raw Connections (Same as before)
                let queryItems = [
                    URLQueryItem(name: "select", value: "*,sender:sender_id(id,first_name,last_name,primary_role,avatar_url),receiver:receiver_id(id,first_name,last_name,primary_role,avatar_url)"),
                    URLQueryItem(name: "or", value: "(sender_id.eq.\(myId),receiver_id.eq.\(myId))"),
                    URLQueryItem(name: "status", value: "eq.accepted")
                ]
                
                var urlComponents = URLComponents(url: client.postgrestURL(for: "connections"), resolvingAgainstBaseURL: false)!
                urlComponents.queryItems = queryItems
                
                var request = URLRequest(url: urlComponents.url!)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let (data, _) = try await URLSession.shared.data(for: request)
                
                // 2. Decode into Connection objects temporarily
                let connections = try JSONDecoder().decode([Connection].self, from: data)
                
                // 3. 🛡️ THE FILTER: Convert Connections to People (ProfileLite)
                // This explicitly looks for the person who is NOT you.
                let friends: [ProfileLite] = connections.compactMap { connection in
                    
                    // Compare IDs safely (lowercased ensures we don't miss matches due to case)
                    if connection.senderId.uuidString.lowercased() == myId.lowercased() {
                        return connection.receiver // If I am sender, return Friend
                    } else {
                        return connection.sender   // If I am receiver, return Friend
                    }
                }
                
                // 4. Return the clean list of people
                return friends
            }
    
    
    // MARK: - Fetch Pending Requests with Profile Data
        // Returns the custom 'ConnectionRequest' model we defined earlier
        func fetchPendingRequests() async throws -> [ConnectionRequest] {
            guard let client = client, let token = accessToken, let myId = currentUserId else {
                return []
            }
            
            // 1. Construct URL with a "Join" Query
            // We want: The Connection ID + The Sender's Profile Details
            // Supabase Syntax: sender_id(col1, col2...) fetches the related data
            let queryItems = [
                URLQueryItem(name: "select", value: "id,status,sender_id(id,first_name,last_name,primary_role)"),
                URLQueryItem(name: "receiver_id", value: "eq.\(myId)"),
                URLQueryItem(name: "status", value: "eq.pending")
            ]
            
            var urlComponents = URLComponents(url: client.postgrestURL(for: "connections"), resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = queryItems
            
            // 2. Build Request
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            // 3. Execute
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                // Optional: Print error body for debugging if needed
                if let errorText = String(data: data, encoding: .utf8) { print("Supabase Error: \(errorText)") }
                throw NSError(domain: "ConnectionService", code: 0, userInfo: nil)
            }
            
            // 4. Decode into our Composite Model
            return try JSONDecoder().decode([ConnectionRequest].self, from: data)
        }
    
    // MARK: - Send Request
    func sendConnectionRequest(to receiverId: UUID) async throws {
        guard let client = client, let token = accessToken, let myId = currentUserId else { return }
        
        // 1. Prepare Data
        let payload = [
            "sender_id": myId,
            "receiver_id": receiverId.uuidString
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        
        // 2. Use your existing client helper
        let request = client.makePostgrestInsertRequest(
            table: "connections",
            body: bodyData,
            accessToken: token
        )
        
        // 3. Execute
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "ConnectionService", code: httpResponse.statusCode, userInfo: nil)
        }
    }
    
    // MARK: - Accept Request
    func acceptConnectionRequest(connectionId: UUID) async throws {
        guard let client = client, let token = accessToken else { return }
        
        // 1. Prepare Data
        let payload = ["status": "accepted"]
        let bodyData = try JSONSerialization.data(withJSONObject: payload)
        
        // 2. Use your existing client helper (Note: makePostgrestUpdateRequest requires 'id' param logic)
        // Your helper usually expects a userId filter, but we need to filter by connection ID.
        // We have to build this manually or modify the helper slightly.
        // Let's build manually to avoid modifying your client code.
        
        var components = URLComponents(url: client.postgrestURL(for: "connections"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "id", value: "eq.\(connectionId)")]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PATCH"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        // 3. Execute
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "ConnectionService", code: httpResponse.statusCode, userInfo: nil)
        }
    }
    
    // MARK: - Reject Request
        func rejectConnectionRequest(connectionId: UUID) async throws {
            guard let client = client, let token = accessToken else { return }
            
            // 1. Prepare Data: Set status to "rejected"
            let payload = ["status": "rejected"]
            let bodyData = try JSONSerialization.data(withJSONObject: payload)
            
            // 2. Build URL manually with ID filter
            var components = URLComponents(url: client.postgrestURL(for: "connections"), resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "id", value: "eq.\(connectionId)")]
            
            // 3. Build Request
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            request.httpBody = bodyData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")

            // 4. Execute
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw NSError(domain: "ConnectionService", code: httpResponse.statusCode, userInfo: nil)
            }
        }
}
