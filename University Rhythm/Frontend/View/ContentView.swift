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
    @State private var floatUp = false
    
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
                    endPoint: .bottomTrailing)
//                Color.softGreen.ignoresSafeArea()
                
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
                        ZStack(alignment: .bottom) {
                            // Mountain background
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
                                
//                                context.fill(
//                                    path,
//                                    with: .linearGradient(
//                                        Gradient(colors: [
//                                            Color(red: 0.4, green: 0.6, blue: 0.3),
//                                            Color(red: 0.5, green: 0.7, blue: 0.4),
//                                            Color(red: 0.8, green: 0.8, blue: 0.8)
//                                        ]),
//                                        startPoint: CGPoint(x: 0.5, y: 0),
//                                        endPoint: CGPoint(x: 0.5, y: 1)
//                                    )
//                                )
                            }
                            .frame(height: 1000)
                            
                            // Trail path
                            Canvas { context, size in
                                var path = Path()
                                path.move(to: CGPoint(x: size.width / 2, y: size.height))
                                path.addCurve(
                                    to: CGPoint(x: size.width / 2, y: 100),
                                    control1: CGPoint(x: size.width * 0.2, y: size.height * 0.7),
                                    control2: CGPoint(x: size.width * 0.8, y: size.height * 0.3)
                                )
                                context.stroke(
                                    path,
                                    with: .color(Color.white.opacity(0.7)),
                                    lineWidth: 4
                                )
                            }
                            .frame(height: 1000)

                            // Content on the mountain
                            VStack(alignment: .center, spacing: 60) {
                                ForEach(viewModel.modules) { module in
                                    MountainModuleSection(module: module, viewModel: viewModel)
                                }
                                Spacer(minLength: 80)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        .frame(height: 1000)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Mountain Module Section
struct MountainModuleSection: View {
    let module: Module
    @ObservedObject var viewModel: RoadmapViewModel
    
    var sortedLessons: [Lesson] {
        viewModel.getLessonsForModule(module.id)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Module name marker
            VStack(spacing: 4) {
//                Text("Stage")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
                Text(module.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 140)
//                    .offset(y:150)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.vertical, 20)
            .offset(y: 150)
            
            // Lessons alternating left/right
            VStack(alignment: .center, spacing: 40) {
                ForEach(Array(sortedLessons.enumerated()), id: \.element.id) { index, lesson in
                    HStack(alignment: .center, spacing: 0) {
                        if index % 2 == 0 {
                            NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                                MountainLessonBubble(lesson: lesson)
                            }
                            .padding(.leading, 40)
                            Spacer()
                        } else {
                            Spacer()
                            NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
                                MountainLessonBubble(lesson: lesson)
                            }
                            .padding(.trailing, 40)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

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
                
                Image(systemName: lesson.isVideo ? "video.fill" : "book.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            
            Text(lesson.markdown.split(separator: "\n").first.map(String.init) ?? "Lesson")
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
                            Image(systemName: lesson.is_Video ? "video.fill" : "doc.fill")
                                .foregroundColor(.blue)
                            Text(lesson.isVideo ? "Video Lesson" : "Text Lesson")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Text(lesson.markdown)
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

//struct MCQuestionView: View {
//    let question: MCQuestion
//    @Binding var selectedAnswer: String?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(question.questionText)
//                .font(.subheadline)
//                .fontWeight(.semibold)
//            
//            ForEach([("A", question.optionA), ("B", question.optionB), ("C", question.optionC), ("D", question.optionD)], id: \.0) { key, option in
//                Button(action: { selectedAnswer = key }) {
//                    HStack(spacing: 12) {
//                        Image(systemName: selectedAnswer == key ? "checkmark.circle.fill" : "circle")
//                            .foregroundColor(selectedAnswer == key ? .blue : .gray)
//                        Text(option)
//                            .foregroundColor(.primary)
//                        Spacer()
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 4)
//    }
//}

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

extension Color {
    static let softGreen = Color(red: 200/255, green: 230/255, blue: 201/255) // Pastel Green
}

#Preview {
    ContentView()
}

//import SwiftUI
//
//// MARK: - Main Content View
//struct ContentView: View {
//    @StateObject private var viewModel = RoadmapViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Mountain background gradient
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
//                        Text("Your Learning Journey")
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .padding(.top, 20)
//                            .padding(.bottom, 40)
//                        
//                        // Mountain climb visualization
//                        if !viewModel.modules.isEmpty {
//                            MountainClimbView(modules: viewModel.modules, viewModel: viewModel)
//                        }
//                        
//                        Spacer(minLength: 40)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - Mountain Climb View
//struct MountainClimbView: View {
//    let modules: [Module]
//    @ObservedObject var viewModel: RoadmapViewModel
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Mountain background shape
//            Canvas { context, size in
//                var path = Path()
//                path.move(to: CGPoint(x: 0, y: size.height))
//                path.addCurve(
//                    to: CGPoint(x: size.width, y: size.height),
//                    control1: CGPoint(x: size.width * 0.3, y: size.height * 0.2),
//                    control2: CGPoint(x: size.width * 0.7, y: size.height * 0.2)
//                )
//                path.addLine(to: CGPoint(x: size.width, y: size.height))
//                path.addLine(to: CGPoint(x: 0, y: size.height))
//                path.closeSubpath()
//                
//                context.fill(
//                    path,
//                    with: .linearGradient(
//                        Gradient(colors: [
//                            Color(red: 0.4, green: 0.6, blue: 0.3),
//                            Color(red: 0.5, green: 0.7, blue: 0.4),
//                            Color(red: 0.8, green: 0.8, blue: 0.8)
//                        ]),
//                        startPoint: CGPoint(x: 0.5, y: 0),
//                        endPoint: CGPoint(x: 0.5, y: 1)
//                    )
//                )
//            }
//            .frame(height: 900)
//            
//            // Trail path on the mountain
//            Canvas { context, size in
//                var path = Path()
//                path.move(to: CGPoint(x: size.width / 2, y: size.height))
//                path.addCurve(
//                    to: CGPoint(x: size.width / 2, y: 50),
//                    control1: CGPoint(x: size.width * 0.2, y: size.height * 0.7),
//                    control2: CGPoint(x: size.width * 0.8, y: size.height * 0.3)
//                )
//                context.stroke(
//                    path,
//                    with: .color(Color.white.opacity(0.7)),
//                    lineWidth: 4
//                )
//            }
//            .frame(height: 900)
//            
//            // Module checkpoints
//            VStack(alignment: .center, spacing: 90) {
//                // Summit flag at top
//                VStack {
//                    Image(systemName: "flag.2.crossed.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.red)
//                    Text("Summit")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                }
//                .padding(.top, 40)
//                
//                // Modules from bottom to top
//                ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
//                    NavigationLink(destination: ModuleDetailView(module: module, viewModel: viewModel)) {
//                        MountainCheckpoint(
//                            module: module,
//                            position: index,
//                            totalModules: modules.count,
//                            lessonsCount: viewModel.getLessonsForModule(module.id).count
//                        )
//                    }
//                }
//                
//                Spacer(minLength: 60)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        }
//        .frame(height: 900)
//    }
//}
//
//// MARK: - Mountain Checkpoint
//struct MountainCheckpoint: View {
//    let module: Module
//    let position: Int
//    let totalModules: Int
//    let lessonsCount: Int
//    
//    var isLeft: Bool {
//        position % 2 == 0
//    }
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 0) {
//            if isLeft {
//                // Left side checkpoint
//                VStack(alignment: .trailing, spacing: 8) {
//                    Text("Stage \(position + 1)")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.secondary)
//                    
//                    Text(module.name)
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                        .lineLimit(2)
//                        .multilineTextAlignment(.trailing)
//                    
//                    HStack(spacing: 12) {
//                        Label("\(lessonsCount)", systemImage: "book.fill")
//                            .font(.caption)
//                        Label(module.timeStart, systemImage: "calendar")
//                            .font(.caption)
//                    }
//                    .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: 140, alignment: .trailing)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 4)
//            }
//            
//            // Center checkpoint circle
//            VStack {
//                Image(systemName: "mountain.2.fill")
//                    .font(.system(size: 32))
//                    .foregroundColor(.orange)
//                    .background(
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 70, height: 70)
//                    )
//            }
//            .frame(width: 70)
//            
//            if !isLeft {
//                // Right side checkpoint
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Stage \(position + 1)")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.secondary)
//                    
//                    Text(module.name)
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                        .lineLimit(2)
//                        .multilineTextAlignment(.leading)
//                    
//                    HStack(spacing: 12) {
//                        Label("\(lessonsCount)", systemImage: "book.fill")
//                            .font(.caption)
//                        Label(module.timeStart, systemImage: "calendar")
//                            .font(.caption)
//                    }
//                    .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: 140, alignment: .leading)
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 4)
//            }
//        }
//    }
//}
//
//// MARK: - Module Detail View
//struct ModuleDetailView: View {
//    let module: Module
//    @ObservedObject var viewModel: RoadmapViewModel
//    @Environment(\.dismiss) var dismiss
//    
//    var sortedLessons: [Lesson] {
//        viewModel.getLessonsForModule(module.id)
//    }
//    
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.87, green: 0.95, blue: 1.0),
//                    Color(red: 0.7, green: 0.85, blue: 1.0)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    // Header card
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text(module.name)
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                HStack(spacing: 16) {
//                                    Label(module.timeStart, systemImage: "calendar")
//                                    Label(module.timeEnd, systemImage: "flag.fill")
//                                }
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            }
//                            Spacer()
//                            Image(systemName: "mountain.2.fill")
//                                .font(.system(size: 40))
//                                .foregroundColor(.orange)
//                        }
//                    }
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(16)
//                    .shadow(radius: 6)
//                    .padding()
//                    
//                    // Lessons section
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Lessons to Complete")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .padding(.horizontal)
//                        
//                        VStack(spacing: 12) {
//                            ForEach(Array(sortedLessons.enumerated()), id: \.element.id) { index, lesson in
//                                NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
//                                    LessonClimbRow(lesson: lesson, position: index + 1, total: sortedLessons.count)
//                                }
//                            }
//                        }
//                        .padding()
//                    }
//                    
//                    Spacer(minLength: 40)
//                }
//            }
//        }
//        .navigationTitle("Checkpoint")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Lesson Climb Row
//struct LessonClimbRow: View {
//    let lesson: Lesson
//    let position: Int
//    let total: Int
//    
//    var progressPercent: Double {
//        Double(position) / Double(total)
//    }
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            HStack(spacing: 12) {
//                // Progress circle
//                ZStack {
//                    Circle()
//                        .trim(from: 0, to: progressPercent)
//                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
//                        .rotationEffect(.degrees(-90))
//                    
//                    Text("\(position)")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
//                }
//                .frame(width: 50, height: 50)
//                
//                // Lesson info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(lesson.markdown.split(separator: "\n").first.map(String.init) ?? "Lesson")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    HStack(spacing: 8) {
//                        Image(systemName: lesson.isVideo ? "video.fill" : "doc.fill")
//                            .font(.caption)
//                        Text(lesson.isVideo ? "Video" : "Reading")
//                            .font(.caption)
//                    }
//                    .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.secondary)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(radius: 4)
//            
//            // Progress bar
//            ProgressView(value: progressPercent)
//                .tint(.blue)
//                .padding(.horizontal)
//        }
//    }
//}
//
//// MARK: - Lesson Detail View
//struct LessonDetailView: View {
//    let lesson: Lesson
//    @ObservedObject var viewModel: RoadmapViewModel
//    @State private var selectedMCAnswers: [Int: String] = [:]
//    @State private var selectedTFAnswers: [Int: Bool] = [:]
//    
//    var mcQuestions: [MCQuestion] {
//        viewModel.getMCQuestionsForLesson(lesson.id)
//    }
//    
//    var tfQuestions: [TFQuestion] {
//        viewModel.getTFQuestionsForLesson(lesson.id)
//    }
//    
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.87, green: 0.95, blue: 1.0),
//                    Color(red: 0.7, green: 0.85, blue: 1.0)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    // Lesson Content
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack(spacing: 8) {
//                            Image(systemName: lesson.isVideo ? "video.fill" : "doc.fill")
//                                .foregroundColor(.blue)
//                            Text(lesson.isVideo ? "Video Lesson" : "Text Lesson")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                        }
//                        
//                        Text(lesson.markdown)
//                            .font(.body)
//                            .lineLimit(nil)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.white)
//                    .cornerRadius(12)
//                    .shadow(radius: 4)
//                    
//                    // Multiple Choice Questions
//                    if !mcQuestions.isEmpty {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Multiple Choice Questions")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                            
//                            ForEach(mcQuestions) { question in
//                                MCQuestionView(question: question, selectedAnswer: $selectedMCAnswers[question.id])
//                            }
//                        }
//                        .padding()
//                    }
//                    
//                    // True/False Questions
//                    if !tfQuestions.isEmpty {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("True/False Questions")
//                                .font(.headline)
//                                .fontWeight(.bold)
//                            
//                            ForEach(tfQuestions) { question in
//                                TFQuestionView(question: question, selectedAnswer: $selectedTFAnswers[question.id])
//                            }
//                        }
//                        .padding()
//                    }
//                    
//                    Spacer(minLength: 40)
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("Lesson")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - MC Question View
//struct MCQuestionView: View {
//    let question: MCQuestion
//    @Binding var selectedAnswer: String?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(question.questionText)
//                .font(.subheadline)
//                .fontWeight(.semibold)
//            
//            ForEach([("A", question.optionA), ("B", question.optionB), ("C", question.optionC), ("D", question.optionD)], id: \.0) { key, option in
//                Button(action: { selectedAnswer = key }) {
//                    HStack(spacing: 12) {
//                        Image(systemName: selectedAnswer == key ? "checkmark.circle.fill" : "circle")
//                            .foregroundColor(selectedAnswer == key ? .blue : .gray)
//                        Text(option)
//                            .foregroundColor(.primary)
//                        Spacer()
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 4)
//    }
//}
//
//// MARK: - TF Question View
//struct TFQuestionView: View {
//    let question: TFQuestion
//    @Binding var selectedAnswer: Bool?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(question.questionText)
//                .font(.subheadline)
//                .fontWeight(.semibold)
//            
//            HStack(spacing: 12) {
//                Button(action: { selectedAnswer = true }) {
//                    HStack {
//                        Image(systemName: selectedAnswer == true ? "checkmark.circle.fill" : "circle")
//                            .foregroundColor(selectedAnswer == true ? .green : .gray)
//                        Text("True")
//                            .foregroundColor(.primary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(selectedAnswer == true ? Color.green.opacity(0.15) : Color(.systemGray6))
//                    .cornerRadius(8)
//                }
//                
//                Button(action: { selectedAnswer = false }) {
//                    HStack {
//                        Image(systemName: selectedAnswer == false ? "checkmark.circle.fill" : "circle")
//                            .foregroundColor(selectedAnswer == false ? .red : .gray)
//                        Text("False")
//                            .foregroundColor(.primary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(selectedAnswer == false ? Color.red.opacity(0.15) : Color(.systemGray6))
//                    .cornerRadius(8)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 4)
//    }
//}
//
//#Preview {
//    ContentView()
//}
