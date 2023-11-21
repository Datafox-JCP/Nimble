//
//  Constants.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import Foundation

struct Constants {
    static let baseUrl = "https://survey-api.nimblehq.co"
    static let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]
    static let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]
}
