//
//  ContentView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var currentUser: UserProfile?
    
    var body: some View {
        Group {
            if let user = currentUser {
                TabView {
                    DailyTrackingView(userProfile: user)
                        .tabItem {
                            Image(systemName: "plus.circle")
                            Text("Track")
                        }
                    
                    HistoryView()
                        .tabItem {
                            Image(systemName: "clock")
                            Text("History")
                        }
                    
                    SummaryView(userProfile: user)
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Summary")
                        }
                    
                    ProfileView(userProfile: user, currentUser: $currentUser)
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }
                .accentColor(.blue)
            } else {
                LoginView(currentUser: $currentUser)
            }
        }
        .onAppear {
            checkForLoggedInUser()
        }
    }
    
    private func checkForLoggedInUser() {
        if let loggedInUser = profiles.first(where: { $0.isLoggedIn }) {
            currentUser = loggedInUser
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NutritionEntry.self, UserProfile.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
