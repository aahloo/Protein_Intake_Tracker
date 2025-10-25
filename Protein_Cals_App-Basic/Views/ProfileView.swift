//
//  ProfileView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/23/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    let userProfile: UserProfile
    @Binding var currentUser: UserProfile?
    
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeaderSection
                    
                    personalInfoSection
                    
                    calculatedMetricsSection
                    
                    dailyTargetsSection
                    
                    actionButtonsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userProfile: userProfile)
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(userProfile.username)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Member since \(userProfile.createdDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .foregroundColor(.blue)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                InfoCard(title: "Sex", value: userProfile.sex.rawValue, icon: "person")
                InfoCard(title: "Age", value: "\(userProfile.age) years", icon: "calendar")
                InfoCard(title: "Height", value: userProfile.heightString, icon: "ruler")
                InfoCard(title: "Weight", value: userProfile.weightString, icon: "scalemass")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(userProfile.activityLevel.shortDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Focus")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(userProfile.focus.rawValue)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var calculatedMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calculated Metrics")
                .font(.headline)
                .foregroundColor(.blue)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "BMR",
                    value: "\(String(format: "%.0f", userProfile.bmr))",
                    subtitle: "calories/day",
                    icon: "heart.fill",
                    color: .red
                )
                
                MetricCard(
                    title: "TDEE",
                    value: "\(String(format: "%.0f", userProfile.tdee))",
                    subtitle: "calories/day",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var dailyTargetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Targets")
                .font(.headline)
                .foregroundColor(.blue)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Protein Target",
                    value: "\(String(format: "%.1f", userProfile.dailyProteinTarget))",
                    subtitle: "grams",
                    icon: "building.2.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Calorie Target",
                    value: "\(String(format: "%.0f", userProfile.dailyCalorieTarget))",
                    subtitle: "calories",
                    icon: "target",
                    color: .green
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button("Edit Profile") {
                showingEditProfile = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            
            Button("Logout") {
                showingLogoutAlert = true
            }
            .font(.headline)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func logout() {
        userProfile.isLoggedIn = false
        currentUser = nil
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Placeholder for EditProfileView
struct EditProfileView: View {
    let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Edit Profile - Coming Soon")
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    let sampleProfile = UserProfile(username: "John Doe", passwordHash: "test")
    container.mainContext.insert(sampleProfile)
    
    @State var currentUser: UserProfile? = sampleProfile
    
    return ProfileView(userProfile: sampleProfile, currentUser: $currentUser)
        .modelContainer(container)
}