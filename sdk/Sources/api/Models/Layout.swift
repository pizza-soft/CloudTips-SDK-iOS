//
//  Layout.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

struct Layout: Codable {
    private(set) var layoutId: String?
    private(set) var defaultLayout: Bool?
    private(set) var disabled: Bool?
    private(set) var title: String?
    private(set) var description: String?
    private(set) var text: String?
    private(set) var paymentLink: String?
    private(set) var backgroundId: String?
    private(set) var backgroundUrl: String?
    private(set) var qrLink: String?
    
    enum CodingKeys: String, CodingKey {
        case layoutId
        case defaultLayout = "default"
        case disabled
        case title
        case description
        case text
        case paymentLink
        case backgroundId
        case backgroundUrl
        case qrLink
    }
}
