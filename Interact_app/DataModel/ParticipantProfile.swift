import Foundation

struct ParticipantProfile {

    let id: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let skills: [String]
    let primaryRole: String?
    let secondaryRole: String?
    let academicYear: String?
    let college: String?
    let location: String?
    let avatarUrl: String?

    // MARK: - Derived / UI-ready values

    var displayName: String {
        let first = firstName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName?.trimmingCharacters(in: .whitespacesAndNewlines)

        switch (first?.isEmpty == false, last?.isEmpty == false) {
        case (true, true):
            return "\(first!) \(last!)"
        case (true, false):
            return first!
        case (false, true):
            return last!
        default:
            return "Participant"
        }
    }

    var displayBio: String {
        guard let bio, !bio.isEmpty else {
            return "No bio added yet."
        }
        return bio
    }

    var displayEducation: String {
        var parts: [String] = []
        if let year = academicYear, !year.isEmpty { parts.append(year) }
        if let college = college, !college.isEmpty { parts.append(college) }
        return parts.isEmpty ? "—" : parts.joined(separator: " • ")
    }
    

    // MARK: - Factory

    static func from(json: [String: Any]) -> ParticipantProfile? {
        guard let id = json["id"] as? String else { return nil }

        return ParticipantProfile(
            id: id,
            firstName: json["first_name"] as? String,
            lastName: json["last_name"] as? String,
            bio: json["about"] as? String,
            skills: json["skills"] as? [String] ?? [],
            primaryRole: json["primary_role"] as? String,
            secondaryRole: json["secondary_role"] as? String,
            academicYear: json["academic_year"] as? String,
            college: json["college"] as? String,
            location: json["location"] as? String,
            avatarUrl: json["avatar_url"] as? String
        )
    }
}
