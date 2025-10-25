//
//  DailyTrackingView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/22/25.
//

import SwiftUI
import SwiftData

struct DailyTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NutritionEntry.date, order: .reverse) private var entries: [NutritionEntry]
    
    let userProfile: UserProfile
    
    @State private var proteinInput = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Auto-calculate calories: 4 calories per gram of protein
    private var calculatedCalories: Double {
        guard let protein = Double(proteinInput), protein > 0 else { return 0 }
        return protein * 4.0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection
                
                dailyTargetsSection
                
                inputSection
                
                addEntryButton
                
                todaysEntriesSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Daily Nutrition")
            .alert("Entry Added", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Track Your Nutrition")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    private var dailyTargetsSection: some View {
        VStack(spacing: 12) {
            Text("Your Daily Targets")
                .font(.headline)
                .foregroundColor(.blue)
            
            HStack(spacing: 20) {
                // Daily Protein Target
                VStack(spacing: 4) {
                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(String(format: "%.1f", userProfile.dailyProteinTarget))g")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Protein Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Daily Calorie Target  
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("\(String(format: "%.0f", userProfile.dailyCalorieTarget))")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Calorie Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                
                TextField("Protein (grams)", text: $proteinInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Protein intake in grams")
                    .accessibilityHint("Enter the amount of protein consumed")
            }
            
            // Display calculated calories (read-only)
            HStack {
                Image(systemName: "flame")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calculated Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.0f", calculatedCalories)) calories")
                        .font(.body)
                        .foregroundColor(calculatedCalories > 0 ? .primary : .secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var addEntryButton: some View {
        Button(action: addEntry) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .accessibilityHidden(true)
                Text("Add Entry")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // Ensure minimum touch target size per HIG
            .padding()
            .background(proteinInput.isEmpty ? Color.gray : Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .disabled(proteinInput.isEmpty)
        .accessibilityLabel("Add nutrition entry")
        .accessibilityHint("Adds the entered protein with auto-calculated calories to your daily tracking")
        .accessibilityAddTraits(.isButton)
    }
    
    private var todaysEntriesSection: some View {
        Group {
            if !todaysEntries().isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Entries")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(todaysEntries()) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: "building.2")
                                                .foregroundColor(.blue)
                                            Text("\(String(format: "%.1f", entry.protein))g protein")
                                        }
                                        .font(.subheadline)
                                        
                                        HStack {
                                            Image(systemName: "flame")
                                                .foregroundColor(.orange)
                                            Text("\(String(format: "%.0f", entry.calories)) calories")
                                        }
                                        .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(timeString(from: entry.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
    
    private func addEntry() {
        guard let protein = Double(proteinInput), protein > 0 else {
            alertMessage = "Please enter a valid protein amount"
            showingAlert = true
            return
        }
        
        let calories = calculatedCalories
        let newEntry = NutritionEntry(protein: protein, calories: calories)
        modelContext.insert(newEntry)
        
        alertMessage = "Added \(String(format: "%.1f", protein))g protein (\(String(format: "%.0f", calories)) auto-calculated calories)"
        showingAlert = true
        
        // Clear inputs
        proteinInput = ""
        
        // Dismiss keyboard
        hideKeyboard()
    }
    
    private func todaysEntries() -> [NutritionEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NutritionEntry.self, UserProfile.self, configurations: config)
    
    let sampleProfile = UserProfile(username: "preview", passwordHash: "test")
    container.mainContext.insert(sampleProfile)
    
    return DailyTrackingView(userProfile: sampleProfile)
        .modelContainer(container)
}