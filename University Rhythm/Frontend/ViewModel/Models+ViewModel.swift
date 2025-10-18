//
//  Models+ViewModel.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import Foundation

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

// MARK: - ViewModel
class RoadmapViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var lessons: [String: [Lesson]] = [:]
    @Published var mcQuestions: [String: [MCQuestion]] = [:]
    @Published var tfQuestions: [String: [TFQuestion]] = [:]
    @Published var isLoading: Bool = false
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Public Methods
    func getLessonsForModule(_ moduleId: String) -> [Lesson] {
        return (lessons[moduleId] ?? []).sorted { $0.order < $1.order }
    }
    
    func getMCQuestionsForLesson(_ lessonId: String) -> [MCQuestion] {
        return mcQuestions[lessonId] ?? []
    }
    
    func getTFQuestionsForLesson(_ lessonId: String) -> [TFQuestion] {
        return tfQuestions[lessonId] ?? []
    }
    
    // MARK: - Data Loading
    private func loadSampleData() {
        loadModules()
        loadLessons()
        loadQuestions()
    }
    
    private func loadModules() {
        modules = [
            Module(id: "M001", name: "Introduction to Programming", timeStart: "Week 1", timeEnd: "Week 4"),
            Module(id: "M002", name: "Data Structures", timeStart: "Week 5", timeEnd: "Week 8"),
            Module(id: "M003", name: "Web Development Basics", timeStart: "Week 9", timeEnd: "Week 12")
        ]
    }
    
    private func loadLessons() {
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
    
    private func loadQuestions() {
        var mcDict: [String: [MCQuestion]] = [:]
        var tfDict: [String: [TFQuestion]] = [:]
        
        mcDict["L001"] = [
            MCQuestion(id: "MC001", lessonId: "L001", questionText: "What is a variable?", optionA: "A named storage location", optionB: "A function", optionC: "A loop", optionD: "A data type", answer: "A")
        ]
        
        mcDict["L002"] = [
            MCQuestion(id: "MC002", lessonId: "L002", questionText: "Which statement is used for loops?", optionA: "if", optionB: "for", optionC: "switch", optionD: "case", answer: "B")
        ]
        
        tfDict["L001"] = [
            TFQuestion(id: "TF001", lessonId: "L001", questionText: "Variables can only store numbers.", trueAnswer: false, answer: false)
        ]
        
        tfDict["L002"] = [
            TFQuestion(id: "TF002", lessonId: "L002", questionText: "A for loop executes a block of code multiple times.", trueAnswer: true, answer: true)
        ]
        
        mcQuestions = mcDict
        tfQuestions = tfDict
    }
    
    // MARK: - API Methods (Placeholder for future implementation)
    func fetchModulesFromAPI() {
        // Replace with actual API call
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    func fetchLessonsFromAPI(for moduleId: String) {
        // Replace with actual API call
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
}
