//
//  LoginViewModel.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 21/11/23.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    @Published var errorMessage = ""
    @Published var validatingUser = false
    @Published var isSurveyListPresented = false
    @Published var isRecoverPresented = false

    func performAuthentication() {
        if isValidInput() {
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

            guard let requestUrl = components?.url else { return}

            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"

            URLSession.shared.dataTask(with: request) { [self] data, _, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    if responseString.contains("invalid_client") {
                        handleAuthenticationError(with: "Client authentication failed due to unknown client.")
                    } else if responseString.contains("invalid_grant") {
                        handleAuthenticationError(with: "Client authentication failed due to unknown client.")
                    } else if responseString.contains("invalid_email_or_password") {
                        handleAuthenticationError(with: "Client authentication failed due to unknown client.")
                    } else {
                        if let jsonData = responseString.data(using: .utf8),
                           let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: jsonData) {
                            let accessToken = tokenResponse.data.attributes.accessToken
                            let expiresIn = Int(tokenResponse.data.attributes.expiresIn)
                            let refreshToken = tokenResponse.data.attributes.refreshToken

                            storeAccessToken(accessToken: accessToken, expiresIn: expiresIn, refreshToken: refreshToken)
                            moveToSurveysScreen()
                        } else {
                            handleAuthenticationError(with: "Failed to decode JSON response")
                        }
                    }
                }
            }
            .resume()
        } else {
            handleAuthenticationError(with: "Invalid email or password format.")
        }
    }

    func moveToSurveysScreen() {
        DispatchQueue.main.async {
            self.validatingUser = false
            self.isSurveyListPresented = true
        }
    }

    func isValidInput() -> Bool {
        let emailValidation = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        let isEmailValid = emailValidation.evaluate(with: email)
        let isPasswordValid = password.count >= 8

        return isEmailValid && isPasswordValid
    }

    private func handleAuthenticationError(with errorMessage: String) {
        DispatchQueue.main.async {
            self.showAlert.toggle()
            self.validatingUser.toggle()
            self.errorMessage = errorMessage
        }
    }
}
