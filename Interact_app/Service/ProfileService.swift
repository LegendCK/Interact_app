//
//  ProfileService.swift
//  Interact_app
//
//  Created by admin73 on 14/01/26.
//

import Foundation

class ProfileService {
    
    static let shared = ProfileService()
    var client: SupabaseClient?
    
    private init() {}
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "supabase_access_token")
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "supabase_user_id")
    }
    
    func fetchProfilesLite() async throws -> [ProfileLite] {
        guard let client = client, let token = accessToken, let myId = currentUserId else { return [] }
        
        // 1. SECURITY CHECK: Ensure the CURRENT user is a "participant"
        // We saved this in SceneDelegate during login
        let myRole = UserDefaults.standard.string(forKey: "UserRole")
            if myRole != "participant" {
            print("⚠️ Access Denied: Organizers cannot view the connection list.")
            return [] // Return empty list so Organizers can't connect with anyone
            }
        
        // Filter out the current user
        let queryItems = [
            URLQueryItem(name: "select", value: "id,first_name,last_name,primary_role"),
            URLQueryItem(name: "id", value: "neq.\(myId)"),
            URLQueryItem(name: "role", value: "eq.participant")
        ]
        
        var urlComponents = URLComponents(url: client.postgrestURL(for: "profiles"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        
        // Manual Request Construction for Auth
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(client.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ProfileService", code: 0, userInfo: nil)
        }
        
        return try JSONDecoder().decode([ProfileLite].self, from: data)
    }
}
