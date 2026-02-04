//
//  Event.swift
//  Interact_app
//
//  Created by admin73 on 01/01/26.
//

import Foundation

// MARK: - Location Type (Shared)
enum EventLocationType: String, Codable {
    case online
    case offline
    case hybrid
}

//
// MARK: - WRITE MODEL (Organizer → DB)
// Used ONLY for creating/updating events
//
struct EventCreatePayload: Codable {

    // Required
    let title: String
    let description: String
    let thumbnailUrl: String
    let startDate: Date
    let endDate: Date
    let locationType: EventLocationType
    let minTeamSize: Int
    let maxTeamSize: Int
    let registrationDeadline: Date

    // Conditional
    let location: String?
    let meetingLink: String?
    let rsvpForFoodRequired: Bool?

    // Optional
    let externalLink: String?
    let eligibilityCriteria: String?
    let prizePool: String?
    let capacity: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case thumbnailUrl = "thumbnail_url"
        case startDate = "start_date"
        case endDate = "end_date"
        case locationType = "location_type"
        case location
        case meetingLink = "meeting_link"
        case rsvpForFoodRequired = "rsvp_for_food_required"
        case minTeamSize = "min_team_size"
        case maxTeamSize = "max_team_size"
        case capacity
        case registrationDeadline = "registration_deadline"
        case eligibilityCriteria = "eligibility_criteria"
        case prizePool = "prize_pool"
        case externalLink = "external_link"
    }
}

//
// MARK: - READ MODEL (DB → App)
// Used for lists, details, navigation
//
struct Event: Decodable {

    // Core
    let id: UUID
    let title: String
    let description: String
    let thumbnailUrl: String

    // Dates
    let startDate: Date
    let endDate: Date
    let registrationDeadline: Date

    // Location
    let locationType: EventLocationType
    let location: String?
    let meetingLink: String?

    // Rules
    let minTeamSize: Int
    let maxTeamSize: Int
    let capacity: Int?

    // Optional Info
    let eligibilityCriteria: String?
    let prizePool: String?

    // System
    let approvalStatus: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case thumbnailUrl = "thumbnail_url"
        case startDate = "start_date"
        case endDate = "end_date"
        case registrationDeadline = "registration_deadline"
        case locationType = "location_type"
        case location
        case meetingLink = "meeting_link"
        case minTeamSize = "min_team_size"
        case maxTeamSize = "max_team_size"
        case capacity
        case eligibilityCriteria = "eligibility_criteria"
        case prizePool = "prize_pool"
        case approvalStatus = "approval_status"
    }
}

extension EventCreatePayload {

    func validate() throws {

        guard minTeamSize <= maxTeamSize else {
            throw ValidationError.invalidTeamSize
        }

        guard registrationDeadline < startDate else {
            throw ValidationError.invalidRegistrationDeadline
        }

        guard endDate > startDate else {
            throw ValidationError.invalidEventDates
        }

        switch locationType {
        case .online:
            guard meetingLink?.isEmpty == false else {
                throw ValidationError.missingMeetingLink
            }

        case .offline:
            guard location?.isEmpty == false else {
                throw ValidationError.missingLocation
            }

        case .hybrid:
            guard location?.isEmpty == false,
                  meetingLink?.isEmpty == false else {
                throw ValidationError.missingHybridDetails
            }
        }
    }

    enum ValidationError: LocalizedError {
        case missingLocation
        case missingMeetingLink
        case missingHybridDetails
        case invalidTeamSize
        case invalidEventDates
        case invalidRegistrationDeadline

        var errorDescription: String? {
            switch self {
            case .missingLocation:
                return "Location is required for offline events."
            case .missingMeetingLink:
                return "Meeting link is required for online events."
            case .missingHybridDetails:
                return "Both location and meeting link are required for hybrid events."
            case .invalidTeamSize:
                return "Minimum team size cannot be greater than maximum team size."
            case .invalidEventDates:
                return "End date must be after start date."
            case .invalidRegistrationDeadline:
                return "Registration deadline must be before the event start date."
            }
        }
    }
}
