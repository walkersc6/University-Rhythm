//
//  Models+ViewModel.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import Foundation

// MARK: - Models

struct Module: Codable, Identifiable {
    let module_id: Int
    let module_name: String
    let time_start: String
    let time_end: String
    let created_at: String

    var id: Int { module_id }
}

struct Lesson: Codable, Identifiable {
    let lesson_id: Int
    let lesson_name: String
    let module_id: Int
    let is_video: Bool
    let lesson: String
    let order_num: Int

    var id: Int { lesson_id }
}

struct MCQuestion: Codable, Identifiable {
    let question_id: Int
    let lesson_id: Int
    let question_text: String
    let option_a: String
    let option_b: String
    let option_c: String
    let option_d: String
    let answer: String

    var id: Int { question_id }
}

struct TFQuestion: Codable, Identifiable {
    let question_id: Int
    let lesson_id: Int
    let question_text: String
    let true_answer: Bool

    var id: Int { question_id }
}

// MARK: - API Response Wrappers (assuming same root key naming)

struct ModulesResponse: Codable {
    let modules: [Module]
}

struct LessonsResponse: Codable {
    let lessons: [Lesson]
}

struct MCQuestionsResponse: Codable {
    let questions: [MCQuestion]
}

struct TFQuestionsResponse: Codable {
    let questions: [TFQuestion]
}

// MARK: - ViewModel

@MainActor
class RoadmapViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var lessons: [Lesson] = []
    @Published var mcQuestions: [MCQuestion] = []
    @Published var tfQuestions: [TFQuestion] = []

    private let baseURL = "http://localhost:8642"
    
    // JSONDecoder setup (no special date decoding needed here since times are Strings)
    private let jsonDecoder = JSONDecoder()

    // Fetch modules
//    func fetchModules() async {
//        guard let url = URL(string: "\(baseURL)/modules") else {
//            print("Invalid modules URL")
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try jsonDecoder.decode(ModulesResponse.self, from: data)
//            modules = response.modules
//        } catch {
//            print("Failed to fetch modules:", error)
//        }
//    }

    func fetchModules() async {
        guard let url = URL(string: "\(baseURL)/modules") else {
            print("❌ Invalid modules URL")
            return
        }
        print("🌐 Fetching modules from:", url.absoluteString)

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Response status:", httpResponse.statusCode)
            }
            print("📦 Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")

            let decoded = try jsonDecoder.decode(ModulesResponse.self, from: data)
            DispatchQueue.main.async {
                self.modules = decoded.modules
                print("✅ Loaded \(decoded.modules.count) modules")
            }
        } catch {
            print("❌ Failed to fetch modules:", error)
        }
    }

    // Fetch lessons for a module
    func fetchLessons(moduleId: Int) async {
        guard let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons") else {
            print("Invalid lessons URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(LessonsResponse.self, from: data)
            lessons = response.lessons
        } catch {
            print("Failed to fetch lessons:", error)
        }
    }
    
    func getLessonsForModule(_ moduleId: Int) -> [Lesson] {
        lessons.filter { $0.module_id == moduleId }
    }

    // Fetch multiple choice questions for a lesson
    func fetchMCQuestions(lessonId: Int) async {
        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/multiple_choice") else {
            print("Invalid MC questions URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(MCQuestionsResponse.self, from: data)
            mcQuestions = response.questions
        } catch {
            print("Failed to fetch MC questions:", error)
        }
    }

    func getMCQuestionsForLesson(_ lessonId: Int) -> [MCQuestion] {
        mcQuestions.filter { $0.lesson_id == lessonId }
    }

    // Fetch true/false questions for a lesson
    func fetchTFQuestions(lessonId: Int) async {
        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/true_false") else {
            print("Invalid TF questions URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(TFQuestionsResponse.self, from: data)
            tfQuestions = response.questions
        } catch {
            print("Failed to fetch TF questions:", error)
        }
    }
    
    func getTFQuestionsForLesson(_ lessonId: Int) -> [TFQuestion] {
        tfQuestions.filter { $0.lesson_id == lessonId }
    }

}



