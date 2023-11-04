//
//  ForgotPasswordView.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    // MARK: Properties
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var isSurveyListPresented = false
    
    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                
                VStack(spacing: 20) {
                    Image("nimble_logo")
                        .resizable()
                        .frame(width: 160, height: 40)
                    
                    Text("Enter your email to receive instructions for resetting your password.")
                        .foregroundStyle(.gray)
                        .padding(.bottom, 120)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray.opacity(0.3))
                        
                        TextField("", text: $email, prompt: Text("Email")
                            .foregroundColor(Color.gray))
                        .keyboardType(.emailAddress)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    } // ZStack
                    .frame(height: 40)
                    .padding(.horizontal)
                    
                    // MARK: - Login button
                    /// Use
                    /// your_email@example.com
                    Button {
                        performPasswordRecovery()
                    } label: {
                        Text("Reset")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    // TODO: - Implement validation (email valid)
                    .disabled(email.isEmpty)
                    .foregroundColor(.black)
                    .accentColor(.white)
                    .buttonStyle(.borderedProminent)
                    .padding()
                } // VStack
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
            } // ZStack
            .ignoresSafeArea()
            .navigationBarHidden(true)
        } // Nav
    }
    
    // MARK: - Functions
    private func performPasswordRecovery() {
        let email = email
        let clientId = Constants.clientId
        let clientSecret = Constants.clientSecret
        
        guard let url = URL(string: "\(Constants.baseUrl)/api/v1/passwords") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "user": ["email": email],
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = postData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Failed to serialize JSON data")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                if responseString.contains("invalid_client") {
                    errorMessage = "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method."
                    print("Invalid client error")
                    showAlert.toggle()
                } else {
                    processNotification()
                    print("Password recovery success")
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            }
        }
        .resume()
    }
    
    // MARK: - Notification
    private func processNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                sendLocalNotification()
            } else {
                // Permission denied
            }
        }
    }

    private func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Check your email"
        content.body = "We’ve email you instructions to reset your password."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ForgotPasswordView()
}
