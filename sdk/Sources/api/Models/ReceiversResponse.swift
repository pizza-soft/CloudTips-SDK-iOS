//
//  ReceiversResponse.swift
//  Cloudtips
//
//  Created by Ivan Rysev on 12.02.2022.
//

import Foundation

struct ReceiversResponse: Codable {
    let name: String?
    let phoneNumber: String?
    let photoUrl: String?
    let photoId: String?
    let email: String?
    let userId: String?
    let phoneVerified: Bool?
    let layoutIds: [String]?
}

