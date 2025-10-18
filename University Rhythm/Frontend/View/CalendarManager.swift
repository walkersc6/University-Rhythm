//
//  CalendarManager.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/18/25.
//

// CalendarManager.swift

import Foundation
import EventKit // Import the EventKit framework

@MainActor
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    // A property to check the current authorization status
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }
    
    // Requests write-only access to the user's calendar
    func requestAccess() async -> Bool {
        do {
            // This will show the permission pop-up to the user
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            return granted
        } catch {
            print("Failed to request calendar access:", error)
            return false
        }
    }
    
    // Adds a specific event to the default calendar
    func addEvent(title: String, startDate: Date, endDate: Date, location: String) throws {
        // Create a new calendar event
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.calendar = eventStore.defaultCalendarForNewEvents // Adds to the default calendar

        // Save the event
        try eventStore.save(event, span: .thisEvent)
    }
}
