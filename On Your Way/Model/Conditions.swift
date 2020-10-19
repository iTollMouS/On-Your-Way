//
//  Conditions.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/19/20.
//

enum Conditions: String, CaseIterable, Codable {
    case success
    case warning
    case error
    
    var JSONStringName: String {
        switch self {
        case .success : return "success_motion"
        case .warning : return "warning_animation"
        case .error : return "New_error"
        }
    }
}
