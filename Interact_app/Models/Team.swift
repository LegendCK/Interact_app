//
//  Team.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import Foundation

// MARK: - Database Models (Raw Tables)

struct Teams: Codable, Identifiable {
    let id: UUID
    let name: String
    let leader_id: UUID
    let event_id: UUID?
    let created_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case leader_id
        case event_id
        case created_at
    }
}

struct TeamMember: Codable {
    let teamId: UUID
    let userId: UUID
    let status: String // 'accepted' or 'pending'
    let role: String   // 'leader' or 'member'
    
    enum CodingKeys: String, CodingKey {
        case teamId = "team_id"
        case userId = "user_id"
        case status
        case role
    }
}

// MARK: - UI Display Models

/// Used for the Notification/Invite screen
struct TeamInviteDisplay: Codable {
    let teamId: UUID
    let teamName: String
    let inviterName: String // The Team Leader
    let eventName: String   // The Event
    let status: String
}

/// Used for the Team Info Modal (TableView)
struct TeamMemberDisplay: Identifiable, Decodable {
    let id: UUID
    let firstName: String
    let lastName: String
    let avatarUrl: String?
    let technicalRole: String? // ✅ Added: Backend, Frontend, etc.
    let status: String         // "accepted", "pending"
    let role: String?          // "leader", "member"
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

/// Used for the initial check to route the user (Leader vs Member vs None)
struct UserTeamStatus: Decodable {
    let team_id: UUID
    let team_name: String
    let my_role: String      // Returns "leader" or "member"
    let is_confirmed: Bool
}
