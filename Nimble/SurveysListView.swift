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
    @State private var selectedCard = 0

    // MARK: - View
    var body: some View {
        ZStack {
            Image(selectedCard % 2 == 0 ? "background2" : "background1")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.black)
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
                        HStack(alignment: .bottom, spacing: 0) {
                            ForEach(0..<viewModel.surveys.count, id: \.self) { index in
                                let survey = viewModel.surveys[index]
                                NavigationLink(destination: SurveyDetailScreen(survey: survey)) {
                                    SurveyCardView(selectedCard: $selectedCard, survey: survey, index: index)
                                        .frame(width: UIScreen.main.bounds.width)
                                } // Navigation
                            } // Loop
                        } //  HStack
                    } // Scroll
                    .padding()
                    .padding(.bottom, 48)
                } // Condition
            } // VStack
        } // ZStack
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.loadSurveys()
        }
    }

    // MARK: - Functions
    private func formattedDate() -> Text {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM"
        let formattedDate = formatter.string(from: currentDate).uppercased()

        return Text(formattedDate)
            .font(.headline)
            .foregroundColor(.white)
    }

        /// This partial code is for refresh the surveys
    private func refreshData() {
        isRefreshing = true
        viewModel.loadSurveys()
        isRefreshing = false
    }

        // ARK: - This code, should work but whem needs to be executed
    private func refreshToken() {
        guard let refreshToken = getRefreshToken() else {
            print("Refresh token not found. User needs to log in.")
            return
        }

        let parameters = """
            {
                "grant_type": "refresh_token",
                "refresh_token": "\(refreshToken)",
                "client_id": "\(Constants.clientId ?? "")",
                "client_secret": "\(Constants.clientSecret ?? "")"
            }
        """
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(
            url: URL(string: "\(Constants.baseUrl)/api/v1/oauth/token")!,
            timeoutInterval: Double.infinity
        )
        request.httpMethod = "POST"
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard data != nil else {
                print(String(describing: error))
                return
            }
//            if let responseString = String(data: data, encoding: .utf8),
//               let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
//                let accessToken = tokenResponse.data.attributes.access_token
//            }
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
        // MARK: - Properties

    @Binding var selectedCard: Int

    let survey: Survey
    var index: Int

        // MARK: - View
    var body: some View {
        VStack(alignment: .leading) {
            Text(survey.attributes.title)
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(.bottom, 16)

            HStack(alignment: .top) {
                Text(survey.attributes.description)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.forward.circle.fill")
                    .font(.system(size: 36))
                    .tint(.white)
            } // HStack
        } // VStack
        .frame(width: 320)
        .onAppear {
            if index == selectedCard {
                selectedCard += 1
            }
        }
    }
}