//// MARK: - API Response Models
//struct ModulesResponse: Codable {
//    let modules: [ModuleDTO]
//}
//
//struct ModuleDTO: Codable {
//    let module_id: Int
//    let module_name: String
//    let time_start: String
//    let time_end: String
//    let created_at: String
//}
//
//struct LessonsResponse: Codable {
//    let lessons: [LessonDTO]
//}
//
//struct LessonDTO: Codable {
//    let lesson_id: Int
//    let module_id: Int
//    let is_video: Bool
//    let lesson: String
//    let order_num: Int
//}
//
//struct MCQuestionsResponse: Codable {
//    let questions: [MCQuestionDTO]
//}
//
//struct MCQuestionDTO: Codable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let option_a: String
//    let option_b: String
//    let option_c: String
//    let option_d: String
//    let answer: String
//}
//
//struct TFQuestionsResponse: Codable {
//    let questions: [TFQuestionDTO]
//}
//
//struct TFQuestionDTO: Codable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let true_answer: Bool
//}
//
//// MARK: - App Models
//struct Module: Identifiable {
//    let id: Int
//    let name: String
//    let timeStart: String
//    let timeEnd: String
//}
//
//struct Lesson: Identifiable {
//    let id: Int
//    let moduleId: Int
//    let isVideo: Bool
//    let markdown: String
//    let order: Int
//}
//
//struct MCQuestion: Identifiable {
//    let id: Int
//    let lessonId: Int
//    let questionText: String
//    let optionA: String
//    let optionB: String
//    let optionC: String
//    let optionD: String
//    let answer: String
//}
//
//struct TFQuestion: Identifiable {
//    let id: Int
//    let lessonId: Int
//    let questionText: String
//    let trueAnswer: Bool
//}

