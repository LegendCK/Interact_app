//
//  EventService.swift
//  Interact_app
//
//  Created by admin73 on 01/01/26.


//
//  EventService.swift
//  Interact_app
//
//  Created by admin73 on 01/01/26.
//

import Foundation

final class EventService {

    // MARK: - Singleton
    static let shared = EventService()

    // MARK: - Properties
    /// Supabase client injected from SceneDelegate
    var client: SupabaseClient?

    private init() {}

    // MARK: - Fetch Methods

    /// Fetches all upcoming, approved events
    /// - Returns: Array of Event sorted by start date
    func fetchUpcomingEvents() async throws -> [Event] {

        guard let client = client else {
            throw NSError(
                domain: "EventService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "SupabaseClient has not been initialized."]
            )
        }

        let nowISO = ISO8601DateFormatter().string(from: Date())

        let queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "approval_status", value: "eq.approved"),
//            URLQueryItem(name: "start_date", value: "gte.\(nowISO)"),
//            URLQueryItem(name: "order", value: "start_date.asc")
        ]

        return try await client.fetch(from: "events", queryItems: queryItems)
    }

    // MARK: - Create Event (Organizer)

    /// Creates a new event.
    /// approval_status is automatically set to 'pending' by the database.
    func createEvent(payload: EventCreatePayload) async throws {

        // 1. Validate payload locally
        try payload.validate()

        guard let client = client else {
            throw NSError(
                domain: "EventService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "SupabaseClient has not been initialized."]
            )
        }

        guard let accessToken = UserDefaults.standard.string(forKey: "supabase_access_token") else {
            throw NSError(
                domain: "EventService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated."]
            )
        }

        // 2. Encode payload
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payload)

        // 3. Build insert request
        let request = client.makePostgrestInsertRequest(
            table: "events",
            body: body,
            accessToken: accessToken
        )

        // 4. Execute
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {

            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "EventService",
                code: (response as? HTTPURLResponse)?.statusCode ?? 0,
                userInfo: [NSLocalizedDescriptionKey: errorText]
            )
        }
    }
}
