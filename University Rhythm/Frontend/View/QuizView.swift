//
//  QuizView.swift
//  University Rhythm
//
//  Created by Claude on 10/18/25.
//

import SwiftUI

// MARK: - Quiz View

struct QuizView: View {
    let lessonId: Int
    let lessonName: String

    @StateObject private var viewModel = RoadmapViewModel()
    @State private var mcQuestions: [QuizQuestion] = []
    @State private var tfQuestions: [QuizQuestion] = []
    @State private var mcAnswers: [Int: String] = [:] // question_id: answer for MC
    @State private var tfAnswers: [Int: String] = [:] // question_id: answer for TF
    @State private var isLoading = true
    @State private var showResults = false
    @State private var score: Int = 0
    @Environment(\.dismiss) private var dismiss

    private var allQuestions: [QuizQuestion] {
        mcQuestions + tfQuestions
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            if isLoading {
                LoadingView()
            } else if allQuestions.isEmpty {
                EmptyQuizView()
            } else if showResults {
                QuizResultsView(
                    score: score,
                    totalQuestions: allQuestions.count,
                    onRetry: resetQuiz,
                    onClose: { dismiss() }
                )
            } else {
                QuizQuestionsView(
                    mcQuestions: mcQuestions,
                    tfQuestions: tfQuestions,
                    mcAnswers: $mcAnswers,
                    tfAnswers: $tfAnswers,
                    onSubmit: submitQuiz
                )
            }
        }
        .navigationTitle("Quiz: \(lessonName)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadQuestions()
        }
    }

    // MARK: - Data Loading

    private func loadQuestions() async {
        isLoading = true
        if let response = await viewModel.fetchAllQuestions(lessonId: lessonId) {
            mcQuestions = response.questions.filter { $0.type == .multiple_choice }
            tfQuestions = response.questions.filter { $0.type == .true_false }
        }
        isLoading = false
    }

    // MARK: - Quiz Submission

    private func submitQuiz() {
        Task {
            var correctCount = 0
            var correctQuestionIds: [Int] = []

            // Check MC questions
            for question in mcQuestions {
                guard let userAnswer = mcAnswers[question.question_id] else {
                    continue // Skip unanswered questions
                }

                if case .string(let correctAnswer) = question.answer {
                    if userAnswer == correctAnswer {
                        correctCount += 1
                        correctQuestionIds.append(question.question_id)
                    }
                }
            }

            // Check TF questions
            for question in tfQuestions {
                guard let userAnswer = tfAnswers[question.question_id] else {
                    continue // Skip unanswered questions
                }

                if case .bool(let correctAnswer) = question.answer {
                    let isCorrect = (userAnswer == "true" && correctAnswer) || (userAnswer == "false" && !correctAnswer)
                    if isCorrect {
                        correctCount += 1
                        correctQuestionIds.append(question.question_id)
                    }
                }
            }

            // Update backend with correct answers
            await updateUserProgress(correctQuestionIds: correctQuestionIds)

            // Update UI
            score = correctCount
            withAnimation {
                showResults = true
            }
        }
    }

    // MARK: - Update User Progress

    private func updateUserProgress(correctQuestionIds: [Int]) async {
        // Fetch current progress
        guard let progress = await viewModel.fetchUserProgress() else {
            print("⚠️ Failed to fetch user progress, skipping update")
            return
        }

        // Get existing correct question IDs
        let existingQuestionIds = progress.questions_right ?? []

        // Combine with newly correct answers (using Set to avoid duplicates)
        let combinedIds = Array(Set(existingQuestionIds + correctQuestionIds))

        // Update backend
        let success = await viewModel.updateUserProgress(questionIds: combinedIds)

        if success {
            print("✅ User progress updated successfully")
        } else {
            print("⚠️ Failed to update user progress")
        }
    }

    // MARK: - Reset Quiz

    private func resetQuiz() {
        mcAnswers.removeAll()
        tfAnswers.removeAll()
        showResults = false
        score = 0
    }
}

// MARK: - Quiz Questions View

struct QuizQuestionsView: View {
    let mcQuestions: [QuizQuestion]
    let tfQuestions: [QuizQuestion]
    @Binding var mcAnswers: [Int: String]
    @Binding var tfAnswers: [Int: String]
    let onSubmit: () -> Void

    var allQuestions: [QuizQuestion] {
        mcQuestions + tfQuestions
    }

    var totalAnswered: Int {
        mcAnswers.count + tfAnswers.count
    }

