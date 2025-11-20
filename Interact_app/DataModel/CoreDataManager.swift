//
//  CoreDataManager.swift
//  Interact-UIKit
//
//  Created by admin73 on 14/11/25.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Events") // Replace with your model name
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("❌ Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Event Management
extension CoreDataManager {
    
    func createEvent(
        eventName: String,
        startDate: Date,
        endDate: Date,
        location: String,                    
        registrationDeadline: Date,
        teamSize: String,
        eventDescription: String,
        whatsappGroupLink: String?,
        posterImage: UIImage?,
        eventType: String,
        rsvpForFood: Bool
    ) -> Bool {
        
        let context = persistentContainer.viewContext
        let newEvent = UserEvent(context: context)
        
        newEvent.id = UUID()
        newEvent.eventName = eventName
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.registrationDeadline = registrationDeadline
        newEvent.teamSize = Int16(teamSize) ?? 0
        newEvent.eventDescription = eventDescription
        newEvent.whatsappGroupLink = whatsappGroupLink
        newEvent.createdAt = Date()
        newEvent.eventType = eventType
        newEvent.rsvpForFood = rsvpForFood
        newEvent.location = location
        
        if let image = posterImage {
            newEvent.posterImageData = image.pngData()
        }

        do {
            try context.save()
            print("✅ Event saved successfully: \(eventName)")
            return true
        } catch {
            print("❌ Failed to save event: \(error.localizedDescription)")
            return false
        }
    }


    
    // Fetch All Events
    func fetchAllEvents() -> [UserEvent] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEvent> = UserEvent.fetchRequest()
        
        // Sort by creation date, newest first
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let events = try context.fetch(fetchRequest)
            print("✅ Fetched \(events.count) events")
            return events
        } catch {
            print("❌ Failed to fetch events: \(error)")
            return []
        }
    }
    
    // Fetch Event by ID
    func fetchEvent(by id: UUID) -> UserEvent? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEvent> = UserEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let events = try context.fetch(fetchRequest)
            return events.first
        } catch {
            print("❌ Failed to fetch event by ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Set Registration Count
        func setRegistrationCount(for eventId: UUID, count: Int16) -> Bool {
            guard let event = fetchEvent(by: eventId) else {
                print("❌ Event not found with ID: \(eventId)")
                return false
            }
            
            event.registeredCount = count
            
            do {
                try context.save()
                print("✅ Set registration count to \(count) for: \(event.eventName ?? "Unnamed")")
                return true
            } catch {
                print("❌ Failed to set registration count: \(error)")
                return false
            }
        }
    
    // Delete Event by fetching event - use for a delete button
    func deleteEvent(_ event: UserEvent) -> Bool {
        let context = persistentContainer.viewContext
        context.delete(event)
        
        do {
            try context.save()
            print("✅ Event deleted successfully")
            return true
        } catch {
            print("❌ Failed to delete event: \(error)")
            return false
        }
    }
    // delete event based on event id
    func deleteEventAndParticipants(by eventId: UUID) -> Bool {
        let context = persistentContainer.viewContext
        
        // 1. Delete participants linked to this event
        let participantFetch: NSFetchRequest<NSFetchRequestResult> = Participant.fetchRequest()
        participantFetch.predicate = NSPredicate(format: "eventId == %@", eventId as CVarArg)
        let deleteParticipantsRequest = NSBatchDeleteRequest(fetchRequest: participantFetch)
        
        // 2. Delete the event itself
        let eventFetch: NSFetchRequest<NSFetchRequestResult> = UserEvent.fetchRequest()
        eventFetch.predicate = NSPredicate(format: "id == %@", eventId as CVarArg)
        let deleteEventRequest = NSBatchDeleteRequest(fetchRequest: eventFetch)
        
        do {
            // Delete participants first
            try context.execute(deleteParticipantsRequest)
            
            // Delete the event
            try context.execute(deleteEventRequest)

            // Save context
            try context.save()
            
            print("🗑️ Deleted event + all participants linked to eventId: \(eventId)")
            return true
            
        } catch {
            print("❌ Failed to delete event + participants: \(error)")
            return false
        }
    }

    
    // Convert Data back to UIImage
    func convertToUIImage(from data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Participant Management
extension CoreDataManager {
    
    // Create a new participant
    func createParticipant(eventId: UUID, name: String, teamName: String, email: String) -> Bool {
        let context = persistentContainer.viewContext
        let participant = Participant(context: context)
        
        participant.id = UUID()
        participant.name = name
        participant.teamName = teamName
        participant.email = email
        participant.eventId = eventId
        participant.registeredAt = Date()
        
        do {
            try context.save()
            return true
        } catch {
            print("❌ Failed to create participant: \(error)")
            return false
        }
    }
    
    // Get all participants for a specific event
    func getParticipants(for eventId: UUID) -> [Participant] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Participant> = Participant.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "eventId == %@", eventId as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "registeredAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("❌ Failed to fetch participants: \(error)")
            return []
        }
    }
    
    // Get registration count for an event
    func getRegistrationCount(for eventId: UUID) -> Int {
        return getParticipants(for: eventId).count
    }
    
    // Populate dummy data for all events
    func populateDummyParticipantsForAllEvents() {
        let allEvents = fetchAllEvents()
        
        for event in allEvents {
            guard let eventId = event.id else { continue }
            
            // Check if participants already exist for this event
            let existingParticipants = getParticipants(for: eventId)
            if existingParticipants.isEmpty {
                createDummyParticipants(for: eventId)
                print("✅ Added 50 participants for: \(event.eventName ?? "Unnamed Event")")
            }
        }
    }
    
    // Create 50 dummy participants for an event
    private func createDummyParticipants(for eventId: UUID) {
        let dummyData = generateDummyParticipantsData()
        
        for participantData in dummyData {
            _ = createParticipant(
                eventId: eventId,
                name: participantData.name,
                teamName: participantData.teamName,
                email: participantData.email
            )
        }
    }
    
    // Generate 50 dummy participants
    private func generateDummyParticipantsData() -> [(name: String, teamName: String, email: String)] {
        return [
            ("Aarav Sharma", "Team Alpha", "aarav.sharma@example.com"),
            ("Priya Patel", "Code Warriors", "priya.patel@example.com"),
            ("Rohan Kumar", "Tech Titans", "rohan.kumar@example.com"),
            ("Ananya Singh", "Innovators Inc", "ananya.singh@example.com"),
            ("Vikram Joshi", "Digital Dreamers", "vikram.joshi@example.com"),
            ("Neha Gupta", "Byte Builders", "neha.gupta@example.com"),
            ("Arjun Reddy", "Logic Legends", "arjun.reddy@example.com"),
            ("Sneha Mishra", "Pixel Pioneers", "sneha.mishra@example.com"),
            ("Karan Malhotra", "Data Dynamos", "karan.malhotra@example.com"),
            ("Pooja Mehta", "Cloud Crew", "pooja.mehta@example.com"),
            ("Rahul Verma", "App Architects", "rahul.verma@example.com"),
            ("Divya Nair", "Web Wizards", "divya.nair@example.com"),
            ("Sanjay Kapoor", "AI Avengers", "sanjay.kapoor@example.com"),
            ("Maya Choudhury", "Mobile Mavericks", "maya.choudhury@example.com"),
            ("Amit Desai", "Code Crusaders", "amit.desai@example.com"),
            ("Sunita Rao", "Tech Tribe", "sunita.rao@example.com"),
            ("Rajesh Iyer", "Debug Dynasty", "rajesh.iyer@example.com"),
            ("Kavita Srinivasan", "Future Founders", "kavita.srinivasan@example.com"),
            ("Deepak Banerjee", "Startup Squad", "deepak.banerjee@example.com"),
            ("Anjali Thakur", "Innovation Nation", "anjali.thakur@example.com"),
            ("Mohan Das", "Cyber Champions", "mohan.das@example.com"),
            ("Lata Menon", "Digital Doers", "lata.menon@example.com"),
            ("Suresh Gowda", "App Alliance", "suresh.gowda@example.com"),
            ("Ritu Agarwal", "Web Warriors", "ritu.agarwal@example.com"),
            ("Nitin Bansal", "Cloud Collective", "nitin.bansal@example.com"),
            ("Swati Chopra", "Data Defenders", "swati.chopra@example.com"),
            ("Harish Pillai", "Tech Titans 2.0", "harish.pillai@example.com"),
            ("Preeti Saxena", "Code Collective", "preeti.saxena@example.com"),
            ("Alok Trivedi", "Digital Dynasty", "alok.trivedi@example.com"),
            ("Madhuri Kulkarni", "Innovation Inc", "madhuri.kulkarni@example.com"),
            ("Gaurav Naik", "App Army", "gaurav.naik@example.com"),
            ("Shweta Rathi", "Web Wizards 2.0", "shweta.rathi@example.com"),
            ("Prakash Mohan", "Cloud Commandos", "prakash.mohan@example.com"),
            ("Anita Bose", "Data Drivers", "anita.bose@example.com"),
            ("Vishal Yadav", "Tech Troopers", "vishal.yadav@example.com"),
            ("Sarika Pande", "Code Commanders", "sarika.pande@example.com"),
            ("Dinesh Rana", "Digital Defenders", "dinesh.rana@example.com"),
            ("Nisha Chawla", "Innovation Institute", "nisha.chawla@example.com"),
            ("Manish Tiwari", "App Academy", "manish.tiwari@example.com"),
            ("Rekha Bhardwaj", "Web Workers", "rekha.bhardwaj@example.com"),
            ("Siddharth Nair", "Cloud Corps", "siddharth.nair@example.com"),
            ("Tanvi Kapoor", "Data Division", "tanvi.kapoor@example.com"),
            ("Abhishek Sinha", "Tech Team", "abhishek.sinha@example.com"),
            ("Meera Joshi", "Code Corps", "meera.joshi@example.com"),
            ("Ravi Shukla", "Digital Division", "ravi.shukla@example.com"),
            ("Poonam Reddy", "Innovation Squad", "poonam.reddy@example.com"),
            ("Anil Mehta", "App Association", "anil.mehta@example.com"),
            ("Sonia Malhotra", "Web Wing", "sonia.malhotra@example.com"),
            ("Vivek Agarwal", "Cloud Club", "vivek.agarwal@example.com"),
            ("Kiran Patel", "Data Department", "kiran.patel@example.com")
        ]
    }
}

// MARK: - Attendance Management
extension CoreDataManager {
    
    // Update attendance status
    func updateAttendance(participantId: UUID, isAttended: Bool) -> Bool {
        guard let participant = getParticipant(by: participantId) else {
            print("Participant not found with ID: \(participantId)")
            return false
        }
        
        participant.isAttended = isAttended
        if isAttended {
            participant.checkedInAt = Date() // Set timestamp when attended
        } else {
            participant.checkedInAt = nil // Clear timestamp when not attended
        }
        
        do {
            try context.save()
            print("Updated attendance for \(participant.name ?? "Unknown"): \(isAttended ? "Present" : "Absent")")
            return true
        } catch {
            print("Failed to update attendance: \(error)")
            return false
        }
    }
    
    // Update food status
    func updateFoodStatus(participantId: UUID, hasFood: Bool) -> Bool {
        guard let participant = getParticipant(by: participantId) else {
            print("Participant not found with ID: \(participantId)")
            return false
        }
        
        participant.hasFood = hasFood
        
        do {
            try context.save()
            print("Updated food status for \(participant.name ?? "Unknown"): \(hasFood ? "Food Taken" : "No Food")")
            return true
        } catch {
            print("Failed to update food status: \(error)")
            return false
        }
    }
    
    // Get participant by ID
    private func getParticipant(by id: UUID) -> Participant? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Participant> = Participant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let participants = try context.fetch(fetchRequest)
            return participants.first
        } catch {
            print("Failed to fetch participant by ID: \(error)")
            return nil
        }
    }
    
    // Get attendance statistics for an event
    func getAttendanceStats(for eventId: UUID) -> (attended: Int, total: Int, foodTaken: Int) {
        let participants = getParticipants(for: eventId)
        let attendedCount = participants.filter { $0.isAttended }.count
        let foodCount = participants.filter { $0.hasFood }.count
        
        return (attendedCount, participants.count, foodCount)
    }
}
