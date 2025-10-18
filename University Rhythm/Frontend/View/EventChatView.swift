//
//  EventChatView.swift
//  University Rhythm
//
//  Created by Claude on 10/18/25.
//

import SwiftUI

// MARK: - Event Chat Message Model

struct EventChatMessage: Identifiable {
    let id = UUID()
    let username: String
    let text: String
    let timestamp: Date
    let isCurrentUser: Bool
}

// MARK: - Event Chat View

struct EventChatView: View {
    let event: Event

    // Hardcoded chat messages
    private let chatMessages: [EventChatMessage] = [
        EventChatMessage(
            username: "Sarah M.",
            text: "Hey everyone! Is anyone else going to this event?",
            timestamp: Date().addingTimeInterval(-3600),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "Mike J.",
            text: "Yeah! I'm planning to go. Should be fun!",
            timestamp: Date().addingTimeInterval(-3300),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "You",
            text: "Count me in! What time are you all heading over?",
            timestamp: Date().addingTimeInterval(-3000),
            isCurrentUser: true
        ),
        EventChatMessage(
            username: "Sarah M.",
            text: "I was thinking of getting there about 15 minutes early to get a good spot",
            timestamp: Date().addingTimeInterval(-2700),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "Emily K.",
            text: "Great idea! I'll meet you guys there",
            timestamp: Date().addingTimeInterval(-2400),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "Mike J.",
            text: "Should we grab food before? There's a good place nearby",
            timestamp: Date().addingTimeInterval(-2100),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "You",
            text: "That sounds perfect! Where should we meet?",
            timestamp: Date().addingTimeInterval(-1800),
            isCurrentUser: true
        ),
        EventChatMessage(
            username: "Sarah M.",
            text: "How about we meet at the Wilkinson Center at 5:30?",
            timestamp: Date().addingTimeInterval(-1500),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "Emily K.",
            text: "Works for me! See you all there 👍",
            timestamp: Date().addingTimeInterval(-1200),
            isCurrentUser: false
        ),
        EventChatMessage(
            username: "Mike J.",
            text: "Awesome! Can't wait!",
            timestamp: Date().addingTimeInterval(-900),
            isCurrentUser: false
        )
    ]

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Event Info Header
                EventInfoHeader(event: event)

                Divider()

                // Messages
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(chatMessages) { message in
                            EventChatBubble(message: message)
                        }
                    }
                    .padding()
                }

                // Input Area (disabled for hardcoded chat)
                DisabledInputArea()
            }
        }
        .navigationTitle("Event Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Event Info Header

struct EventInfoHeader: View {
    let event: Event

    var body: some View {
        VStack(spacing: 8) {
            Text(event.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Label(event.date, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label(event.location, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Event Chat Bubble

struct EventChatBubble: View {
    let message: EventChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isCurrentUser {
                Spacer()
            }

            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Username (only for other users)
                if !message.isCurrentUser {
                    Text(message.username)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                }

                // Message bubble
                HStack {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(message.isCurrentUser ? Color.blue : Color.white)
                        .foregroundColor(message.isCurrentUser ? .white : .primary)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }

                // Timestamp
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
            }
            .frame(maxWidth: 280, alignment: message.isCurrentUser ? .trailing : .leading)

            if !message.isCurrentUser {
                Spacer()
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Disabled Input Area

struct DisabledInputArea: View {
    var body: some View {
        HStack(spacing: 12) {
            TextField("This is a preview conversation...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(true)
                .frame(minHeight: 40)

            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .disabled(true)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EventChatView(event: Event(
            id: "1",
            category: "Social",
            title: "Welcome Week Kickoff",
            description: "Join us for the start of Welcome Week!",
            date: "2025-08-25",
            startTime: "18:00:00",
            endTime: "20:00:00",
            location: "Wilkinson Center",
            allDay: false,
            createdAt: "2025-01-01",
            updatedAt: "2025-01-01"
        ))
    }
}