    var allQuestionsAnswered: Bool {
        mcQuestions.allSatisfy { mcAnswers[$0.question_id] != nil } &&
        tfQuestions.allSatisfy { tfAnswers[$0.question_id] != nil }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress indicator
                QuizProgressBar(
                    answered: totalAnswered,
                    total: allQuestions.count
                )

                // MC Questions
                ForEach(Array(mcQuestions.enumerated()), id: \.element.id) { index, question in
                    QuizQuestionCard(
                        question: question,
                        questionNumber: index + 1,
                        selectedAnswer: Binding(
                            get: { mcAnswers[question.question_id] },
                            set: { mcAnswers[question.question_id] = $0 }
                        )
                    )
                }

                // TF Questions
                ForEach(Array(tfQuestions.enumerated()), id: \.element.id) { index, question in
                    QuizQuestionCard(
                        question: question,
                        questionNumber: mcQuestions.count + index + 1,
                        selectedAnswer: Binding(
                            get: { tfAnswers[question.question_id] },
                            set: { tfAnswers[question.question_id] = $0 }
                        )
                    )
                }

                // Submit button
                Button(action: onSubmit) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Submit Quiz")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        allQuestionsAnswered ?
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray, Color.gray.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: allQuestionsAnswered ? .green.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!allQuestionsAnswered)
                .buttonStyle(PlainButtonStyle())

                if !allQuestionsAnswered {
                    Text("Please answer all questions before submitting")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Quiz Progress Bar

struct QuizProgressBar: View {
    let answered: Int
    let total: Int

    var progress: Double {
        total > 0 ? Double(answered) / Double(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(answered)/\(total)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Quiz Question Card

struct QuizQuestionCard: View {
    let question: QuizQuestion
    let questionNumber: Int
    @Binding var selectedAnswer: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question header
            HStack(alignment: .top, spacing: 12) {
                Text("\(questionNumber).")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 30, alignment: .leading)

                Text(question.question_text)
                    .font(.body)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Answer options
            if question.type == .multiple_choice {
                VStack(spacing: 10) {
                    QuizAnswerOption(letter: "a", text: question.a ?? "", isSelected: selectedAnswer == "a") {
                        selectedAnswer = "a"
                    }
                    QuizAnswerOption(letter: "b", text: question.b ?? "", isSelected: selectedAnswer == "b") {
                        selectedAnswer = "b"
                    }
                    QuizAnswerOption(letter: "c", text: question.c ?? "", isSelected: selectedAnswer == "c") {
                        selectedAnswer = "c"
                    }
                    QuizAnswerOption(letter: "d", text: question.d ?? "", isSelected: selectedAnswer == "d") {
                        selectedAnswer = "d"
                    }
                }
            } else {
                HStack(spacing: 12) {
                    QuizTrueFalseButton(
                        text: "True",
                        isSelected: selectedAnswer == "true"
                    ) {
                        selectedAnswer = "true"
                    }

                    QuizTrueFalseButton(
                        text: "False",
                        isSelected: selectedAnswer == "false"
                    ) {
                        selectedAnswer = "false"
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedAnswer != nil ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Quiz Answer Option

struct QuizAnswerOption: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter.uppercased())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quiz True/False Button

struct QuizTrueFalseButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : .blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quiz Results View

struct QuizResultsView: View {
    let score: Int
    let totalQuestions: Int
    let onRetry: () -> Void
    let onClose: () -> Void

    var percentage: Double {
        totalQuestions > 0 ? Double(score) / Double(totalQuestions) * 100 : 0
    }

    var resultColor: Color {
        if percentage >= 80 { return .green }
        if percentage >= 60 { return .orange }
        return .red
    }

    var resultEmoji: String {
        if percentage >= 80 { return "🎉" }
        if percentage >= 60 { return "👍" }
        return "📚"
    }

    var resultMessage: String {
        if percentage >= 80 { return "Excellent work!" }
        if percentage >= 60 { return "Good job!" }
        return "Keep studying!"
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Result emoji
            Text(resultEmoji)
                .font(.system(size: 80))

            // Score
            VStack(spacing: 12) {
                Text("\(score)/\(totalQuestions)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(resultColor)

                Text(resultMessage)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(Int(percentage))% Correct")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(resultColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: percentage)

                Text("\(Int(percentage))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(resultColor)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry Quiz")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                Button(action: onClose) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Empty Quiz View

struct EmptyQuizView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Questions Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This lesson doesn't have any quiz questions yet.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        QuizView(lessonId: 1, lessonName: "Welcome to BYU")
    }
}
