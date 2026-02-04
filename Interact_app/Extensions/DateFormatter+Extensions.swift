//
//  DateFormatter+Extensions.swift
//  Interact_app
//
//  Created by admin73 on 01/01/26.
//

//
//  DateFormatter+Extensions.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import Foundation

extension DateFormatter {
    /// Used for UI display: "Dec 15, 2024 • 9:00 AM"
    static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Used for backend ISO strings
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Used for event date range: "March 20 – March 22, 2026"
    static let eventDateRangeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Used for event year only
    static let eventYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Used for event time: "9:00 AM"
    static let eventTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

}

extension Date {
    func toEventString() -> String {
        return DateFormatter.eventDateFormatter.string(from: self)
    }
    
    static func eventDateRangeString(start: Date, end: Date) -> String {
        let startDate = DateFormatter.eventDateRangeFormatter.string(from: start)
        let endDate = DateFormatter.eventDateRangeFormatter.string(from: end)
        let year = DateFormatter.eventYearFormatter.string(from: end)

        return "\(startDate) – \(endDate), \(year)"
    }

    static func eventTimeRangeString(start: Date, end: Date) -> String {
        let startTime = DateFormatter.eventTimeFormatter.string(from: start)
        let endTime = DateFormatter.eventTimeFormatter.string(from: end)

        return "\(startTime) – \(endTime)"
    }

}
