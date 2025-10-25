//
//  UserProfile.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/23/25.
//

import Foundation
import SwiftData

@Model
class UserProfile {
    var id: UUID
    var username: String
    var passwordHash: String // In production, use proper password hashing
    var isLoggedIn: Bool
    
    // Profile inputs
    var sex: Sex
    var age: Int
    var heightFeet: Int
    var heightInches: Int
    var weightLbs: Double
    var activityLevel: ActivityLevel
    var focus: Focus
    
    // Calculated values
    var bmr: Double
    var tdee: Double
    var dailyProteinTarget: Double
    var dailyCalorieTarget: Double
    
    var createdDate: Date
    var lastUpdated: Date
    
    init(username: String, passwordHash: String) {
        self.id = UUID()
        self.username = username
        self.passwordHash = passwordHash
        self.isLoggedIn = true
        
        // Default values
        self.sex = .male
        self.age = 30
        self.heightFeet = 5
        self.heightInches = 8
        self.weightLbs = 150.0
        self.activityLevel = .moderatelyActive
        self.focus = .maintenance
        
        // Initialize calculated values
        self.bmr = 0.0
        self.tdee = 0.0
        self.dailyProteinTarget = 0.0
        self.dailyCalorieTarget = 0.0
        
        self.createdDate = Date()
        self.lastUpdated = Date()
        
        // Calculate initial values
        calculateMetrics()
    }
    
    // MARK: - Calculations
    
    func calculateMetrics() {
        calculateBMR()
        calculateTDEE()
        calculateDailyTargets()
        lastUpdated = Date()
    }
    
    private func calculateBMR() {
        let weightKg = weightLbs * 0.453592 // Convert lbs to kg
        let heightCm = Double(heightFeet * 12 + heightInches) * 2.54 // Convert feet/inches to cm
        
        switch sex {
        case .male:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        case .female:
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        }
    }
    
    private func calculateTDEE() {
        tdee = bmr * activityLevel.multiplier
    }
    
    private func calculateDailyTargets() {
        let weightKg = weightLbs * 0.453592 // Convert lbs to kg
        
        // Protein calculation based on focus (using weight in kg)
        dailyProteinTarget = weightKg * focus.proteinMultiplier
        
        // Calorie calculation based on focus
        dailyCalorieTarget = tdee + focus.calorieAdjustment
    }
    
    // MARK: - Helper Properties
    
    var heightString: String {
        return "\(heightFeet)'\(heightInches)\""
    }
    
    var weightString: String {
        return String(format: "%.1f lbs", weightLbs)
    }
}

// MARK: - Enums

enum Sex: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary (little to no exercise)"
    case lightlyActive = "Lightly active (daily walks, light resistance work 1-3 days/week)"
    case moderatelyActive = "Moderately active (moderate intensity workouts 3-5 days/week)"
    case veryActive = "Very active (high intensity strength and/or HIIT 5-7 days a week)"
    case superActive = "Super active (high level sports athlete or physical collision occupation)"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .superActive: return 1.9
        }
    }
    
    var shortDescription: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .lightlyActive: return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive: return "Very Active"
        case .superActive: return "Super Active"
        }
    }
}

enum Focus: String, CaseIterable, Codable {
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
    case fatLoss = "Fat Loss"
    
    var proteinMultiplier: Double {
        switch self {
        case .maintenance: return 1.5
        case .muscleGain: return 2.2
        case .fatLoss: return 2.4
        }
    }
    
    var calorieAdjustment: Double {
        switch self {
        case .maintenance: return 0
        case .muscleGain: return 300
        case .fatLoss: return -300
        }
    }
}
