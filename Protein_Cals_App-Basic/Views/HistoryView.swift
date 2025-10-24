//
//  HistoryView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NutritionEntry.date, order: .reverse) private var entries: [NutritionEntry]
    
    var body: some View {
        NavigationView {
            Group {
                if entries.isEmpty {
                    emptyStateView
                } else {
                    entriesList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Entries Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Start tracking your protein intake to see your history here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    private var entriesList: some View {
        List {
            ForEach(groupedEntries, id: \.0) { date, entries in
                Section(header: sectionHeader(for: date)) {
                    ForEach(entries) { entry in
                        entryRow(entry)
                    }
                    .onDelete { indexSet in
                        deleteEntries(at: indexSet, from: entries)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(dateString(for: date))
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            let dayEntries = entriesForDate(date)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.1f", dayEntries.reduce(0) { $0 + $1.protein }))g protein")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("\(String(format: "%.0f", dayEntries.reduce(0) { $0 + $1.calories })) cal")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func entryRow(_ entry: NutritionEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text("Protein: \(String(format: "%.1f", entry.protein))g")
                        .font(.body)
                }
                
                HStack {
                    Image(systemName: "flame")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    
                    Text("Calories: \(String(format: "%.0f", entry.calories))")
                        .font(.body)
                }
            }
            
            Spacer()
            
            Text(timeString(for: entry.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var groupedEntries: [(Date, [NutritionEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
            .map { (key, value) in
                (key, value.sorted { $0.date > $1.date })
            }
    }
    
    private func entriesForDate(_ date: Date) -> [NutritionEntry] {
        entries.filter { 
            Calendar.current.isDate($0.date, inSameDayAs: date) 
        }
    }
    
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func deleteEntries(at indexSet: IndexSet, from dayEntries: [NutritionEntry]) {
        for index in indexSet {
            let entryToDelete = dayEntries[index]
            modelContext.delete(entryToDelete)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NutritionEntry.self, configurations: config)
    
    // Add sample data
    let entry1 = NutritionEntry(protein: 25.5, calories: 350)
    let entry2 = NutritionEntry(protein: 30.0, calories: 420)
    container.mainContext.insert(entry1)
    container.mainContext.insert(entry2)
    
    return HistoryView()
        .modelContainer(container)
}
