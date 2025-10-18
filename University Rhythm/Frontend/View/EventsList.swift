//
//  EventsList.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/18/25.
//

import SwiftUI

// In ContentView.swift

struct EventsList: View {
    @ObservedObject var viewModel: RoadmapViewModel
    @State private var isLoading = false
    
    // 1. Add state for the calendar manager and alerts
    @StateObject private var calendarManager = CalendarManager()
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Fetching Events...")
            } else if viewModel.events.isEmpty {
                Text("No upcoming events found.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                List(viewModel.events) { event in
                    // 2. Add the button next to the event details
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(event.location)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()

//                        VStack {
//                            Button("Run Permission Test") {
//                                Task {
//                                    await calendarManager.debugRequestAccess()
//                                }
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .tint(.red)
//                            Spacer() // Pushes the button to the top
//                        }
//                        .zIndex(1) // Ensures the button is on top of the list
//
//                        if isLoading {
//                            // ...
//                        } else if viewModel.events.isEmpty {
//                            // ...
//                        } else {
//                            List(viewModel.events) { event in
//                                // ... your list row code
//                            }
//                        }
                    
                        Button {
                            // Call our new function when the button is tapped
                            addEventToCalendar(event)
                        } label: {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                        }
                        .buttonStyle(.borderless) // Use .borderless for buttons in a List row
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Events")
        .task {
            if viewModel.events.isEmpty {
                isLoading = true
                await viewModel.fetchEvents()
                isLoading = false
            }
        }
        // 3. Add an alert to show success or failure messages
        .alert("Add to Calendar", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    
    
    // 4. Add this helper function to the view
    // In ContentView.swift -> EventsList
    // In ContentView.swift -> EventsList

    // 1. REPLACE your old `addEventToCalendar` function with this new one.
    private func addEventToCalendar(_ event: Event) {
        Task {
            // Use a switch statement to handle all possible permission statuses
            switch calendarManager.authorizationStatus {
            
            case .fullAccess, .writeOnly:
                // Access is already granted, so save the event.
                await saveEvent(event)
                
            case .notDetermined:
                // Permission hasn't been asked for yet.
                if await calendarManager.requestAccess() {
                    // The user just granted permission, so save the event.
                    await saveEvent(event)
                } else {
                    // The user just denied permission.
                    alertMessage = "Calendar access was denied."
                    showAlert = true
                }
                
            case .denied, .restricted:
                // Access has been previously denied or is restricted by settings.
                alertMessage = "Calendar access is required. Please enable it in Settings > Privacy & Security > Calendars."
                showAlert = true
                
            @unknown default:
                // Handle any future cases Apple might add.
                alertMessage = "An unknown calendar error occurred."
                showAlert = true
            }
        }
    }

    // 2. ADD this new helper function right below the one above.
    private func saveEvent(_ event: Event) async {
        // First, make sure we can get valid dates for the event.
        guard let startDate = event.eventStartDate, let endDate = event.eventEndDate else {
            alertMessage = "There was an error reading the event's date."
            showAlert = true
            return
        }
        
        // Try to save the event to the calendar.
        do {
            try calendarManager.addEvent(
                title: event.title,
                startDate: startDate,
                endDate: endDate,
                location: event.location
            )
            alertMessage = "'\(event.title)' was successfully added to your calendar."
        } catch {
            alertMessage = "Failed to add event: \(error.localizedDescription)"
        }
        showAlert = true
    }

