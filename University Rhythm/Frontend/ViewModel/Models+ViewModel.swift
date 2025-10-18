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

// MARK: - Quiz Question Models (from /lessons/{id}/questions endpoint)
enum QuestionType: String, Codable {
    case multiple_choice = "multiple_choice"
    case true_false = "true_false"
}

struct QuizQuestion: Codable, Identifiable {
    let type: QuestionType
    let question_id: Int
    let lesson_id: Int
    let question_text: String
    let created_at: String

    // Multiple choice fields
    let a: String?
    let b: String?
    let c: String?
    let d: String?

    // True/False fields
    let true_option: String?
    let false_option: String?

    // Answer can be string (for MC) or bool (for TF)
    let answer: QuizAnswer

    var id: Int { question_id }

    enum CodingKeys: String, CodingKey {
        case type, question_id, lesson_id, question_text, created_at
        case a, b, c, d
        case true_option, false_option
        case answer
    }
}

// Custom enum to handle both string and bool answers
enum QuizAnswer: Codable {
    case string(String)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else {
            throw DecodingError.typeMismatch(
                QuizAnswer.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Answer must be String or Bool")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}

struct AllQuestionsResponse: Codable {
    let questions: [QuizQuestion]
}

// MARK: - User Progress Models
struct UserProgress: Codable {
    let user_id: Int
    let questions_right: [Int]?
    let created_at: String
    let updated_at: String
}

struct UpdateQuestionsRequest: Codable {
    let question_ids: [Int]
}

// MARK: - Module with Lessons Models
struct LessonSummary: Codable, Identifiable {
    let lesson_id: Int
    let lesson_name: String

    var id: Int { lesson_id }
}

struct ModuleWithLessons: Codable, Identifiable {
    let module_id: Int
    let module_name: String
    let time_start: String
    let time_end: String
    let created_at: String
    let lessons: [LessonSummary]

    var id: Int { module_id }
}

struct ModulesWithLessonsResponse: Codable {
    let modules: [ModuleWithLessons]
}

// MARK: - Event Model

// New Model for a single Event
struct Event: Codable, Identifiable {
    let id: String
    let category: String
    let title: String
    let description: String
    let date: String
    let startTime: String
    let endTime: String
    let location: String
    let allDay: Bool
    let createdAt: String
    let updatedAt: String

    var eventStartDate: Date? {
            let dateString = "\(date) \(startTime)"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.current // Use the user's local timezone
            return formatter.date(from: dateString)
        }
    
    var eventEndDate: Date? {
            let dateString = "\(date) \(endTime)"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.current
            return formatter.date(from: dateString)
        }
    // Maps the JSON keys to your Swift properties
    enum CodingKeys: String, CodingKey {
        case id, category, title, description, date, location
        case startTime = "start_time"
        case endTime = "end_time"
        case allDay = "all_day"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
//
//// Wrapper to handle the root "events" key in the JSON
struct EventsResponse: Codable {
    let events: [Event]
}

// MARK: - ViewModel

@MainActor
class RoadmapViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var modulesWithLessons: [ModuleWithLessons] = []
    @Published var lessons: [Lesson] = []
    @Published var mcQuestions: [MCQuestion] = []
    @Published var tfQuestions: [TFQuestion] = []
    @Published var events: [Event] = []

    private let baseURL = "https://possible-stafani-hoco-byu-hack-d9d46b95.koyeb.app"
    
    // JSONDecoder setup (no special date decoding needed here since times are Strings)
    private let jsonDecoder = JSONDecoder()
//    let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601
//            return decoder
//        }()
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
    
    func fetchEvents() async {
            guard let url = URL(string: "\(baseURL)/events") else {
                print("❌ Invalid events URL")
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try jsonDecoder.decode(EventsResponse.self, from: data)
                // Update the 'events' array on the main thread
                self.events = response.events
            } catch {
                print("❌ Failed to fetch or decode events:", error)
            }
        }

    // MARK: - Fetch Modules with Lessons
    func fetchModulesWithLessons() async {
        guard let url = URL(string: "\(baseURL)/modules/with-lessons") else {
            print("❌ Invalid modules-with-lessons URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Server returned error status")
                return
            }

            let decoded = try jsonDecoder.decode(ModulesWithLessonsResponse.self, from: data)
            self.modulesWithLessons = decoded.modules
            print("✅ Loaded \(decoded.modules.count) modules with lessons")
        } catch {
            print("❌ Failed to fetch modules with lessons:", error)
        }
    }

    // Helper to get a specific lesson detail by ID
    func fetchLessonDetail(lessonId: Int) async -> Lesson? {
        // We need to find which module this lesson belongs to first
        // Then fetch from /modules/{module_id}/lessons
        // For now, we'll need to fetch all lessons or implement a single lesson endpoint
        return nil
    }

    // MARK: - Fetch All Questions for Quiz
    func fetchAllQuestions(lessonId: Int) async -> AllQuestionsResponse? {
        guard let url = URL(string: "\(baseURL)/lessons/\(lessonId)/questions") else {
            print("❌ Invalid questions URL")
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Server returned error status")
                return nil
            }

            let decoded = try jsonDecoder.decode(AllQuestionsResponse.self, from: data)
            let mcCount = decoded.questions.filter { $0.type == .multiple_choice }.count
            let tfCount = decoded.questions.filter { $0.type == .true_false }.count
            print("✅ Loaded \(mcCount) MC and \(tfCount) TF questions")
            return decoded
        } catch {
            print("❌ Failed to fetch all questions:", error)
            return nil
        }
    }

    // MARK: - User Progress Management
    func fetchUserProgress(userId: Int = 1) async -> UserProgress? {
        guard let url = URL(string: "\(baseURL)/users/\(userId)/progress") else {
            print("❌ Invalid user progress URL")
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Server returned error status")
                return nil
            }

            let decoded = try jsonDecoder.decode(UserProgress.self, from: data)
            print("✅ Loaded user progress: \(decoded.questions_right?.count ?? 0) questions answered correctly")
            return decoded
        } catch {
            print("❌ Failed to fetch user progress:", error)
            return nil
        }
    }

    func updateUserProgress(userId: Int = 1, questionIds: [Int]) async -> Bool {
        guard let url = URL(string: "\(baseURL)/users/\(userId)/questions") else {
            print("❌ Invalid update questions URL")
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = UpdateQuestionsRequest(question_ids: questionIds)

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ Server returned error status when updating questions")
                return false
            }

            print("✅ Successfully updated user progress with \(questionIds.count) question IDs")
            return true
        } catch {
            print("❌ Failed to update user progress:", error)
            return false
        }
    }

}

