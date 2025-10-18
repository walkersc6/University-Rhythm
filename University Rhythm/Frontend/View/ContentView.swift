//
//  ContentView.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var viewModel = RoadmapViewModel()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundGradientView()

                if isLoading {
                    LoadingView()
                } else if let error = errorMessage {
                    ErrorView(message: error) {
                        Task { await loadData() }
                    }
                } else {
                    LearningPathView(modulesWithLessons: viewModel.modulesWithLessons)
                }
            }
            .navigationTitle("Your Learning Journey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationMenu()
                }
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        await viewModel.fetchModulesWithLessons()

        // Simulate slight delay to prevent flashing
        try? await Task.sleep(nanoseconds: 100_000_000)

        isLoading = false

        if viewModel.modulesWithLessons.isEmpty {
            errorMessage = "No modules found. Please try again."
        }
    }
}

// MARK: - Background Gradient

struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.87, green: 0.95, blue: 1.0),
                Color(red: 0.7, green: 0.85, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Navigation Menu

struct NavigationMenu: View {
    var body: some View {
        Menu {
            NavigationLink(destination: EventsList(viewModel: RoadmapViewModel())) {
                Label("Events", systemImage: "calendar")
            }

            NavigationLink(destination: ChatView()) {
                Label("Y Guide", systemImage: "message.fill")
            }

            NavigationLink(destination: RewardsView()) {
                Label("Rewards", systemImage: "trophy.fill")
            }
        } label: {
            Image(systemName: "line.3.horizontal.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading your journey...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Learning Path View

struct LearningPathView: View {
    let modulesWithLessons: [ModuleWithLessons]
    @State private var pathAnchors: [Anchor<CGPoint>] = []

    var body: some View {
        ScrollView {
            ZStack {
                // Path connector line
                GeometryReader { geometry in
                    Canvas { context, size in
                        guard pathAnchors.count > 1 else { return }
                        var path = Path()
                        path.move(to: geometry[pathAnchors[0]])
                        for i in 1..<pathAnchors.count {
                            path.addLine(to: geometry[pathAnchors[i]])
                        }
                        context.stroke(
                            path,
                            with: .color(Color.white.opacity(0.6)),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [8, 4])
                        )
                    }
                }

                // Modules and lessons
                VStack(spacing: 50) {
                    ForEach(modulesWithLessons) { module in
                        ModuleSection(module: module)
                    }

                    Spacer(minLength: 60)
                }
                .padding(.top, 30)
                .padding(.horizontal, 16)
            }
            .coordinateSpace(name: "path")
            .onPreferenceChange(PathPreferenceKey.self) { anchors in
                self.pathAnchors = anchors
            }
        }
    }
}

// MARK: - Module Section

struct ModuleSection: View {
    let module: ModuleWithLessons

    var body: some View {
        VStack(spacing: 24) {
            ModuleHeader(title: module.module_name)

            LessonsGrid(
                lessons: module.lessons,
                moduleId: module.module_id
            )
        }
    }
}

// MARK: - Module Header

struct ModuleHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .multilineTextAlignment(.center)
    }
}

// MARK: - Lessons Grid

struct LessonsGrid: View {
    let lessons: [LessonSummary]
    let moduleId: Int

    var body: some View {
        VStack(spacing: 32) {
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                HStack {
                    if index % 2 == 0 {
                        LessonCard(lesson: lesson, moduleId: moduleId)
                            .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                        Spacer()
                    } else {
                        Spacer()
                        LessonCard(lesson: lesson, moduleId: moduleId)
                            .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                    }
                }
            }
        }
    }
}

// MARK: - Lesson Card

struct LessonCard: View {
    let lesson: LessonSummary
    let moduleId: Int
    @StateObject private var viewModel = RoadmapViewModel()
    @State private var fullLesson: Lesson?
    @State private var isLoadingLesson = false

    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack(spacing: 12) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)

                    if isLoadingLesson {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "book.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 70, height: 70)

                // Lesson name
                Text(lesson.lesson_name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var destinationView: some View {
        if let fullLesson = fullLesson {
            LessonDetailView(lesson: fullLesson, viewModel: viewModel)
        } else {
            LoadingLessonView(lessonName: lesson.lesson_name)
                .task {
                    await loadLessonDetails()
                }
        }
    }

    private func loadLessonDetails() async {
        isLoadingLesson = true
        await viewModel.fetchLessons(moduleId: moduleId)
        fullLesson = viewModel.lessons.first { $0.lesson_id == lesson.lesson_id }
        isLoadingLesson = false
    }
}

// MARK: - Loading Lesson View

struct LoadingLessonView: View {
    let lessonName: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading \(lessonName)...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .navigationTitle(lessonName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Path Drawing Helper

struct PathPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGPoint>]
    static var defaultValue: [Anchor<CGPoint>] = []

    static func reduce(value: inout [Anchor<CGPoint>], nextValue: () -> [Anchor<CGPoint>]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Lesson Detail View

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var viewModel: RoadmapViewModel
    @State private var selectedMCAnswers: [Int: String?] = [:]
    @State private var selectedTFAnswers: [Int: Bool?] = [:]

    private var attributedLessonText: AttributedString {
        do {
            let correctedString = lesson.lesson
                .replacingOccurrences(of: "\n", with: "\n\n")
            return try AttributedString(markdown: correctedString)
        } catch {
            return AttributedString(lesson.lesson)
        }
    }

    private var mcQuestions: [MCQuestion] {
        viewModel.getMCQuestionsForLesson(lesson.lesson_id)
    }

    private var tfQuestions: [TFQuestion] {
        viewModel.getTFQuestionsForLesson(lesson.lesson_id)
    }

    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Lesson content card
                    LessonContentCard(
                        isVideo: lesson.is_video,
                        attributedText: attributedLessonText
                    )

                    // Multiple choice questions
                    if !mcQuestions.isEmpty {
                        QuestionSection(title: "Multiple Choice") {
                            ForEach(mcQuestions) { question in
                                MCQuestionCard(
                                    question: question,
                                    selectedAnswer: Binding(
                                        get: { selectedMCAnswers[question.id] ?? nil },
                                        set: { selectedMCAnswers[question.id] = $0 }
                                    )
                                )
                            }
                        }
                    }

                    // True/False questions
                    if !tfQuestions.isEmpty {
                        QuestionSection(title: "True/False") {
                            ForEach(tfQuestions) { question in
                                TFQuestionCard(
                                    question: question,
                                    selectedAnswer: Binding(
                                        get: { selectedTFAnswers[question.id] ?? nil },
                                        set: { selectedTFAnswers[question.id] = $0 }
                                    )
                                )
                            }
                        }
                    }

                    // Take Quiz Button - Always show
                    NavigationLink(destination: QuizView(lessonId: lesson.lesson_id, lessonName: lesson.lesson_name)) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                            Text("Take Quiz")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .navigationTitle(lesson.lesson_name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMCQuestions(lessonId: lesson.lesson_id)
            await viewModel.fetchTFQuestions(lessonId: lesson.lesson_id)
        }
    }
}

// MARK: - Lesson Content Card

struct LessonContentCard: View {
    let isVideo: Bool
    let attributedText: AttributedString

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: isVideo ? "video.fill" : "doc.text.fill")
                    .foregroundColor(.blue)
                Text(isVideo ? "Video Lesson" : "Text Lesson")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            Text(attributedText)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Question Section

struct QuestionSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)

            content
        }
    }
}

// MARK: - MC Question Card

struct MCQuestionCard: View {
    let question: MCQuestion
    @Binding var selectedAnswer: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question_text)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 8) {
                AnswerButton(text: question.option_a, letter: "A", isSelected: selectedAnswer == "A") {
                    selectedAnswer = "A"
                }
                AnswerButton(text: question.option_b, letter: "B", isSelected: selectedAnswer == "B") {
                    selectedAnswer = "B"
                }
                AnswerButton(text: question.option_c, letter: "C", isSelected: selectedAnswer == "C") {
                    selectedAnswer = "C"
                }
                AnswerButton(text: question.option_d, letter: "D", isSelected: selectedAnswer == "D") {
                    selectedAnswer = "D"
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - TF Question Card

struct TFQuestionCard: View {
    let question: TFQuestion
    @Binding var selectedAnswer: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question_text)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 12) {
                Button {
                    selectedAnswer = true
                } label: {
                    Text("True")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedAnswer == true ? .white : .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedAnswer == true ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                Button {
                    selectedAnswer = false
                } label: {
                    Text("False")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedAnswer == false ? .white : .blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedAnswer == false ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Answer Button

struct AnswerButton: View {
    let text: String
    let letter: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
