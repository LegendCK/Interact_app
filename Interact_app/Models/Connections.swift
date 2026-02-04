//
//  Connections.swift
//  Interact_app
//
//  Created by admin73 on 14/01/26.
//

import Foundation

// 1. The Database Model (Profile Data)
// Updated to include 'avatar_url' since the service fetches it
struct ProfileLite: Codable, Identifiable {
    let id: UUID
    let firstName: String?
    let lastName: String?
    let primaryRole: String?
    let avatarUrl: String? // 👈 Added this
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case primaryRole = "primary_role"
        case avatarUrl = "avatar_url"
    }
    
    // Helper for UI
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}

// 2. The Connection Model (The "Smart" Model)
// This now matches the structure: { id, status, sender: {profile}, receiver: {profile} }
struct Connection: Codable, Identifiable {
    let id: UUID
    let senderId: UUID
    let receiverId: UUID
    let status: String // 'pending', 'accepted', 'rejected'
    
    // 👇 THESE ARE KEY: They hold the nested profile data
    let sender: ProfileLite?
    let receiver: ProfileLite?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case status
        case sender   // Matches "sender:sender_id(...)"
        case receiver // Matches "receiver:receiver_id(...)"
    }
    
    // MARK: - UI Helper
    // This logic determines who the "Friend" is.
    // If I am the sender, the friend is the receiver.
    // If I am the receiver, the friend is the sender.
    func friendProfile(myId: String) -> ProfileLite? {
        if senderId.uuidString == myId {
            return receiver
        } else {
            return sender
        }
    }
}

// 3. The View Model (For your Search/Discovery screens)
struct ProfileDisplayModel {
    let profile: ProfileLite
    var connectionStatus: String?
    
    var buttonTitle: String {
        switch connectionStatus {
        case "accepted": return "Accepted"
        case "pending": return "Pending"
        default: return "Connect"
        }
    }
    
    var isButtonEnabled: Bool {
        return connectionStatus == nil
    }
}

// 4. Extensions for Inbox Feature
struct ConnectionRequest: Decodable, Identifiable {
    let id: UUID
    let status: String
    let sender: ProfileLite
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case sender = "sender_id"
    }
}
