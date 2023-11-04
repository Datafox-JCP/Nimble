//
//  TokenResp.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 03/11/23.
//

import Foundation

struct TokenResponse: Codable {
    
    let data: TokenData
        
        struct TokenData: Codable {
            let id: String
            let type: String
            let attributes: TokenAttributes
            
            struct TokenAttributes: Codable {
                let access_token: String
                let token_type: String
                let expires_in: Int
                let refresh_token: String
                let created_at: Int
            }
        }
}
