//
//  UniversityModel.swift
//  University Rhythm
//
//  Created by Sarah Walker on 10/17/25.
//

import Foundation

struct UniversityModel: Codable {

    struct Modules {
        var module_id: Int
        var module_name: String
        var time_start: Date
        var time_end: Date
    }
    
    struct Lessons {
        var lesson_id: Int
    }
}
