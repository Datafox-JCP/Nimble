//
//  TokenResp.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 03/11/23.

import Foundation

struct TokenResponse: Codable {

    let data: TokenData

    struct TokenData: Codable {
        let id: String
        let type: String
        let attributes: TokenAttributes
    }
}

struct TokenAttributes: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
    }
}
