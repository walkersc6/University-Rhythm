//
//  Models+ViewModel.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

//
//  Models+ViewModel.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import Foundation

// MARK: - Models (No changes needed here)

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

// MARK: - API Response Wrappers (No changes needed here)

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
    
    // +++ 1. Store lessons and questions in dictionaries to prevent overwriting. +++
    @Published var lessonsByModule: [Int: [Lesson]] = [:]
    @Published var mcQuestionsByLesson: [Int: [MCQuestion]] = [:]
    @Published var tfQuestionsByLesson: [Int: [TFQuestion]] = [:]

    private let baseURL = "http://localhost:8642"
    private let jsonDecoder = JSONDecoder()

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
            let decoded = try jsonDecoder.decode(ModulesResponse.self, from: data)
            self.modules = decoded.modules
            print("✅ Loaded \(decoded.modules.count) modules")
        } catch {
            print("❌ Failed to fetch modules:", error)
        }
    }

    // +++ 2. Update fetchLessons to populate the dictionary. +++
    func fetchLessons(moduleId: Int) async {
        // Optimization: Don't re-fetch if we already have the data for this module.
        if lessonsByModule[moduleId] != nil { return }
        
        guard let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons") else {
            print("Invalid lessons URL for module \(moduleId)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(LessonsResponse.self, from: data)
            // Add the fetched lessons to the dictionary using the module ID as the key.
            lessonsByModule[moduleId] = response.lessons
        } catch {
            print("Failed to fetch lessons for module \(moduleId):", error)
        }
    }
    
    // +++ 3. Update the getter to read from the dictionary. +++
    func getLessonsForModule(_ moduleId: Int) -> [Lesson] {
        // Return the lessons for the specific module, or an empty array if none are found.
        return lessonsByModule[moduleId] ?? []
    }

    // +++ 4. Apply the same dictionary pattern to MC questions. +++
    func fetchMCQuestions(lessonId: Int) async {
        if mcQuestionsByLesson[lessonId] != nil { return }
        
        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/multiple_choice") else {
            print("Invalid MC questions URL for lesson \(lessonId)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(MCQuestionsResponse.self, from: data)
            mcQuestionsByLesson[lessonId] = response.questions
        } catch {
            print("Failed to fetch MC questions for lesson \(lessonId):", error)
        }
    }

    func getMCQuestionsForLesson(_ lessonId: Int) -> [MCQuestion] {
        return mcQuestionsByLesson[lessonId] ?? []
    }

    // +++ 5. Apply the same dictionary pattern to TF questions. +++
    func fetchTFQuestions(lessonId: Int) async {
        if tfQuestionsByLesson[lessonId] != nil { return }
        
        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/true_false") else {
            print("Invalid TF questions URL for lesson \(lessonId)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try jsonDecoder.decode(TFQuestionsResponse.self, from: data)
            tfQuestionsByLesson[lessonId] = response.questions
        } catch {
            print("Failed to fetch TF questions for lesson \(lessonId):", error)
        }
    }
    
    func getTFQuestionsForLesson(_ lessonId: Int) -> [TFQuestion] {
        return tfQuestionsByLesson[lessonId] ?? []
    }
}
//
//import Foundation
//
//// MARK: - Models
//
//struct Module: Codable, Identifiable {
//    let module_id: Int
//    let module_name: String
//    let time_start: String
//    let time_end: String
//    let created_at: String
//
//    var id: Int { module_id }
//}
//
//struct Lesson: Codable, Identifiable {
//    let lesson_id: Int
//    let lesson_name: String
//    let module_id: Int
//    let is_video: Bool
//    let lesson: String
//    let order_num: Int
//
//    var id: Int { lesson_id }
//}
//
//struct MCQuestion: Codable, Identifiable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let option_a: String
//    let option_b: String
//    let option_c: String
//    let option_d: String
//    let answer: String
//
//    var id: Int { question_id }
//}
//
//struct TFQuestion: Codable, Identifiable {
//    let question_id: Int
//    let lesson_id: Int
//    let question_text: String
//    let true_answer: Bool
//
//    var id: Int { question_id }
//}
//
//// MARK: - API Response Wrappers (assuming same root key naming)
//
//struct ModulesResponse: Codable {
//    let modules: [Module]
//}
//
//struct LessonsResponse: Codable {
//    let lessons: [Lesson]
//}
//
//struct MCQuestionsResponse: Codable {
//    let questions: [MCQuestion]
//}
//
//struct TFQuestionsResponse: Codable {
//    let questions: [TFQuestion]
//}
//
//// MARK: - ViewModel
//
//@MainActor
//class RoadmapViewModel: ObservableObject {
//    @Published var modules: [Module] = []
//    @Published var lessons: [Lesson] = []
//    @Published var mcQuestions: [MCQuestion] = []
//    @Published var tfQuestions: [TFQuestion] = []
//
//    private let baseURL = "http://localhost:8642"
//    
//    // JSONDecoder setup (no special date decoding needed here since times are Strings)
//    private let jsonDecoder = JSONDecoder()
//
//    // Fetch modules
////    func fetchModules() async {
////        guard let url = URL(string: "\(baseURL)/modules") else {
////            print("Invalid modules URL")
////            return
////        }
////        do {
////            let (data, _) = try await URLSession.shared.data(from: url)
////            let response = try jsonDecoder.decode(ModulesResponse.self, from: data)
////            modules = response.modules
////        } catch {
////            print("Failed to fetch modules:", error)
////        }
////    }
//
//    func fetchModules() async {
//        guard let url = URL(string: "\(baseURL)/modules") else {
//            print("❌ Invalid modules URL")
//            return
//        }
//        print("🌐 Fetching modules from:", url.absoluteString)
//
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//            if let httpResponse = response as? HTTPURLResponse {
//                print("✅ Response status:", httpResponse.statusCode)
//            }
//            print("📦 Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
//
//            let decoded = try jsonDecoder.decode(ModulesResponse.self, from: data)
//            DispatchQueue.main.async {
//                self.modules = decoded.modules
//                print("✅ Loaded \(decoded.modules.count) modules")
//            }
//        } catch {
//            print("❌ Failed to fetch modules:", error)
//        }
//    }
//
//    // Fetch lessons for a module
//    func fetchLessons(moduleId: Int) async {
//        guard let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons") else {
//            print("Invalid lessons URL")
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try jsonDecoder.decode(LessonsResponse.self, from: data)
//            lessons = response.lessons
//        } catch {
//            print("Failed to fetch lessons:", error)
//        }
//    }
//    
//    func getLessonsForModule(_ moduleId: Int) -> [Lesson] {
//        lessons.filter { $0.module_id == moduleId }
//    }
//
//    // Fetch multiple choice questions for a lesson
//    func fetchMCQuestions(lessonId: Int) async {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/multiple_choice") else {
//            print("Invalid MC questions URL")
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try jsonDecoder.decode(MCQuestionsResponse.self, from: data)
//            mcQuestions = response.questions
//        } catch {
//            print("Failed to fetch MC questions:", error)
//        }
//    }
//
//    func getMCQuestionsForLesson(_ lessonId: Int) -> [MCQuestion] {
//        mcQuestions.filter { $0.lesson_id == lessonId }
//    }
//
//    // Fetch true/false questions for a lesson
//    func fetchTFQuestions(lessonId: Int) async {
//        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions/true_false") else {
//            print("Invalid TF questions URL")
//            return
//        }
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let response = try jsonDecoder.decode(TFQuestionsResponse.self, from: data)
//            tfQuestions = response.questions
//        } catch {
//            print("Failed to fetch TF questions:", error)
//        }
//    }
//    
//    func getTFQuestionsForLesson(_ lessonId: Int) -> [TFQuestion] {
//        tfQuestions.filter { $0.lesson_id == lessonId }
//    }
//
//}

