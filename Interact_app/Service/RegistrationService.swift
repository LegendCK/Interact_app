//
//  RegistrationService.swift
//  Interact_app
//
//  Created by admin73 on 05/02/26.
//

import Foundation

class RegistrationService {
    
    static let shared = RegistrationService()
    var client: SupabaseClient? // Injected from SceneDelegate
    
    private init() {}
    
    // MARK: - Helpers
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "supabase_access_token")
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "supabase_user_id")
    }

    func fetchEventParticipants(eventId: UUID) async throws -> [EventParticipant] {

        guard
            let client = client,
            let token = UserDefaults.standard.string(forKey: "supabase_access_token")
        else {
            throw NSError(
                domain: "RegistrationService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }

        return try await client.callRPC(
            name: "get_event_participants",
            params: [
                "p_event_id": eventId.uuidString
            ],
            accessToken: token
        )
    }

}
