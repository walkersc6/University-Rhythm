//
//  ContentView.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import SwiftUI

// The PreferenceKey for path drawing remains the same.
struct PathPreferenceKey: PreferenceKey {
    typealias Value = [Anchor<CGPoint>]
    static var defaultValue: [Anchor<CGPoint>] = []

    static func reduce(value: inout [Anchor<CGPoint>], nextValue: () -> [Anchor<CGPoint>]) {
        value.append(contentsOf: nextValue())
    }
}


// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = RoadmapViewModel()
    @State private var floatUp = false
    @State private var pathAnchors: [Anchor<CGPoint>] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Sky background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.87, green: 0.95, blue: 1.0),
                        Color(red: 0.7, green: 0.85, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        
                        // Floating header
                        ZStack {
                            Text("Your Learning Journey")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.top, 60)
                                .padding(.bottom, 50)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 70)
                        .onAppear { floatUp.toggle() }

                        // Mountain with trail
                        ZStack {
                            // Layer 1 (Back): Mountain background
                            Canvas { context, size in
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: size.height))
                                path.addCurve(
                                    to: CGPoint(x: size.width, y: size.height),
                                    control1: CGPoint(x: size.width * 0.3, y: size.height * 0.2),
                                    control2: CGPoint(x: size.width * 0.7, y: size.height * 0.2)
                                )
                                path.addLine(to: CGPoint(x: size.width, y: size.height))
                                path.addLine(to: CGPoint(x: 0, y: size.height))
                                path.closeSubpath()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // +++ Layer 2 (Middle): The path, moved here from the .overlay +++
                            GeometryReader { geometry in
                                Canvas { context, size in
                                    guard pathAnchors.count > 1 else { return }
                                    
                                    var path = Path()
                                    let firstPoint = geometry[pathAnchors[0]]
                                    path.move(to: firstPoint)
                                    
                                    for i in 1..<pathAnchors.count {
                                        let point = geometry[pathAnchors[i]]
                                        path.addLine(to: point)
                                    }
                                    
                                    context.stroke(
                                        path,
                                        with: .color(Color.white.opacity(0.7)),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                                    )
                                }
                            }

                            // Layer 3 (Front): Module titles and lesson bubbles
                            VStack(alignment: .center, spacing: 40) {
                                ForEach(viewModel.modules) { module in
                                    ModuleTitleView(name: module.module_name)
                                    LessonsForModuleView(moduleId: module.module_id, viewModel: viewModel)
                                }
                                Spacer(minLength: 80)
                            }
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                        // --- The .overlay modifier has been removed ---
                        .coordinateSpace(name: "path")
                        .onPreferenceChange(PathPreferenceKey.self) { anchors in
                            self.pathAnchors = anchors
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.fetchModules()
        }
    }
}
//struct ContentView: View {
//    @StateObject private var viewModel = RoadmapViewModel()
//    @State private var floatUp = false
//    @State private var pathAnchors: [Anchor<CGPoint>] = []
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Sky background
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(red: 0.87, green: 0.95, blue: 1.0),
//                        Color(red: 0.7, green: 0.85, blue: 1.0)
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(alignment: .center, spacing: 0) {
//                        
//                        // Floating header
//                        ZStack {
//                            Text("Your Learning Journey")
//                                .font(.system(size: 32, weight: .bold, design: .rounded))
//                                .foregroundColor(.primary)
//                                .padding(.top, 60)
//                                .padding(.bottom, 50)
//                        }
//                        .padding(.top, 60)
//                        .padding(.bottom, 70)
//                        .onAppear { floatUp.toggle() }
//
//                        // Mountain with trail
//                        ZStack {
//                            // Mountain background
//                            Canvas { context, size in
//                                var path = Path()
//                                path.move(to: CGPoint(x: 0, y: size.height))
//                                path.addCurve(
//                                    to: CGPoint(x: size.width, y: size.height),
//                                    control1: CGPoint(x: size.width * 0.3, y: size.height * 0.2),
//                                    control2: CGPoint(x: size.width * 0.7, y: size.height * 0.2)
//                                )
//                                path.addLine(to: CGPoint(x: size.width, y: size.height))
//                                path.addLine(to: CGPoint(x: 0, y: size.height))
//                                path.closeSubpath()
//                            }
//                            // Using .infinity for maxHeight allows the view to grow with content
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            
//                            // +++ 1. Restructured VStack for the new sequential layout +++
//                            VStack(alignment: .center, spacing: 40) {
//                                ForEach(viewModel.modules) { module in
//                                    // First, display the module title card
//                                    ModuleTitleView(name: module.module_name)
//                                    
//                                    // Second, display the lessons associated with that module
//                                    LessonsForModuleView(moduleId: module.module_id, viewModel: viewModel)
//                                }
//                                Spacer(minLength: 80)
//                            }
//                            .padding(.top, 40) // Adjust top padding as needed
//                            .frame(maxWidth: .infinity, alignment: .top)
//                        }
//                        // The overlay for path drawing remains the same
//                        .overlay(
//                            GeometryReader { geometry in
//                                Canvas { context, size in
//                                    guard pathAnchors.count > 1 else { return }
//                                    
//                                    var path = Path()
//                                    let firstPoint = geometry[pathAnchors[0]]
//                                    path.move(to: firstPoint)
//                                    
//                                    for i in 1..<pathAnchors.count {
//                                        let point = geometry[pathAnchors[i]]
//                                        path.addLine(to: point)
//                                    }
//                                    
//                                    context.stroke(
//                                        path,
//                                        with: .color(Color.white.opacity(0.7)),
//                                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
//                                    )
//                                }
//                            }
//                        )
//                        .coordinateSpace(name: "path")
//                        .onPreferenceChange(PathPreferenceKey.self) { anchors in
//                            self.pathAnchors = anchors
//                        }
//                        
//                        Spacer(minLength: 40)
//                    }
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//        }
//        .task {
//            await viewModel.fetchModules()
//        }
//    }
//}


// +++ 2. New, separate view for the module title card +++
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
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}


