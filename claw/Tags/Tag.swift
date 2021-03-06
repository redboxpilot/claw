//
//  Tag.swift
//  claw
//
//  Created by Zachary Gorak on 9/30/20.
//

import Foundation

struct Tag: Codable, Identifiable, Hashable {
    var id: Int
    var tag: String
    var description: String
    var privileged: Bool
    var is_media: Bool
    var active: Bool
    var hotness_mod: Double
    var permit_by_new_users: Bool
    var category_id: Int
}
