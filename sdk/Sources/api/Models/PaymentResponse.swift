//
//  PaymentResponse.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 02.10.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

enum PaymentResponseStatus: String, Codable {
    case success = "Success"
    case failure = "Failure"
    case need3ds = "Need3ds"
}

struct PaymentResponse: Codable {
    private(set) var transactionId: Int?
    private(set) var md: String?
    private(set) var paReq: String?
    private(set) var acsUrl: String?
    private(set) var message: String?
    private(set) var statusCode: PaymentResponseStatus?
    private(set) var cardToken: String?
    private(set) var partnerRedirectUrl: String?
}
