//
//  CapthcaVerifyResponse.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 17.12.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

struct CaptchaVerifyResponse: Codable {
    let status: String?
    let token: String?
    let title: String?  // TODO: нужно ли в новом апи?
    let detail: String? // TODO: нужно ли в новом апи?
}
