//
//  SurveysListViewModel.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import Foundation

class SurveysListViewModel: ObservableObject {
    @Published var surveys: [Survey] = []
        @Published var isLoading: Bool = false

        func loadSurveys() {
            isLoading = true

            guard let url = URL(string: "\(Constants.baseUrl)/api/v1/surveys?page[number]=1&page[size]=2") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)

            if let accessToken = getAccessToken() {
                let bearerToken = "Bearer \(accessToken)"
                request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
            } else {
                print("Access token not saved")
            }

            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, _, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    guard let data = data else {
                        print(String(describing: error))
                        return
                    }
//                    print(String(data: data, encoding: .utf8)!)

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    do {
                        let decodedData = try decoder.decode(SurveyListResponse.self, from: data)
                        self.surveys = decodedData.data
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
}

struct SurveyListResponse: Decodable {
    var data: [Survey]
    var meta: Meta

    struct Meta: Decodable {
        var page: Int
        var pages: Int
        var page_size: Int
        var records: Int
    }
}
