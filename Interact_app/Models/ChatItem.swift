//
//  ChatItem.swift
//  Interact_app
//
//  Created by admin56 on 05/02/26.
//

import Foundation

struct ChatItem {
    let id: String
    let name: String
    let avatarURL: String?
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
    let isGroup: Bool
    
    // For displaying timestamp
    var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// Dummy data for testing
extension ChatItem {
    static func dummyData() -> [ChatItem] {
        return [
            ChatItem(
                id: "1",
                name: "Sarah Chen",
                avatarURL: nil,
                lastMessage: "Hey! Are you joining the AI hackathon next week?",
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                unreadCount: 2,
                isGroup: false
            ),
            ChatItem(
                id: "2",
                name: "DevSquad Team",
                avatarURL: nil,
                lastMessage: "John: Let's meet tomorrow to discuss the project",
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                unreadCount: 0,
                isGroup: true
            ),
            ChatItem(
                id: "3",
                name: "Alex Kumar",
                avatarURL: nil,
                lastMessage: "Thanks for the invite! I'm interested",
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                unreadCount: 0,
                isGroup: false
            ),
            ChatItem(
                id: "4",
                name: "Blockchain Builders",
                avatarURL: nil,
                lastMessage: "Sarah: We need one more developer",
                timestamp: Date().addingTimeInterval(-172800), // 2 days ago
                unreadCount: 5,
                isGroup: true
            )
        ]
    }
}
