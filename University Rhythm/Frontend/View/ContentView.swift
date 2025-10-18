//
//  ContentView.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import SwiftUI

// MARK: - Models
struct Module: Identifiable {
    let id: String
    let name: String
    let timeStart: String
    let timeEnd: String
}

struct Lesson: Identifiable {
    let id: String
    let moduleId: String
    let isVideo: Bool
    let markdown: String
    let order: Int
}

struct MCQuestion: Identifiable {
    let id: String
    let lessonId: String
    let questionText: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let answer: String
}

struct TFQuestion: Identifiable {
    let id: String
    let lessonId: String
    let questionText: String
    let trueAnswer: Bool
    let answer: Bool
}

// MARK: - Main View
struct ContentView: View {
    @State private var modules: [Module] = []
    @State private var selectedModule: Module?
    @State private var lessons: [String: [Lesson]] = [:]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Module Roadmap")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(modules) { module in
                        NavigationLink(destination: ModuleDetailView(module: module, lessons: lessons[module.id] ?? [])) {
                            ModuleCard(module: module)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Sample modules
        modules = [
            Module(id: "M001", name: "Introduction to Programming", timeStart: "Week 1", timeEnd: "Week 4"),
            Module(id: "M002", name: "Data Structures", timeStart: "Week 5", timeEnd: "Week 8"),
            Module(id: "M003", name: "Web Development Basics", timeStart: "Week 9", timeEnd: "Week 12")
        ]
        
        // Sample lessons for each module
        var lessonsDict: [String: [Lesson]] = [:]
        
        lessonsDict["M001"] = [
            Lesson(id: "L001", moduleId: "M001", isVideo: true, markdown: "Introduction to variables and basic syntax", order: 1),
            Lesson(id: "L002", moduleId: "M001", isVideo: false, markdown: "# Control Flow\n\nLearn about if-statements, loops, and conditional logic.", order: 2),
            Lesson(id: "L003", moduleId: "M001", isVideo: true, markdown: "Functions and code organization", order: 3)
        ]
        
        lessonsDict["M002"] = [
            Lesson(id: "L004", moduleId: "M002", isVideo: false, markdown: "# Arrays and Lists\n\nUnderstanding sequential data structures.", order: 1),
            Lesson(id: "L005", moduleId: "M002", isVideo: true, markdown: "Linked Lists and Pointers", order: 2),
            Lesson(id: "L006", moduleId: "M002", isVideo: false, markdown: "# Trees and Graphs\n\nHierarchical and networked data structures.", order: 3)
        ]
        
        lessonsDict["M003"] = [
            Lesson(id: "L007", moduleId: "M003", isVideo: true, markdown: "HTML Fundamentals", order: 1),
            Lesson(id: "L008", moduleId: "M003", isVideo: false, markdown: "# CSS Styling\n\nMaking websites look great.", order: 2)
        ]
        
        lessons = lessonsDict
    }
}

// MARK: - Module Card
struct ModuleCard: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("\(module.timeStart) - \(module.timeEnd)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// MARK: - Module Detail View
struct ModuleDetailView: View {
    let module: Module
    let lessons: [Lesson]
    @State private var selectedLesson: Lesson?
    @Environment(\.dismiss) var dismiss
    
    var sortedLessons: [Lesson] {
        lessons.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(module.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(module.timeStart) - \(module.timeEnd)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lessons (\(sortedLessons.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(sortedLessons) { lesson in
                        NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                            LessonRow(lesson: lesson, lessonNumber: sortedLessons.firstIndex(where: { $0.id == lesson.id })! + 1)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Module")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: Lesson
    let lessonNumber: Int
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .center) {
                Text("\(lessonNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)
            .background(Color.blue)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lesson.markdown.split(separator: "\n").first.map(String.init) ?? "Lesson")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: lesson.isVideo ? "video.fill" : "doc.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray5), lineWidth: 1))
    }
}

// MARK: - Lesson Detail View
struct LessonDetailView: View {
    let lesson: Lesson
    @State private var mcQuestions: [MCQuestion] = []
    @State private var tfQuestions: [TFQuestion] = []
    @State private var selectedMCAnswers: [String: String] = [:]
    @State private var selectedTFAnswers: [String: Bool] = [:]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Lesson Content
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: lesson.isVideo ? "video.fill" : "doc.fill")
                            .foregroundColor(.blue)
                        Text(lesson.isVideo ? "Video Lesson" : "Text Lesson")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    Text(lesson.markdown)
                        .font(.body)
                        .lineLimit(nil)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Multiple Choice Questions
                if !mcQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Multiple Choice Questions")
                            .font(.headline)
                        
                        ForEach(mcQuestions) { question in
                            MCQuestionView(question: question, selectedAnswer: $selectedMCAnswers[question.id])
                        }
                    }
                    .padding()
                }
                
                // True/False Questions
                if !tfQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("True/False Questions")
                            .font(.headline)
                        
                        ForEach(tfQuestions) { question in
                            TFQuestionView(question: question, selectedAnswer: $selectedTFAnswers[question.id])
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSampleQuestions()
        }
    }
    
    private func loadSampleQuestions() {
        mcQuestions = [
            MCQuestion(id: "MC001", lessonId: lesson.id, questionText: "What is a variable?", optionA: "A named storage location", optionB: "A function", optionC: "A loop", optionD: "A data type", answer: "A")
        ]
        
        tfQuestions = [
            TFQuestion(id: "TF001", lessonId: lesson.id, questionText: "Variables can only store numbers.", trueAnswer: false, answer: false)
        ]
    }
}

// MARK: - MC Question View
struct MCQuestionView: View {
    let question: MCQuestion
    @Binding var selectedAnswer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach([("A", question.optionA), ("B", question.optionB), ("C", question.optionC), ("D", question.optionD)], id: \.0) { key, option in
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
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - TF Question View
struct TFQuestionView: View {
    let question: TFQuestion
    @Binding var selectedAnswer: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.questionText)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                Button(action: { selectedAnswer = true }) {
                    HStack {
                        Image(systemName: selectedAnswer == true ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedAnswer == true ? .green : .gray)
                        Text("True")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedAnswer == true ? Color.green.opacity(0.1) : Color(.systemGray6))
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
                    .background(selectedAnswer == false ? Color.red.opacity(0.1) : Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
