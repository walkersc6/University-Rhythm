//
//  ContentView.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import SwiftUI



import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = RoadmapViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Module Roadmap")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(viewModel.modules) { module in
                            NavigationLink(destination: ModuleDetailView(module: module, viewModel: viewModel)) {
                                ModuleCard(module: module)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Module Card View
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
    @ObservedObject var viewModel: RoadmapViewModel
    
    var sortedLessons: [Lesson] {
        viewModel.getLessonsForModule(module.id)
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
                        NavigationLink(destination: LessonDetailView(lesson: lesson, viewModel: viewModel)) {
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

// MARK: - Lesson Row View
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
    @ObservedObject var viewModel: RoadmapViewModel
    @State private var selectedMCAnswers: [String: String] = [:]
    @State private var selectedTFAnswers: [String: Bool] = [:]
    
    var mcQuestions: [MCQuestion] {
        viewModel.getMCQuestionsForLesson(lesson.id)
    }
    
    var tfQuestions: [TFQuestion] {
        viewModel.getTFQuestionsForLesson(lesson.id)
    }
    
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
