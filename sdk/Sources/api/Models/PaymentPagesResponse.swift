//
//  PaymentPagesResponse.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 23.12.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

struct PaymentPagesResponse: Codable {
    private(set) var id: String?
    private(set) var layoutId: String?
    private(set) var url: String?
    private(set) var title: String?
    private(set) var backgroundUrl: String?
    private(set) var amount: AmountSettings?
    
    private(set) var nameText: String?
    private(set) var avatarUrl: String?
    
    private(set) var paymentMessage: PaymentPageText?
    private(set) var successMessage: PaymentPageText?
    
    private(set) var payerFee: PayerFee?
}

struct AmountSettings: Codable {
    private(set) var constraints: [AmountConstraint]?
    
    func getMinAmount() -> Double? {
        return self.constraints?.filter { $0.type == "Minimal" }.first?.value
    }
    
    func getMaxAmount() -> Double? {
        return self.constraints?.filter { $0.type == "Maximal" }.first?.value
    }
}

struct AmountConstraint: Codable {
    private(set) var type: String?
    private(set) var currency: String?
    private(set) var value: Double?
}

struct PaymentPageText: Codable {
    private(set) var ru: String?
    private(set) var en: String?
}

struct PayerFee: Codable {
    private(set) var enabled: Bool?
    private(set) var initialState: String?
}
