//
//  Survey.swift
//  Nimble
//
//  Created by Juan Hernandez Pazos on 04/11/23.
//

import Foundation

struct Survey: Decodable, Identifiable {
    var id: String
    var type: String
    var attributes: Attributes
}

struct Attributes: Decodable {
    var title: String
    var description: String
    var thank_email_above_threshold: String
    var thank_email_below_threshold: String
    var is_active: Bool
    var cover_image_url: String
    var created_at: String
    var active_at: String
    var inactive_at: String?
    var survey_type: String
}
