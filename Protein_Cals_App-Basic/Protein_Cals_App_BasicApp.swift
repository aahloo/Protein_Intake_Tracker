//
//  Protein_Cals_App_BasicApp.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

@main
struct Protein_Cals_App_BasicApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NutritionEntry.self,
            UserProfile.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
