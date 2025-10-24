//
//  NutritionEntry.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import Foundation
import SwiftData

@Model
class NutritionEntry {
    var id: UUID
    var date: Date
    var protein: Double
    var calories: Double
    
    init(date: Date = Date(), protein: Double, calories: Double) {
        self.id = UUID()
        self.date = date
        self.protein = protein
        self.calories = calories
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}