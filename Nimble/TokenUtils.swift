//
//  TokenUtils.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import Foundation

// TODO: Should this use Keychain?
func storeAccessToken(accessToken: String, expiresIn: Int, refreshToken: String) {
    UserDefaults.standard.set(accessToken, forKey: "AccessToken")
    UserDefaults.standard.set(expiresIn, forKey: "ExpiresIn")
    UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
}

func getAccessToken() -> String? {
    return UserDefaults.standard.string(forKey: "AccessToken")
}

func getExpiresIn() -> Int? {
    return UserDefaults.standard.integer(forKey: "ExpiresIn")
}

func getRefreshToken() -> String? {
    let refreshTokenKey = "RefreshToken"
    return UserDefaults.standard.string(forKey: refreshTokenKey)
}
