//
//  ContentView.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import SwiftUI
import UIKit

// MARK: - Path Drawing Helper
struct PathPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGPoint>]
    static var defaultValue: [Anchor<CGPoint>] = []

    static func reduce(value: inout [Anchor<CGPoint>], nextValue: () -> [Anchor<CGPoint>]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - UIKit Text View Wrapper
// This struct wraps a reliable UIKit UILabel to ensure text wraps correctly.
struct MarkdownLabel: UIViewRepresentable {
    let attributedString: AttributedString

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = NSAttributedString(attributedString)
        uiView.font = UIFont.preferredFont(forTextStyle: .body)
    }
}


// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = RoadmapViewModel()
    @State private var pathAnchors: [Anchor<CGPoint>] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // ... (The ZStack with your ScrollView remains the same)
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.87, green: 0.95, blue: 1.0), Color(red: 0.7, green: 0.85, blue: 1.0)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        ZStack {
                            Canvas { context, size in
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: size.height))
                                path.addCurve(to: CGPoint(x: size.width, y: size.height), control1: CGPoint(x: size.width * 0.3, y: size.height * 0.2), control2: CGPoint(x: size.width * 0.7, y: size.height * 0.2))
                                path.addLine(to: CGPoint(x: size.width, y: size.height))
                                path.addLine(to: CGPoint(x: 0, y: size.height))
                                path.closeSubpath()
                            }.frame(maxHeight: .infinity)
                            
                            GeometryReader { geometry in
                                Canvas { context, size in
                                    guard pathAnchors.count > 1 else { return }
                                    var path = Path()
                                    path.move(to: geometry[pathAnchors[0]])
                                    for i in 1..<pathAnchors.count { path.addLine(to: geometry[pathAnchors[i]]) }
                                    context.stroke(path, with: .color(Color.white.opacity(0.7)), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                }
                            }

                            VStack(spacing: 40) {
                                ForEach(viewModel.modules) { module in
                                    ModuleTitleView(name: module.module_name)
                                    LessonsForModuleView(moduleId: module.module_id, viewModel: viewModel)
                                }
                                Spacer(minLength: 80)
                            }
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                        .coordinateSpace(name: "path")
                        .onPreferenceChange(PathPreferenceKey.self) { anchors in self.pathAnchors = anchors }
                    }
                }
            }
            .navigationTitle("Your Learning Journey")
            .navigationBarTitleDisplayMode(.large)
            // +++ Replace the old toolbar with this new Menu +++
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink("Events List", destination: EventsList(viewModel: viewModel))
                        NavigationLink("Chat Bot", destination: ChatBotView())
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchModules()
        }
    }
}

// MARK: - Main Screen Helper Views
struct ModuleTitleView: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.headline)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 160)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.background)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

struct LessonsForModuleView: View {
    let moduleId: Int
    @ObservedObject var viewModel: RoadmapViewModel
    
    private var sortedLessons: [Lesson] {
        viewModel.getLessonsForModule(moduleId).sorted { $0.order_num < $1.order_num }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            ForEach(Array(sortedLessons.enumerated()), id: \.element.id) { index, lesson in
                HStack {
                    if index % 2 == 0 {
                        NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                            MountainLessonBubble(lesson: lesson)
                                .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                        }
                        Spacer()
                    } else {
                        Spacer()
                        NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                            MountainLessonBubble(lesson: lesson)
                                .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLessons(moduleId: moduleId)
            }
        }
    }
}

struct MountainLessonBubble: View {
    let lesson: Lesson
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 6)
                Image(systemName: lesson.is_video ? "video.fill" : "book.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            
            Text(lesson.lesson_name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 90)
        }
    }
}

// MARK: - Lesson Detail View (Form Style)
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

    var mcQuestions: [MCQuestion] {
        viewModel.getMCQuestionsForLesson(lesson.lesson_id)
    }
    
    var tfQuestions: [TFQuestion] {
        viewModel.getTFQuestionsForLesson(lesson.lesson_id)
    }
    
    var body: some View { // ✅ Capital V
        ZStack {
            Image("astronaut")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.white.opacity(0.4), Color.white.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Form {
                Section(header: Text("Lesson Content")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: lesson.is_video ? "video.fill" : "doc.fill")
                                .foregroundColor(.blue)
                            Text(lesson.is_video ? "Video Lesson" : "Text Lesson")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        MarkdownLabel(attributedString: attributedLessonText)
                    }
                }

                if !mcQuestions.isEmpty {
                    Section(header: Text("Multiple Choice Questions")) {
                        ForEach(mcQuestions) { question in
                            MCQuestionView(
                                question: question,
                                selectedAnswer: Binding(
                                    get: { selectedMCAnswers[question.id] ?? nil },
                                    set: { selectedMCAnswers[question.id] = $0 }
                                )
                            )
                        }
                    }
                }

                if !tfQuestions.isEmpty {
                    Section(header: Text("True/False Questions")) {
                        ForEach(tfQuestions) { question in
                            TFQuestionView(
                                question: question,
                                selectedAnswer: Binding(
                                    get: { selectedTFAnswers[question.id] ?? nil },
                                    set: { selectedTFAnswers[question.id] = $0 }
                                )
                            )
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(lesson.lesson_name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMCQuestions(lessonId: lesson.lesson_id)
            await viewModel.fetchTFQuestions(lessonId: lesson.lesson_id)
        }
    }
}


// MARK: - Detail Screen Helper Views
struct MCQuestionView: View {
    let question: MCQuestion
    @Binding var selectedAnswer: String?
    
    var body: some View {
        Picker(question.question_text, selection: $selectedAnswer) {
            Text(question.option_a).tag(Optional("A"))
            Text(question.option_b).tag(Optional("B"))
            Text(question.option_c).tag(Optional("C"))
            Text(question.option_d).tag(Optional("D"))
        }
        .pickerStyle(.inline)
    }
}

struct TFQuestionView: View {
    let question: TFQuestion
    @Binding var selectedAnswer: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.question_text)
            Picker("Answer", selection: $selectedAnswer) {
                Text("True").tag(Optional(true))
                Text("False").tag(Optional(false))
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 4)
    }
}

// Replace the placeholder EventsList struct

// ✅ Your final code should look exactly like this:

// In ContentView.swift


struct ChatBotView: View {
    var body: some View {
        Text("Chat Bot")
            .navigationTitle("Chat Bot")
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
