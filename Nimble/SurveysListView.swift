    //
    //  SurveysListView.swift
    //  Nimble
    //
    //  Created by Juan Hernandez Pazos on 04/11/23.
    //

import SwiftUI

struct SurveysListView: View {
    // MARK: Properties
    @ObservedObject var viewModel = SurveysListViewModel()
    
    @State private var currentDateAndTime = Date.now
    @State private var isRefreshing = false
    
    // MARK: - View
    var body: some View {
        ZStack {
            Image("background1")
                .resizable()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Surveys...")
                } else {
                    
                    VStack(alignment: .leading) {
                        formattedDate()
                        
                        HStack {
                            Text("Today")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image("userpic")
                                .resizable()
                                .frame(width: 36, height: 36)
                        }
                    } // VStack
                    .padding(.top, 64)
                    .padding()
                    
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(viewModel.surveys) { survey in
                                NavigationLink(destination: SurveyDetailScreen(survey: survey)) {
                                    SurveyCardView(survey: survey)
                                } // Navigation
                            } // Loop
                        } //  HStack
                    } // Scroll
                    .padding()
                    .padding(.bottom, 48)
                    .refreshable {
                        await refreshData()
                    }
                } // Condition
            } // VStacl
        } // ZStack
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.loadSurveys()
        }
    }
    
    // MARK: - Functions
    
    private func formattedDate() -> Text {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd MMMM"
        let formattedDate = formatter.string(from: currentDate).uppercased()
        
        return Text(formattedDate)
            .font(.headline)
            .foregroundColor(.white)
    }
    
    private func refreshData() async {
        isRefreshing = true
        await viewModel.loadSurveys()
        isRefreshing = false
    }
    
    // TODO: - This code, should work but whem needs to be executed
    private func refreshToken() {
        guard let refreshToken = getRefreshToken() else {
            print("Refresh token not found. User needs to log in.")
            return
        }
        
        let clientId = Constants.clientId
        let clientSecret = Constants.clientSecret
        
        let parameters = """
            {
                "grant_type": "refresh_token",
                "refresh_token": "\(refreshToken)",
                "client_id": clientId,
                "client_secret": clientSecret
            }
        """
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "\(Constants.baseUrl)/api/v1/oauth/token")!,timeoutInterval: Double.infinity)
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
            }
        }
        .resume()
    }
}

// MARK: - Preview
#Preview {
    SurveysListView()
}

// MARK: - Card
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
