//
//  LoginView.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 03/11/23.
//

import SwiftUI

struct LoginView: View {
    // MARK: Properties
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var isSurveyListPresented = false
    @State private var isRecoverPresented = false
    @State private var validatingUser = false

    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                
                if validatingUser {
                    ProgressView()
                        .tint(.white)
                }

                VStack(spacing: 20) {
                    Image("nimble_logo")
                        .resizable()
                        .frame(width: 160, height: 40)
                        .padding(.bottom, 80)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray.opacity(0.3))

                        TextField("", text: $email, prompt: Text("Email")
                            .foregroundColor(Color.gray))
                        .keyboardType(.emailAddress)
                        .submitLabel(.next)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    } // ZStack
                    .frame(height: 40)
                    .padding(.horizontal)

                    /// Fussion Password and forgot button
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.gray.opacity(0.3))

                        HStack {
                            SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color.gray))
                                .foregroundStyle(.white)
                                .padding(.horizontal)

                            Button {
                                isRecoverPresented.toggle()
                            } label: {
                                Text("Forgot?")
                                    .font(.callout)
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            .padding(.horizontal)
                        } // HStack
                    } // ZStack
                    .frame(height: 40)
                    .padding(.horizontal)

                    // MARK: - Login button
                    /// Always use
                    /// your_email@example.com
                    /// 12345678
                    Button {
                        performAuthentication()
                        validatingUser.toggle()
                    } label: {
                        Text("Log in")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    // MARK: - Implement validations (email valid, chars in password...)
//                    .disabled(email.isEmpty && password.isEmpty)
                    .foregroundColor(.black)
                    .accentColor(.white)
                    .buttonStyle(.borderedProminent)
                    .padding()

                    /// Goes to main list screen
                    NavigationLink(destination: SurveysListView(), isActive: $isSurveyListPresented) {
                        EmptyView()
                    }
                    /// Goes to recover password screen
                    NavigationLink(destination: ForgotPasswordView(), isActive: $isRecoverPresented) {
                        EmptyView()
                    }
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
    private func performAuthentication() {
        guard let url = URL(string: "\(Constants.baseUrl)/api/v1/oauth/token") else {
            print("Invalid URL")
            return
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "client_id", value: Constants.clientId),
            URLQueryItem(name: "client_secret", value: Constants.clientSecret)
        ]

        guard let requestUrl = components?.url else {
            print("Invalid request URL")
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                if responseString.contains("invalid_client") {
                    errorMessage = "Client authentication failed due to unknown client."
                    showAlert.toggle()
                    validatingUser.toggle()
                } else if responseString.contains("invalid_grant") {
                        errorMessage = "Client authentication failed due to unknown client."
                    showAlert.toggle()
                    validatingUser.toggle()
                } else if responseString.contains("invalid_email_or_password") {
                        errorMessage = "Your email or password is incorrect. Please try again."
                    showAlert.toggle()
                    validatingUser.toggle()
                } else {
                    if let jsonData = responseString.data(using: .utf8),
                       let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: jsonData) {
                        let accessToken = tokenResponse.data.attributes.access_token
                        let expiresIn = Int(tokenResponse.data.attributes.expires_in)
                        let refreshToken = tokenResponse.data.attributes.refresh_token

                        storeAccessToken(accessToken: accessToken, expiresIn: expiresIn, refreshToken: refreshToken)
                        moveToSurveysScreen()
                    } else {
                        errorMessage = "Failed to decode JSON response"
                        showAlert.toggle()
                        validatingUser.toggle()
                    }
                }
            }
        }
        .resume()
    }

    private func moveToSurveysScreen() {
        DispatchQueue.main.async {
            validatingUser = false
            self.isSurveyListPresented = true
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