// +++ 3. New, separate view to fetch and display lessons for a specific module +++
// In ContentView.swift

// +++ Corrected view to ensure lessons are fetched and displayed +++
struct LessonsForModuleView: View {
    let moduleId: Int
    @ObservedObject var viewModel: RoadmapViewModel
    
    private var sortedLessons: [Lesson] {
        viewModel.getLessonsForModule(moduleId)
            .sorted { $0.order_num < $1.order_num }
    }
    
    var body: some View {
        // By wrapping the ForEach in a VStack, we give this view a permanent
        // place in the layout, which allows .onAppear to fire reliably.
        VStack(spacing: 40) {
            ForEach(Array(sortedLessons.enumerated()), id: \.element.id) { index, lesson in
                HStack(alignment: .center, spacing: 0) {
                    if index % 2 == 0 {
                        NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                            MountainLessonBubble(lesson: lesson)
                                .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                        }
                        .padding(.leading, 40)
                        Spacer()
                    } else {
                        Spacer()
                        NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                            MountainLessonBubble(lesson: lesson)
                                .anchorPreference(key: PathPreferenceKey.self, value: .center) { [$0] }
                        }
                        .padding(.trailing, 40)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchLessons(moduleId: moduleId)
            }
        }
    }
}

// --- The old MountainModuleSection has been replaced by the two views above ---


//
// The rest of the file (MountainLessonBubble, LessonDetailView, etc.)
// remains unchanged.
//

// MARK: - Mountain Lesson Bubble
struct MountainLessonBubble: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.blue.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 6)
                
                Image(systemName: lesson.is_video ? "video.fill" : "book.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            
            Text(lesson.lesson_name.split(separator: "\n").first.map(String.init) ?? "Lesson")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 90)
        }
    }
}

#Preview {
    ContentView()
}



// MARK: - Lesson Detail View
struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var viewModel: RoadmapViewModel
    @State private var selectedMCAnswers: [Int: String] = [:]
    @State private var selectedTFAnswers: [Int: Bool] = [:]
    
    var mcQuestions: [MCQuestion] {
        viewModel.getMCQuestionsForLesson(lesson.lesson_id)
    }
    
    var tfQuestions: [TFQuestion] {
        viewModel.getTFQuestionsForLesson(lesson.lesson_id)
    }
    
    var body: some View {
        ZStack {
            Image("astronaut")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.4),
                    Color.white.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Lesson content
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: lesson.is_video ? "video.fill" : "doc.fill")
                                .foregroundColor(.blue)
                            Text(lesson.is_video ? "Video Lesson" : "Text Lesson")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Text(lesson.lesson)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    // MC questions
                    if !mcQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Multiple Choice Questions")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(mcQuestions) { question in
                                MCQuestionView(question: question, selectedAnswer: $selectedMCAnswers[question.id])
                            }
                        }
                        .padding()
                    }
                    
                    // TF questions
                    if !tfQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("True/False Questions")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(tfQuestions) { question in
                                TFQuestionView(question: question, selectedAnswer: $selectedTFAnswers[question.id])
                            }
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // As recommended previously, fetch questions when this view appears!
            await viewModel.fetchMCQuestions(lessonId: lesson.lesson_id)
            await viewModel.fetchTFQuestions(lessonId: lesson.lesson_id)
        }
    }
}

// MARK: - MC Question View
struct MCQuestionView: View {
    let question: MCQuestion
    @Binding var selectedAnswer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question_text)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach([("A", question.option_a), ("B", question.option_b), ("C", question.option_c), ("D", question.option_d)], id: \.0) { key, option in
                Button(action: { selectedAnswer = key }) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedAnswer == key ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAnswer == key ? .blue : .gray)
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}


// MARK: - TF Question View
struct TFQuestionView: View {
    let question: TFQuestion
    @Binding var selectedAnswer: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.question_text)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                Button(action: { selectedAnswer = true }) {
                    HStack {
                        Image(systemName: selectedAnswer == true ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAnswer == true ? .green : .gray)
                        Text("True")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAnswer == true ? Color.green.opacity(0.15) : Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Button(action: { selectedAnswer = false }) {
                    HStack {
                        Image(systemName: selectedAnswer == false ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAnswer == false ? .red : .gray)
                        Text("False")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAnswer == false ? Color.red.opacity(0.15) : Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
