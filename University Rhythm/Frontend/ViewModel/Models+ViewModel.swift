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

//// New Model for a single Event
//struct Event: Codable, Identifiable {
//    let id: String
//    let category: String
//    let title: String
//    let description: String
//    let date: String
//    let startTime: String
//    let endTime: String
//    let location: String
//    let allDay: Bool
//    let createdAt: Date
//    let updatedAt: Date
//
//    // Maps the JSON keys to your Swift properties
//    enum CodingKeys: String, CodingKey {
//        case id, category, title, description, date, location
//        case startTime = "start_time"
//        case endTime = "end_time"
//        case allDay = "all_day"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//    }
//}
//
//// Wrapper to handle the root "events" key in the JSON
//struct EventsResponse: Codable {
//    let events: [Event]
//}

// MARK: - ViewModel

@MainActor
class RoadmapViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var lessons: [Lesson] = []
    @Published var mcQuestions: [MCQuestion] = []
    @Published var tfQuestions: [TFQuestion] = []

    private let baseURL = "https://possible-stafani-hoco-byu-hack-d9d46b95.koyeb.app"
    
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

