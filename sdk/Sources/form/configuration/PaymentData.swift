//
//  PaymentData.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 02.10.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation
import Cloudpayments

class PaymentData {
    let layoutId: String
    let amount: NSNumber
    let comment: String?
    let currency: Currency
    let amountPayerFee: NSNumber
    let feeFromPayer: Bool
    
    init(layoutId: String, amount: NSNumber, comment: String?, currency: Currency = .ruble, amountPayerFee: NSNumber, feeFromPayer: Bool = false) {
        self.layoutId = layoutId
        self.comment = comment
        self.amount = amount
        self.currency = currency
        self.amountPayerFee = amountPayerFee
        self.feeFromPayer = feeFromPayer
    }
}
