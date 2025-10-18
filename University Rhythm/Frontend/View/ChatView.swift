//
//  ChatView.swift
//  University Rhythm
//
//  Created by Claude on 10/18/25.
//

import SwiftUI

// MARK: - API Models
struct AIMessageRequest: Codable {
    let message: String
    let model: String
}

struct AIMessageResponse: Codable {
    let response: String
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - Main Chat View
struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var messageText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .padding(.leading, 16)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area
            HStack(spacing: 12) {
                TextField("Type your message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Y Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Welcome message
            if messages.isEmpty {
                messages.append(ChatMessage(
                    text: "Hello! I'm your learning assistant. How can I help you today?",
                    isUser: false,
                    timestamp: Date()
                ))
            }
        }
    }

    // MARK: - Helper Functions
    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            text: messageText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)

        let currentMessage = messageText
        messageText = ""

        // Send message to API
        isLoading = true
        Task {
            await sendMessageToAI(message: currentMessage)
        }
    }

    private func sendMessageToAI(message: String) async {
        guard let url = URL(string: "https://possible-stafani-hoco-byu-hack-d9d46b95.koyeb.app/ai/message") else {
            await handleError(message: "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = AIMessageRequest(message: message, model: "gpt-4o-mini")

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                await handleError(message: "Server error occurred")
                return
            }

            let aiResponse = try JSONDecoder().decode(AIMessageResponse.self, from: data)

            await MainActor.run {
                isLoading = false
                let botResponse = ChatMessage(
                    text: aiResponse.response,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(botResponse)
            }
        } catch {
            await handleError(message: "Failed to get response: \(error.localizedDescription)")
        }
    }

    private func handleError(message: String) async {
        await MainActor.run {
            isLoading = false
            let errorResponse = ChatMessage(
                text: "Sorry, I encountered an error: \(message)",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorResponse)
        }
    }
}

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser {
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

// MARK: - Preview
#Preview {
    NavigationStack {
        ChatView()
    }
}
