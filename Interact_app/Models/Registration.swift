//
//  Registration.swift
//  Interact_app
//
//  Created by admin73 on 05/02/26.
//

import Foundation

//struct EventParticipant: Decodable {
//    let userId: UUID
//    let name: String
//    let email: String?
//    let teamId: UUID?
//    let status: String
//    let joinedAt: Date
//
//    enum CodingKeys: String, CodingKey {
//        case userId = "user_id"
//        case name
//        case email
//        case teamId = "team_id"
//        case status
//        case joinedAt = "joined_at"
//    }
//}

struct EventParticipant: Decodable {
    let userId: UUID
    let name: String
    let email: String?
    let teamId: UUID?
    let teamName: String?
    let status: String
    let joinedAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case email
        case teamId = "team_id"
        case teamName = "team_name"
        case status
        case joinedAt = "joined_at"
    }
}
