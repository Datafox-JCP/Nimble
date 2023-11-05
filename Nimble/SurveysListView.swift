    //
    //  SurveysListView.swift
    //  Nimble
    //
    //  Created by Juan Hernandez Pazos on 04/11/23.
    //

import SwiftUI

struct SurveysListView: View {
    
    @ObservedObject var viewModel = SurveysListViewModel()
    
    @State private var isRefreshing = false
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Surveys...")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.surveys) { survey in
                            NavigationLink(destination: SurveyDetailScreen(survey: survey)) {
                                SurveyCardView(survey: survey)
                            }
                        }
                    }
                    .padding()
                    .refreshable {
                        await refreshData()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadSurveys()
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        await viewModel.loadSurveys()
        isRefreshing = false
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


struct SurveyCardView: View {
    let survey: Survey
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(survey.attributes.title)
                .font(.headline)
                .fontWeight(.bold)
            Text(survey.attributes.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
