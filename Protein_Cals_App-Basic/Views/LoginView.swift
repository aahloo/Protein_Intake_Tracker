//
//  LoginView.swift
//  Protein_Cals_App-Basic
//
//  Created by Austin Ah Loo on 10/23/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var username = ""
    @State private var password = ""
    @State private var showingCreateProfile = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoggingIn = false
    
    @Binding var currentUser: UserProfile?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                headerSection
                
                loginForm
                
                actionButtons
                
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.large)
            .alert("Login Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingCreateProfile) {
                ProfileCreationView(currentUser: $currentUser)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Protein & Calorie Tracker")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Track your personalized nutrition goals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("Username")
            }
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Password")
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: login) {
                HStack {
                    if isLoggingIn {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    Text(isLoggingIn ? "Logging In..." : "Login")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding()
                .background(username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(12)
            }
            .disabled(username.isEmpty || password.isEmpty || isLoggingIn)
            .accessibilityLabel("Login to your account")
            
            Button("Create New Profile") {
                showingCreateProfile = true
            }
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .accessibilityLabel("Create a new user profile")
        }
    }
    
    private func login() {
        isLoggingIn = true
        
        // Simple authentication (in production, use proper password hashing)
        if let user = profiles.first(where: { $0.username == username && $0.passwordHash == password }) {
            user.isLoggedIn = true
            user.lastUpdated = Date()
            currentUser = user
            
            alertMessage = "Welcome back, \(username)!"
            showingAlert = true
        } else {
            alertMessage = "Invalid username or password"
            showingAlert = true
        }
        
        isLoggingIn = false
        
        // Clear password for security
        password = ""
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    @State var currentUser: UserProfile? = nil
    
    return LoginView(currentUser: $currentUser)
        .modelContainer(container)
}