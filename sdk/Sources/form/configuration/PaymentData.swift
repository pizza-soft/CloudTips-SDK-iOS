//
//  PaymentData.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 02.10.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation
import Cloudpayments

struct Rating {
    let score: Int
    let selectedComponents: [String]
}

class PaymentData {

    let layoutId: String
    let amount: NSNumber
    let comment: String?
    let currency: Currency
    let amountPayerFee: NSNumber
    let feeFromPayer: Bool

    // new
    let name: String?
    let invoiceId: String?
    let payerEmail: String?
    let receiverSubscriptionSettingId: String?
    let payerPhoneNumber: String?
    let payerCity: String?
    let placeCode: String?
    let rating: Rating?

    init(layoutId: String,
         amount: NSNumber,
         comment: String?,
         currency: Currency = .ruble,
         amountPayerFee: NSNumber,
         name: String? = nil,
         invoiceId: String? = nil,
         payerEmail: String? = nil,
         receiverSubscriptionSettingId: String? = nil,
         payerPhoneNumber: String? = nil,
         payerCity: String? = nil,
         placeCode: String? = nil,
         rating: Rating? = nil,
         feeFromPayer: Bool = false) {

        self.layoutId = layoutId
        self.comment = comment
        self.amount = amount
        self.currency = currency
        self.amountPayerFee = amountPayerFee
        self.feeFromPayer = feeFromPayer

        self.name = name
        self.invoiceId = invoiceId
        self.payerEmail = payerEmail
        self.receiverSubscriptionSettingId = receiverSubscriptionSettingId
        self.payerPhoneNumber = payerPhoneNumber
        self.payerCity = payerCity
        self.placeCode = placeCode
        self.rating = rating
    }
}