//// MARK: - ViewModel
//class RoadmapViewModel: ObservableObject {
//    @Published var modules: [Module] = []
//    @Published var lessons: [Int: [Lesson]] = [:]
//    @Published var mcQuestions: [Int: [MCQuestion]] = [:]
//    @Published var tfQuestions: [Int: [TFQuestion]] = [:]
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private let baseURL: String = "YOUR_API_BASE_URL" // Replace with your actual API URL
//    
//    init() {
//        // Uncomment the line below once you set up your API URL
//        // fetchModules()
//        
//        // For testing, load sample data
//        loadSampleData()
//    }
//    
//    // MARK: - Public Methods
//    func getLessonsForModule(_ moduleId: Int) -> [Lesson] {
//        return (lessons[moduleId] ?? []).sorted { $0.order < $1.order }
//    }
//    
//    func getMCQuestionsForLesson(_ lessonId: Int) -> [MCQuestion] {
//        return mcQuestions[lessonId] ?? []
//    }
//    
//    func getTFQuestionsForLesson(_ lessonId: Int) -> [TFQuestion] {
//        return tfQuestions[lessonId] ?? []
//    }
//    
//    // MARK: - API Calls
//    func fetchModules() {
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = URL(string: "\(baseURL)/modules") else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    self.errorMessage = "Failed to fetch modules: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    self.errorMessage = "No data received"
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(ModulesResponse.self, from: data)
//                    self.modules = response.modules.map { dto in
//                        Module(
//                            id: dto.module_id,
//                            name: dto.module_name,
//                            timeStart: self.formatDate(dto.time_start),
//                            timeEnd: self.formatDate(dto.time_end)
//                        )
//                    }
//                    
//                    // Fetch lessons for each module
//                    for module in self.modules {
//                        self.fetchLessons(for: module.id)
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode modules: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchLessons(for moduleId: Int) {
//        guard let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(LessonsResponse.self, from: data)
//                    self.lessons[moduleId] = response.lessons.map { dto in
//                        Lesson(
//                            id: dto.lesson_id,
//                            moduleId: dto.module_id,
//                            isVideo: dto.is_video,
//                            markdown: dto.lesson,
//                            order: dto.order_num
//                        )
//                    }
//                    
//                    // Fetch questions for each lesson
//                    for lesson in self.lessons[moduleId] ?? [] {
//                        self.fetchMCQuestions(for: lesson.id)
//                        self.fetchTFQuestions(for: lesson.id)
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode lessons: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchMCQuestions(for lessonId: Int) {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/mc-questions") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch MC questions: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(MCQuestionsResponse.self, from: data)
//                    self.mcQuestions[lessonId] = response.questions.map { dto in
//                        MCQuestion(
//                            id: dto.question_id,
//                            lessonId: dto.lesson_id,
//                            questionText: dto.question_text,
//                            optionA: dto.option_a,
//                            optionB: dto.option_b,
//                            optionC: dto.option_c,
//                            optionD: dto.option_d,
//                            answer: dto.answer
//                        )
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode MC questions: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchTFQuestions(for lessonId: Int) {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/tf-questions") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch TF questions: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(TFQuestionsResponse.self, from: data)
//                    self.tfQuestions[lessonId] = response.questions.map { dto in
//                        TFQuestion(
//                            id: dto.question_id,
//                            lessonId: dto.lesson_id,
//                            questionText: dto.question_text,
//                            trueAnswer: dto.true_answer
//                        )
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode TF questions: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    // MARK: - Helper Methods
//    private func formatDate(_ dateString: String) -> String {
//        let formatter = ISO8601DateFormatter()
//        guard let date = formatter.date(from: dateString) else {
//            return dateString
//        }
//        
//        let displayFormatter = DateFormatter()
//        displayFormatter.dateFormat = "MMM dd"
//        return displayFormatter.string(from: date)
//    }
//    
//    // MARK: - Sample Data (for testing)
//    private func loadSampleData() {
//        modules = [
//            Module(id: 1, name: "Before You Start", timeStart: "Aug 01", timeEnd: "Aug 15"),
//            Module(id: 2, name: "Introduction to Programming", timeStart: "Aug 16", timeEnd: "Aug 30"),
//            Module(id: 3, name: "Data Structures", timeStart: "Sep 01", timeEnd: "Sep 15")
//        ]
//        
//        lessons[1] = [
//            Lesson(id: 1, moduleId: 1, isVideo: false, markdown: "**Registration: First-Year Students at BYU**\n\nWelcome to BYU! This lesson will guide you through registering for your first semester.", order: 1),
//            Lesson(id: 2, moduleId: 1, isVideo: false, markdown: "**Housing**\n\nLearn about your housing options, deadlines, and how to submit applications.", order: 2),
//            Lesson(id: 3, moduleId: 1, isVideo: true, markdown: "https://example.com/nso_video", order: 3)
//        ]
//        
//        lessons[2] = [
//            Lesson(id: 4, moduleId: 2, isVideo: false, markdown: "**Variables and Data Types**\n\nLearn about different data types and how to declare variables.", order: 1),
//            Lesson(id: 5, moduleId: 2, isVideo: false, markdown: "**Control Flow Basics**\n\nUnderstand if statements, loops, and conditional logic.", order: 2)
//        ]
//        
//        mcQuestions[1] = [
//            MCQuestion(id: 1, lessonId: 1, questionText: "What is this course about?", optionA: "Programming", optionB: "Math", optionC: "Art", optionD: "Music", answer: "A")
//        ]
//        
//        tfQuestions[1] = [
//            TFQuestion(id: 1, lessonId: 1, questionText: "This course is optional.", trueAnswer: false)
//        ]
//    }
//}

//import Foundation
//
//// MARK: - API Response Models
//struct ModulesResponse: Codable {
//    let modules: [ModuleDTO]
//}
//
//struct ModuleDTO: Codable {
//    let module_id: Int
//    let module_name: String
//    let time_start: String
//    let time_end: String
//    let created_at: String
//}
//
//struct LessonsResponse: Codable {
//    let lessons: [LessonDTO]
//}
//
//struct LessonDTO: Codable {
//    let lesson_id: Int
//    let module_id: Int
//    let is_video: Bool
//    let markdown: String
//    let order: Int
//}
//
//struct MCQuestionsResponse: Codable {
//    let questions: [MCQuestionDTO]
//}
//
//struct MCQuestionDTO: Codable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let option_a: String
//    let option_b: String
//    let option_c: String
//    let option_d: String
//    let answer: String
//}
//
//struct TFQuestionsResponse: Codable {
//    let questions: [TFQuestionDTO]
//}
//
//struct TFQuestionDTO: Codable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let true_answer: Bool
//}
//
//// MARK: - App Models
//struct Module: Identifiable {
//    let id: Int
//    let name: String
//    let timeStart: String
//    let timeEnd: String
//}
//
//struct Lesson: Identifiable {
//    let id: Int
//    let moduleId: Int
//    let isVideo: Bool
//    let markdown: String
//    let order: Int
//}
//
//struct MCQuestion: Identifiable {
//    let id: Int
//    let lessonId: Int
//    let questionText: String
//    let optionA: String
//    let optionB: String
//    let optionC: String
//    let optionD: String
//    let answer: String
//}
//
//struct TFQuestion: Identifiable {
//    let id: Int
//    let lessonId: Int
//    let questionText: String
//    let trueAnswer: Bool
//}
//
//// MARK: - ViewModel
//class RoadmapViewModel: ObservableObject {
//    @Published var modules: [Module] = []
//    @Published var lessons: [Int: [Lesson]] = [:]
//    @Published var mcQuestions: [Int: [MCQuestion]] = [:]
//    @Published var tfQuestions: [Int: [TFQuestion]] = [:]
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private let baseURL: String = "YOUR_API_BASE_URL" // Replace with your actual API URL
//    
//    init() {
//        // Uncomment the line below once you set up your API URL
//        // fetchModules()
//        
//        // For testing, load sample data
//        loadSampleData()
//    }
//    
//    // MARK: - Public Methods
//    func getLessonsForModule(_ moduleId: Int) -> [Lesson] {
//        return (lessons[moduleId] ?? []).sorted { $0.order < $1.order }
//    }
//    
//    func getMCQuestionsForLesson(_ lessonId: Int) -> [MCQuestion] {
//        return mcQuestions[lessonId] ?? []
//    }
//    
//    func getTFQuestionsForLesson(_ lessonId: Int) -> [TFQuestion] {
//        return tfQuestions[lessonId] ?? []
//    }
//    
//    // MARK: - API Calls
//    func fetchModules() {
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = URL(string: "\(baseURL)/modules") else {
//            errorMessage = "Invalid URL"
//            isLoading = false
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                
//                if let error = error {
//                    self.errorMessage = "Failed to fetch modules: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    self.errorMessage = "No data received"
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(ModulesResponse.self, from: data)
//                    self.modules = response.modules.map { dto in
//                        Module(
//                            id: dto.module_id,
//                            name: dto.module_name,
//                            timeStart: self.formatDate(dto.time_start),
//                            timeEnd: self.formatDate(dto.time_end)
//                        )
//                    }
//                    
//                    // Fetch lessons for each module
//                    for module in self.modules {
//                        self.fetchLessons(for: module.id)
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode modules: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchLessons(for moduleId: Int) {
//        guard let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch lessons: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(LessonsResponse.self, from: data)
//                    self.lessons[moduleId] = response.lessons.map { dto in
//                        Lesson(
//                            id: dto.lesson_id,
//                            moduleId: dto.module_id,
//                            isVideo: dto.is_video,
//                            markdown: dto.markdown,
//                            order: dto.order
//                        )
//                    }
//                    
//                    // Fetch questions for each lesson
//                    for lesson in self.lessons[moduleId] ?? [] {
//                        self.fetchMCQuestions(for: lesson.id)
//                        self.fetchTFQuestions(for: lesson.id)
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode lessons: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchMCQuestions(for lessonId: Int) {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/mc-questions") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch MC questions: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(MCQuestionsResponse.self, from: data)
//                    self.mcQuestions[lessonId] = response.questions.map { dto in
//                        MCQuestion(
//                            id: dto.question_id,
//                            lessonId: dto.lesson_id,
//                            questionText: dto.question_text,
//                            optionA: dto.option_a,
//                            optionB: dto.option_b,
//                            optionC: dto.option_c,
//                            optionD: dto.option_d,
//                            answer: dto.answer
//                        )
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode MC questions: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    func fetchTFQuestions(for lessonId: Int) {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/tf-questions") else {
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.errorMessage = "Failed to fetch TF questions: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let data = data else {
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(TFQuestionsResponse.self, from: data)
//                    self.tfQuestions[lessonId] = response.questions.map { dto in
//                        TFQuestion(
//                            id: dto.question_id,
//                            lessonId: dto.lesson_id,
//                            questionText: dto.question_text,
//                            trueAnswer: dto.true_answer
//                        )
//                    }
//                } catch {
//                    self.errorMessage = "Failed to decode TF questions: \(error.localizedDescription)"
//                }
//            }
//        }.resume()
//    }
//    
//    // MARK: - Helper Methods
//    private func formatDate(_ dateString: String) -> String {
//        let formatter = ISO8601DateFormatter()
//        guard let date = formatter.date(from: dateString) else {
//            return dateString
//        }
//        
//        let displayFormatter = DateFormatter()
//        displayFormatter.dateFormat = "MMM dd"
//        return displayFormatter.string(from: date)
//    }
//    
//    // MARK: - Sample Data (for testing)
//    private func loadSampleData() {
//        modules = [
//            Module(id: 1, name: "Before You Start", timeStart: "Aug 01", timeEnd: "Aug 15"),
//            Module(id: 2, name: "Introduction to Programming", timeStart: "Aug 16", timeEnd: "Aug 30"),
//            Module(id: 3, name: "Data Structures", timeStart: "Sep 01", timeEnd: "Sep 15")
//        ]
//        
//        lessons[1] = [
//            Lesson(id: 1, moduleId: 1, isVideo: true, markdown: "Course Overview", order: 1),
//            Lesson(id: 2, moduleId: 1, isVideo: false, markdown: "Getting Started Guide", order: 2)
//        ]
//        
//        lessons[2] = [
//            Lesson(id: 3, moduleId: 2, isVideo: true, markdown: "Variables and Data Types", order: 1),
//            Lesson(id: 4, moduleId: 2, isVideo: false, markdown: "Control Flow Basics", order: 2)
//        ]
//        
//        mcQuestions[1] = [
//            MCQuestion(id: 1, lessonId: 1, questionText: "What is this course about?", optionA: "Programming", optionB: "Math", optionC: "Art", optionD: "Music", answer: "A")
//        ]
//        
//        tfQuestions[1] = [
//            TFQuestion(id: 1, lessonId: 1, questionText: "This course is optional.", trueAnswer: false)
//        ]
//    }
//}

//import Foundation
//
//// MARK: - Models
//struct Module: Identifiable {
//    let id: String
//    let name: String
//    let timeStart: String
//    let timeEnd: String
//}
//
//struct Lesson: Identifiable {
//    let id: String
//    let moduleId: String
//    let isVideo: Bool
//    let markdown: String
//    let order: Int
//}
//
//struct MCQuestion: Identifiable {
//    let id: String
//    let lessonId: String
//    let questionText: String
//    let optionA: String
//    let optionB: String
//    let optionC: String
//    let optionD: String
//    let answer: String
//}
//
//struct TFQuestion: Identifiable {
//    let id: String
//    let lessonId: String
//    let questionText: String
//    let trueAnswer: Bool
//    let answer: Bool
//}
//
//// MARK: - ViewModel
//class RoadmapViewModel: ObservableObject {
//    @Published var modules: [Module] = []
//    @Published var lessons: [String: [Lesson]] = [:]
//    @Published var mcQuestions: [String: [MCQuestion]] = [:]
//    @Published var tfQuestions: [String: [TFQuestion]] = [:]
//    @Published var isLoading: Bool = false
//    
//    init() {
//        loadSampleData()
//    }
//    
//    // MARK: - Public Methods
//    func getLessonsForModule(_ moduleId: String) -> [Lesson] {
//        return (lessons[moduleId] ?? []).sorted { $0.order < $1.order }
//    }
//    
//    func getMCQuestionsForLesson(_ lessonId: String) -> [MCQuestion] {
//        return mcQuestions[lessonId] ?? []
//    }
//    
//    func getTFQuestionsForLesson(_ lessonId: String) -> [TFQuestion] {
//        return tfQuestions[lessonId] ?? []
//    }
//    
//    // MARK: - Data Loading
//    private func loadSampleData() {
//        loadModules()
//        loadLessons()
//        loadQuestions()
//    }
//    
//    private func loadModules() {
//        modules = [
//            Module(id: "M001", name: "Introduction to Programming", timeStart: "Week 1", timeEnd: "Week 4"),
//            Module(id: "M002", name: "Data Structures", timeStart: "Week 5", timeEnd: "Week 8"),
//            Module(id: "M003", name: "Web Development Basics", timeStart: "Week 9", timeEnd: "Week 12")
//        ]
//    }
//    
//    private func loadLessons() {
//        var lessonsDict: [String: [Lesson]] = [:]
//        
//        lessonsDict["M001"] = [
//            Lesson(id: "L001", moduleId: "M001", isVideo: true, markdown: "Introduction to variables and basic syntax", order: 1),
//            Lesson(id: "L002", moduleId: "M001", isVideo: false, markdown: "# Control Flow\n\nLearn about if-statements, loops, and conditional logic.", order: 2),
//            Lesson(id: "L003", moduleId: "M001", isVideo: true, markdown: "Functions and code organization", order: 3)
//        ]
//        
//        lessonsDict["M002"] = [
//            Lesson(id: "L004", moduleId: "M002", isVideo: false, markdown: "# Arrays and Lists\n\nUnderstanding sequential data structures.", order: 1),
//            Lesson(id: "L005", moduleId: "M002", isVideo: true, markdown: "Linked Lists and Pointers", order: 2),
//            Lesson(id: "L006", moduleId: "M002", isVideo: false, markdown: "# Trees and Graphs\n\nHierarchical and networked data structures.", order: 3)
//        ]
//        
//        lessonsDict["M003"] = [
//            Lesson(id: "L007", moduleId: "M003", isVideo: true, markdown: "HTML Fundamentals", order: 1),
//            Lesson(id: "L008", moduleId: "M003", isVideo: false, markdown: "# CSS Styling\n\nMaking websites look great.", order: 2)
//        ]
//        
//        lessons = lessonsDict
//    }
//    
//    private func loadQuestions() {
//        var mcDict: [String: [MCQuestion]] = [:]
//        var tfDict: [String: [TFQuestion]] = [:]
//        
//        mcDict["L001"] = [
//            MCQuestion(id: "MC001", lessonId: "L001", questionText: "What is a variable?", optionA: "A named storage location", optionB: "A function", optionC: "A loop", optionD: "A data type", answer: "A")
//        ]
//        
//        mcDict["L002"] = [
//            MCQuestion(id: "MC002", lessonId: "L002", questionText: "Which statement is used for loops?", optionA: "if", optionB: "for", optionC: "switch", optionD: "case", answer: "B")
//        ]
//        
//        tfDict["L001"] = [
//            TFQuestion(id: "TF001", lessonId: "L001", questionText: "Variables can only store numbers.", trueAnswer: false, answer: false)
//        ]
//        
//        tfDict["L002"] = [
//            TFQuestion(id: "TF002", lessonId: "L002", questionText: "A for loop executes a block of code multiple times.", trueAnswer: true, answer: true)
//        ]
//        
//        mcQuestions = mcDict
//        tfQuestions = tfDict
//    }
//    
//    // MARK: - API Methods (Placeholder for future implementation)
//    func fetchModulesFromAPI() {
//        // Replace with actual API call
//        isLoading = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.isLoading = false
//        }
//    }
//    
//    func fetchLessonsFromAPI(for moduleId: String) {
//        // Replace with actual API call
//        isLoading = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.isLoading = false
//        }
//    }
//}
