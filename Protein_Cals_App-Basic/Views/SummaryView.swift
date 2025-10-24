//
//  SummaryView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NutritionEntry.date, order: .reverse) private var entries: [NutritionEntry]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if entries.isEmpty {
                        emptyStateView
                    } else {
                        overallStatsSection
                        
                        weeklyStatsSection
                        
                        goalsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Data Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Start tracking your nutrition to see your summary statistics here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 60)
    }
    
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Statistics")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Total Entries",
                    value: "\(entries.count)",
                    icon: "list.number",
                    color: .green
                )
                
                StatCard(
                    title: "Days Tracked",
                    value: "\(uniqueDaysCount)",
                    icon: "calendar",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Protein/Day",
                    value: String(format: "%.1f", averageProtein) + "g",
                    icon: "building.2",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Calories/Day",
                    value: String(format: "%.0f", averageCalories),
                    icon: "flame",
                    color: .orange
                )
            }
        }
    }
    
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.title2)
                .fontWeight(.semibold)
            
            let weekData = currentWeekData()
            
            if !weekData.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Week Protein",
                        value: "\(String(format: "%.1f", weekData.reduce(0) { $0 + $1.protein }))g",
                        icon: "building.2.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Week Calories",
                        value: "\(String(format: "%.0f", weekData.reduce(0) { $0 + $1.calories }))",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                
                weeklyChart(data: weekData)
                    .padding(.top)
            } else {
                Text("No entries this week")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Goals")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                let todaysProtein = todaysTotal().protein
                let todaysCalories = todaysTotal().calories
                
                GoalProgressView(
                    title: "Protein Goal",
                    current: todaysProtein,
                    goal: 50.0, // Example goal
                    unit: "g",
                    color: .blue
                )
                
                GoalProgressView(
                    title: "Calorie Goal",
                    current: todaysCalories,
                    goal: 2000.0, // Example goal
                    unit: "cal",
                    color: .orange
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }
    
    private var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }
    
    private var averageProtein: Double {
        guard !entries.isEmpty else { return 0 }
        return totalProtein / Double(entries.count)
    }
    
    private var averageCalories: Double {
        guard !entries.isEmpty else { return 0 }
        return totalCalories / Double(entries.count)
    }
    
    private var uniqueDaysCount: Int {
        let uniqueDays = Set(entries.map { 
            Calendar.current.startOfDay(for: $0.date) 
        })
        return uniqueDays.count
    }
    
    private func currentWeekData() -> [NutritionEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return entries.filter { $0.date >= weekAgo }
    }
    
    private func todaysTotal() -> (protein: Double, calories: Double) {
        let todaysEntries = entries.filter { 
            Calendar.current.isDateInToday($0.date) 
        }
        
        let protein = todaysEntries.reduce(0) { $0 + $1.protein }
        let calories = todaysEntries.reduce(0) { $0 + $1.calories }
        
        return (protein, calories)
    }
    
    private func weeklyChart(data: [NutritionEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Protein This Week")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(last7Days().enumerated()), id: \.offset) { index, date in
                    let dayProtein = data.filter { 
                        Calendar.current.isDate($0.date, inSameDayAs: date) 
                    }.reduce(0) { $0 + $1.protein }
                    
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 30, height: max(4, dayProtein / 2)) // Scale height
                            .cornerRadius(4)
                        
                        Text(dayAbbreviation(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        var days: [Date] = []
        
        for i in (1...6).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                days.append(date)
            }
        }
        days.append(Date()) // Today
        
        return days
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else {
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct GoalProgressView: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(String(format: "%.1f", current)) / \(String(format: "%.0f", goal)) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(progress * 100))% of daily goal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NutritionEntry.self, configurations: config)
    
    // Add sample data
    let entry1 = NutritionEntry(protein: 25.5, calories: 350)
    let entry2 = NutritionEntry(protein: 30.0, calories: 420)
    let entry3 = NutritionEntry(protein: 20.0, calories: 280)
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    container.mainContext.insert(entry3)
    
    return SummaryView()
        .modelContainer(container)
}
