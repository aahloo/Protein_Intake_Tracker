//
//  ProfileCreationView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/23/25.
//

import SwiftUI
import SwiftData

struct ProfileCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingProfiles: [UserProfile]
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Profile inputs
    @State private var selectedSex: Sex = .male
    @State private var age = ""
    @State private var heightFeet = 5
    @State private var heightInches = 8
    @State private var weight = ""
    @State private var selectedActivityLevel: ActivityLevel = .moderatelyActive
    @State private var selectedFocus: Focus = .maintenance
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCreating = false
    
    @Binding var currentUser: UserProfile?
    
    // Height options
    private let feetOptions = Array(4...7)
    private let inchesOptions = Array(0...11)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    accountSection
                    
                    profileInputsSection
                    
                    createButton
                }
                .padding()
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Profile Creation", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Personal Nutrition Profile")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                }
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
    
    private var profileInputsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Personal Information")
                .font(.headline)
                .foregroundColor(.blue)
            
            // Sex Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Sex")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 20) {
                    ForEach(Sex.allCases, id: \.self) { sex in
                        Button(action: { selectedSex = sex }) {
                            HStack {
                                Image(systemName: selectedSex == sex ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.blue)
                                Text(sex.rawValue)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            // Age Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Age")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    TextField("Age", text: $age)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                    
                    Text("years")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Height Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Height")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(feetOptions, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Inches", selection: $heightInches) {
                        ForEach(inchesOptions, id: \.self) { inches in
                            Text("\(inches) in").tag(inches)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Spacer()
                }
            }
            
            // Weight Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "scalemass")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    TextField("Weight", text: $weight)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(maxWidth: 120)
                    
                    Text("lbs")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Activity Level Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity Level")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Activity Level", selection: $selectedActivityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.shortDescription).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Focus Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Focus")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Focus", selection: $selectedFocus) {
                    ForEach(Focus.allCases, id: \.self) { focus in
                        Text(focus.rawValue).tag(focus)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var createButton: some View {
        Button(action: createProfile) {
            HStack {
                if isCreating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(isCreating ? "Creating Profile..." : "Create Profile")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding()
            .background(isFormValid ? Color.blue : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isCreating)
        .accessibilityLabel("Create user profile with entered information")
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !age.isEmpty &&
        Int(age) != nil &&
        !weight.isEmpty &&
        Double(weight) != nil
    }
    
    private func createProfile() {
        isCreating = true
        
        // Check if username already exists
        if existingProfiles.contains(where: { $0.username == username }) {
            alertMessage = "Username already exists. Please choose a different username."
            showingAlert = true
            isCreating = false
            return
        }
        
        // Validate inputs
        guard let ageInt = Int(age), ageInt > 0, ageInt < 120,
              let weightDouble = Double(weight), weightDouble > 0 else {
            alertMessage = "Please enter valid age and weight values."
            showingAlert = true
            isCreating = false
            return
        }
        
        // Create new profile
        let newProfile = UserProfile(username: username, passwordHash: password)
        newProfile.sex = selectedSex
        newProfile.age = ageInt
        newProfile.heightFeet = heightFeet
        newProfile.heightInches = heightInches
        newProfile.weightLbs = weightDouble
        newProfile.activityLevel = selectedActivityLevel
        newProfile.focus = selectedFocus
        newProfile.calculateMetrics()
        
        modelContext.insert(newProfile)
        currentUser = newProfile
        
        alertMessage = "Profile created successfully! Welcome, \(username)!"
        showingAlert = true
        isCreating = false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    @State var currentUser: UserProfile? = nil
    
    return ProfileCreationView(currentUser: $currentUser)
        .modelContainer(container)
}