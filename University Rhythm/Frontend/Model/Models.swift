////
////  UniversityModel.swift
////  University Rhythm
////
////  Created by Sarah Walker on 10/17/25.
////
//
//import Foundation
//
//struct Models: Codable {
//
//    // MARK: - Models
//    struct Module: Identifiable {
//        let id: String
//        let name: String
//        let timeStart: String
//        let timeEnd: String
//    }
//
//    struct Lesson: Identifiable {
//        let id: String
//        let moduleId: String
//        let isVideo: Bool
//        let markdown: String
//        let order: Int
//    }
//
//    struct MCQuestion: Identifiable {
//        let id: String
//        let lessonId: String
//        let questionText: String
//        let optionA: String
//        let optionB: String
//        let optionC: String
//        let optionD: String
//        let answer: String
//    }
//
//    struct TFQuestion: Identifiable {
//        let id: String
//        let lessonId: String
//        let questionText: String
//        let trueAnswer: Bool
//        let answer: Bool
//    }
//}
