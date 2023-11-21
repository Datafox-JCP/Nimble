//
//  Survey.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import Foundation

struct Survey: Codable, Identifiable {
    var id: String
    var type: String
    var attributes: Attributes
}

struct Attributes: Codable {
    var title: String
    var description: String
    var thankEmailAboveThreshold: String
    var thankEmailBelowThreshold: String
    var isActive: Bool
    var coverImageUrl: String
    var createdAt: String
    var activeAt: String
    var inactiveAt: String?
    var surveyType: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case thankEmailAboveThreshold = "thank_email_above_threshold"
        case thankEmailBelowThreshold = "thank_email_below_threshold"
        case isActive = "is_active"
        case coverImageUrl = "cover_image_url"
        case createdAt = "created_at"
        case activeAt = "active_at"
        case inactiveAt = "inactive_at"
        case surveyType = "survey_type"
    }
}
