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

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
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

struct SurveyListResponse: Codable {
    var data: [Survey]
    var meta: Meta
}

struct Meta: Codable {
    var page: Int
    var pages: Int
    var pageSize: Int
    var records: Int

    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case pageSize = "page_size"
        case records
    }
}
