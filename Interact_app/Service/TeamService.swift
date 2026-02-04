//
//  TeamService.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import Foundation

class TeamService {
    
    static let shared = TeamService()
    var client: SupabaseClient? // Injected from SceneDelegate
    
    private init() {}
    
    // MARK: - Helpers
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "supabase_access_token")
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "supabase_user_id")
    }
    
    
    // MARK: - 1. Create New Team (Updated)
    // Returns the UUID of the newly created team
    func createTeam(eventID: UUID, name: String) async throws -> UUID {
        guard let client = client, let token = accessToken, let myId = currentUserId else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        
        // 1. Prepare RPC Parameters
        // These keys must match the argument names in your SQL function exactly
        let params: [String: Any] = [
            "p_event_id": eventID.uuidString,
            "p_team_name": name,
            "p_user_id": myId
        ]
        
        let bodyData = try JSONSerialization.data(withJSONObject: params)
        
        // 2. Point to the RPC URL
        // Note: We use "rpc/create_new_team" instead of "teams"
        var components = URLComponents(url: client.postgrestURL(for: "rpc/create_new_team"), resolvingAgainstBaseURL: false)!
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        // 3. Add Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 4. Execute Request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Handle Errors
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let rawError = String(data: data, encoding: .utf8) ?? "Unknown DB Error"
            
            // Check for our specific custom error message from the SQL function
            if rawError.contains("User already belongs to a team") {
                throw NSError(domain: "TeamService", code: 409, userInfo: [NSLocalizedDescriptionKey: "You have already joined a team for this event."])
            }
            
            throw NSError(domain: "Supabase", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "DB Error: \(rawError)"])
        }
        
        // 6. Decode Response (The RPC returns a single UUID string, e.g. "uuid-string")
        let rawString = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "") ?? ""
        
        guard let newTeamID = UUID(uuidString: rawString) else {
            throw NSError(domain: "Supabase", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID returned from server."])
        }
        
        print("✅ Team Created via RPC: \(name) (ID: \(newTeamID))")
        
        return newTeamID
    }
    
    // MARK: - Invite Members to Existing Team
    // Call this from the NEXT modal
    // MARK: - Invite Members (With Better Error Handling)
    func inviteMembers(teamID: UUID, userIds: [UUID]) async throws {
        guard let client = client, let token = accessToken else { return }
        guard !userIds.isEmpty else { return }
        
        var membersToAdd: [[String: Any]] = []
        
        for userId in userIds {
            membersToAdd.append([
                "team_id": teamID.uuidString,
                "user_id": userId.uuidString,
                "status": "pending",
                "role": "member"
            ])
        }
        
        let bodyData = try JSONSerialization.data(withJSONObject: membersToAdd)
        
        var request = URLRequest(url: client.postgrestURL(for: "team_members"))
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Optional: Keep this if you want to silence duplicates,
        // BUT remove it temporarily if you want to see the error explicitly.
        // request.setValue("resolution=ignore-duplicates", forHTTPHeaderField: "Prefer")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            
            // 👇 1. Decode the Error Body
            let rawError = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("🔴 Supabase Error Body: \(rawError)") // Check your Console for this!
            
            // 👇 2. Try to get a clean message (Supabase usually returns { "message": "..." })
            var errorMessage = "Failed to send invites"
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                errorMessage = msg
            }
            
            // 👇 3. Throw the detailed error
            throw NSError(domain: "TeamService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "DB Error (\(httpResponse.statusCode)): \(errorMessage)"])
        }
        
        print("✅ Invites sent successfully")
    }
    
    // MARK: - 2. Fetch Pending Invites
    // In TeamService.swift
    
    func fetchPendingInvites() async throws -> [TeamInviteDisplay] {
        guard let client = client, let token = accessToken, let myId = currentUserId else { return [] }
        
        // ✅ FIX: Use '!fk_teams_leader' to tell Supabase exactly which relationship to use
        let queryString = "status,team:teams(id,name,leader:profiles!fk_teams_leader(first_name,last_name),event:events(title))"
        
        let queryItems = [
            URLQueryItem(name: "select", value: queryString),
            URLQueryItem(name: "user_id", value: "eq.\(myId)"),
            URLQueryItem(name: "status", value: "eq.pending")
        ]
        
        var components = URLComponents(url: client.postgrestURL(for: "team_members"), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown Server Error"
            print("❌ Supabase API Error: \(errorText)")
            throw NSError(domain: "TeamService", code: 1, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        struct InviteResponse: Decodable {
            let status: String
            let team: TeamData
            
            struct TeamData: Decodable {
                let id: UUID
                let name: String
                let leader: ProfileData?
                let event: EventData?
            }
            struct ProfileData: Decodable {
                let first_name: String?
                let last_name: String?
                var fullName: String {
                    return [first_name, last_name].compactMap { $0 }.joined(separator: "")
                }
            }
            struct EventData: Decodable {
                let title: String?
            }
        }
        
        do {
            let rawResponse = try JSONDecoder().decode([InviteResponse].self, from: data)
            return rawResponse.map { item in
                let leaderName = item.team.leader?.fullName ?? "Unknown Leader"
                let finalLeaderName = leaderName.isEmpty ? "Unnamed User" : leaderName
                
                return TeamInviteDisplay(
                    teamId: item.team.id,
                    teamName: item.team.name,
                    inviterName: finalLeaderName,
                    eventName: item.team.event?.title ?? "Unknown Event",
                    status: item.status
                )
            }
        } catch {
            print("❌ Decoding Failed: \(error)")
            print("📄 Raw JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw error
        }
    }
    
    // MARK: - 4. RPC Functions (Concurrency & Logic Handled by DB)
    
    /// Accepts an Invite using the Database Function (RPC)
    /// Checks for Max Team Size limits atomically to prevent race conditions.
    /// Returns: "success", "team_is_full", or "invite_not_found"
    // MARK: - RPC Functions (Clean Version)

        func acceptInvite(teamId: UUID) async throws -> String {
            guard let client = client, let token = accessToken, let myId = currentUserId else {
                throw NSError(domain: "TeamService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])
            }
            
            // Clean one-liner using the new helper
            return try await client.callRPC(
                name: "accept_team_invite",
                params: ["p_team_id": teamId.uuidString, "p_user_id": myId],
                accessToken: token
            )
        }

        func confirmTeamRegistration(teamId: UUID) async throws -> String {
            guard let client = client, let token = accessToken else {
                throw NSError(domain: "TeamService", code: 0, userInfo: nil)
            }
            
            return try await client.callRPC(
                name: "confirm_team_registration",
                params: ["p_team_id": teamId.uuidString],
                accessToken: token
            )
        }
    
    /// Fetch Event limits (Min/Max size) for a specific Team
    func fetchTeamLimits(teamId: UUID) async throws -> (min: Int, max: Int) {
            guard let client = client, let token = accessToken else { return (0, 0) }
            
            // Query: teams -> embedded event data
            // We assume the relationship is named 'events' or the foreign key matches.
            // If Supabase complains, you might need "events!inner(...)" or just "events(...)"
            let query = "events(min_team_size,max_team_size)"
            
            let queryItems = [
                URLQueryItem(name: "select", value: query),
                URLQueryItem(name: "id", value: "eq.\(teamId.uuidString)"),
                URLQueryItem(name: "limit", value: "1")
            ]
            
            var components = URLComponents(url: client.postgrestURL(for: "teams"), resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            
            // ✅ CRITICAL: Add Auth Headers
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("❌ Error fetching limits: \(String(data: data, encoding: .utf8) ?? "Unknown")")
                return (0, 0)
            }
            
            // Decode Structure
            struct Response: Decodable {
                struct EventData: Decodable {
                    let min_team_size: Int?
                    let max_team_size: Int?
                }
                // Note: The key name matches the table name used in select.
                // If the relationship is "events", the JSON key is usually "events".
                let events: EventData?
            }
            
            do {
                let results = try JSONDecoder().decode([Response].self, from: data)
                if let eventData = results.first?.events {
                    // Default to 0 if null
                    return (eventData.min_team_size ?? 0, eventData.max_team_size ?? 0)
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
            
            return (0, 0)
        }
    

        // MARK: - Updated Fetch Function
    // MARK: - Fetch Function
        // notice return type is just [TeamMemberDisplay], not [TeamService.TeamMemberDisplay]
        func fetchTeamMembers(for teamId: UUID) async throws -> [TeamMemberDisplay] {
            guard let client = client, let token = accessToken else { return [] }
            
            // 1. Query: Get status, role, and join profiles for details + technical_role
            let queryString = "role,status,user:profiles(id,first_name,last_name,avatar_url,primary_role)"
            
            let queryItems = [
                URLQueryItem(name: "select", value: queryString),
                URLQueryItem(name: "team_id", value: "eq.\(teamId)")
            ]
            
            var components = URLComponents(url: client.postgrestURL(for: "team_members"), resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "TeamService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
            }
            
            // Internal Struct for decoding nested JSON (Supabase format)
            struct MemberResponse: Decodable {
                let status: String
                let role: String?
                let user: ProfileData
                
                struct ProfileData: Decodable {
                    let id: UUID
                    let first_name: String?
                    let last_name: String?
                    let avatar_url: String?
                    let primary_role: String?
                }
            }
            
            let rawResponse = try JSONDecoder().decode([MemberResponse].self, from: data)
            
            // Map to global TeamMemberDisplay model
            return rawResponse.map { item in
                TeamMemberDisplay(
                    id: item.user.id,
                    firstName: item.user.first_name ?? "Unknown",
                    lastName: item.user.last_name ?? "",
                    avatarUrl: item.user.avatar_url,
                    technicalRole: item.user.primary_role,
                    status: item.status,
                    role: item.role
                )
            }
        }
    
    // Check if the current user is already in a team for a specific event
    // Returns the Team UUID if found, or nil if they haven't joined yet.
    func checkIfAlreadyInTeam(for eventId: UUID) async throws -> UUID? {
        guard let client = client, let token = accessToken, let myId = currentUserId else { return nil }
        
        // Query Logic:
        // 1. Look at 'team_members' table.
        // 2. Filter by 'user_id' (Me).
        // 3. INNER JOIN 'teams' to filter by 'event_id'.
        // This ensures we find a team specifically for THIS event.
        
        let queryString = "team_id,teams!inner(event_id)"
        
        let queryItems = [
            URLQueryItem(name: "select", value: queryString),
            URLQueryItem(name: "user_id", value: "eq.\(myId)"),
            URLQueryItem(name: "teams.event_id", value: "eq.\(eventId)"), // Filter on the joined table
            URLQueryItem(name: "limit", value: "1") // We only need 1 result
        ]
        
        var components = URLComponents(url: client.postgrestURL(for: "team_members"), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // If error, print it but return nil so the app doesn't crash (assumes no team)
            print("checkIfAlreadyInTeam API Error: \(String(data: data, encoding: .utf8) ?? "")")
            return nil
        }
        
        // Helper struct to decode just the ID
        struct TeamCheckResponse: Decodable {
            let team_id: UUID
        }
        
        let results = try JSONDecoder().decode([TeamCheckResponse].self, from: data)
        
        // If we found a result, return the first one's ID
        return results.first?.team_id
    }
    
    // MARK: - 3. Decline Invite
    func declineInvite(teamId: UUID) async throws {
        guard let client = client, let token = accessToken, let myId = currentUserId else { return }
        
        // Manually build DELETE request to target specific row
        var components = URLComponents(url: client.postgrestURL(for: "team_members"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "team_id", value: "eq.\(teamId.uuidString)"),
            URLQueryItem(name: "user_id", value: "eq.\(myId)")
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "TeamService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to decline invite"])
        }
    }
    
    // MARK: - Data Models
//        struct UserTeamStatus: Decodable {
//            let team_id: UUID
//            let team_name: String
//            let my_role: String      // Returns "leader" or "member"
//            let is_confirmed: Bool
//        }

        // MARK: - Check Status Function
    func getUserTeamStatus(eventID: UUID) async throws -> UserTeamStatus? {
            guard let client = client, let token = accessToken, let userID = currentUserId else { return nil }
            
            let params: [String: Any] = [
                "p_event_id": eventID.uuidString,
                "p_user_id": userID
            ]
            
            let results: [UserTeamStatus] = try await client.callRPC(
                name: "get_user_team_status",
                params: params,
                accessToken: token
            )
            
            // 1. Get the first result found (if any)
            guard let status = results.first else { return nil }
            
            // 2. ⚡️ BUG FIX: Check if the user has actually ACCEPTED the invite.
            // If 'is_confirmed' is false, it means they are 'pending'.
            // We return nil so the UI treats them as "not in a team yet" (allowing them to create/join others).
            if !status.is_confirmed {
                return nil
            }
            
            return status
        }
}
