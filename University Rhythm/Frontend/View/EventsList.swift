//
//  EventsList.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/18/25.
//

import SwiftUI

struct EventsList: View {
    @ObservedObject var viewModel: RoadmapViewModel
    @State private var isLoading = false // Used to show a loading spinner

    var body: some View {
        ZStack {
            // If the view is loading, show a spinner
            if isLoading {
                ProgressView("Fetching Events...")
            }
            // If not loading and the events array is empty, show a message
            else if viewModel.events.isEmpty {
                Text("No upcoming events found.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            // Otherwise, show the list of events
            else {
                List(viewModel.events) { event in
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
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Events")
        .task {
            // Only fetch if the list is empty to avoid reloading every time
            if viewModel.events.isEmpty {
                isLoading = true
                await viewModel.fetchEvents()
                isLoading = false
            }
        }
    }
}
