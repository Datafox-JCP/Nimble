//
//  LoginView.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 03/11/23.
//

import SwiftUI

struct LoginView: View {
    // MARK: Properties
    @StateObject private var loginViewModel = LoginViewModel()

    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()

                if loginViewModel.validatingUser {
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

                        TextField("", text: $loginViewModel.email, prompt: Text("Email").foregroundColor(Color.gray))
                        .accessibilityIdentifier("EmailTextField")
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
                            SecureField("", text: $loginViewModel.password, prompt: Text("Password")
                                .foregroundColor(Color.gray))
                                .accessibilityIdentifier("PasswordTextField")
                                .foregroundStyle(.white)
                                .padding(.horizontal)

                            Button {
                                loginViewModel.isRecoverPresented.toggle()
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

                    // Login
                    /// your_email@example.com - 12345678
                    Button {
                        loginViewModel.validatingUser.toggle()
                        loginViewModel.performAuthentication()
                    } label: {
                        Text("Log in")
                            .bold()
                            .accessibilityIdentifier("LoginButton")
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    .foregroundColor(.black)
                    .accentColor(.white)
                    .buttonStyle(.borderedProminent)
                    .padding()

                    /// Goes to main list screen
                    NavigationLink(destination: SurveysListView(), isActive: $loginViewModel.isSurveyListPresented) {
                        EmptyView()
                    }
                    /// Goes to recover password screen
                    NavigationLink(destination: ForgotPasswordView(), isActive: $loginViewModel.isRecoverPresented) {
                        EmptyView()
                    }
                } // VStack
                .alert(isPresented: $loginViewModel.showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(loginViewModel.errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
            } // ZStack
            .ignoresSafeArea()
            .navigationBarHidden(true)
        } // Nav
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
