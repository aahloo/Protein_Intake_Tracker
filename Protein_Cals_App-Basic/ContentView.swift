//
//  ContentView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DailyTrackingView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Track")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
            
            SummaryView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Summary")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NutritionEntry.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
