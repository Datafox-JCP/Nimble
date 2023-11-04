//
//  SurveysListView.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import SwiftUI

struct SurveysListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    
    /*
    func checkAccessTokenExpiry() {
        if let storedAccessToken = getAccessToken() {
            // Check if the access token has expired (you may need additional logic based on the API)
            let accessTokenExpired = /* Add logic to check if access token is expired */

            if accessTokenExpired {
                // Use refresh token to obtain a new access token
                refreshToken()
            }
        } else {
            print("Access token not found. User needs to log in.")
        }
    }
     */

    func refreshToken() {
        guard let refreshToken = getRefreshToken() else {
            print("Refresh token not found. User needs to log in.")
            return
        }

        let parameters = """
            {
                "grant_type": "refresh_token",
                "refresh_token": "\(refreshToken)",
                "client_id": "YOUR_CLIENT_ID",
                "client_secret": "YOUR_CLIENT_SECRET"
            }
        """
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://survey-api.nimblehq.co/api/v1/oauth/token")!,timeoutInterval: Double.infinity)
        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }

            if let responseString = String(data: data, encoding: .utf8),
               let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                let accessToken = tokenResponse.data.attributes.access_token
//                storeAccessToken(accessToken: accessToken)

                // You may also update the UI or perform additional actions if needed
            }
        }
        .resume()
    }
}

#Preview {
    SurveysListView()
}
