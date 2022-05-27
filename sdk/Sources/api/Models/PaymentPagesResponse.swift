//
//  PaymentPagesResponse.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 23.12.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

/*
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
*/

// swiftlint:disable identifier_name
struct LocalizedStringModel: Codable {
    var ru: String?
    var en: String?
}

enum PaymentPageAmountConstraintType: String, Codable {
    case Maximal
    case Minimal
    case Fixed
}

struct PaymentPageAmountConstraintModel: Codable {
    var type: PaymentPageAmountConstraintType
    var currency: String
    var value: Double
}

struct PaymentPageAmountModel: Codable {
    var currency: String?
    var amountPresetSettings: PaymentPageAmountPresetSettingsModel
        //var constraints: [PaymentPageAmountConstraintModel]
    var range: [String: Double?]

    func getMinAmount() -> Double? {
        return range["minimal"] ?? nil
    }

    func getMaxAmount() -> Double? {
        return range["maximal"] ?? nil
    }

    func getFixAmount() -> Double? {
        return range["fixed"] ?? nil
    }

}

struct PaymentPageAmountPresetSettingsModel: Codable {
    var enabled: Bool
    var amounts: [Double]
}

struct PaymentPageTargetModel: Codable {
    var startDate: Date
    var finishDate: Date
    var targetAmount: Double
    var currentAmount: Double?
}

struct PaymentPageFieldModel: Codable {
    var enabled: Bool
    var required: Bool
    var title: String?
}

struct PaymentPageFieldsModel: Codable {
    var comment: PaymentPageFieldModel?
    var email: PaymentPageFieldModel?
    var name: PaymentPageFieldModel?
    var phoneNumber: PaymentPageFieldModel?
    var payerCity: PaymentPageFieldModel?
}

struct PaymentPageRatingComponentModel: Codable {
    var id: String
    var title: String
    var imageUrl: String
}

struct PaymentPageRatingModel: Codable {
    var enabled: Bool
    var components: [PaymentPageRatingComponentModel]
}

struct PaymentPageAfterPaymentAction: Codable {
    var enabled: Bool
    var text: String?
}

struct PaymentPageAfterPaymentActions: Codable {
    var emailSending: PaymentPageAfterPaymentAction
}

struct PayerFee: Codable {
    var enabled: Bool?
    var initialState: String?
}

struct PaymentPageModel: Codable {
    var id: String?
    var layoutId: String?
    var url: String
    var title: String
    var backgroundUrl: String?
    var avatarUrl: String?
    var paymentMessage: LocalizedStringModel
    var successMessage: LocalizedStringModel
    var failMessage: LocalizedStringModel
    var amount: PaymentPageAmountModel
    var target: PaymentPageTargetModel?
    var rating: PaymentPageRatingModel?
    var availableFields: PaymentPageFieldsModel?
    var afterPaymentActions: PaymentPageAfterPaymentActions?

    var logoUrl: String?
    var nameText: String?
    var backgroundColor: String?
    var linksColor: String?
    var buttonsColor: String?
    var userAgreementText: String?
    var userAgreementUrl: String?

    var applePayEnabled: Bool?
    var googlePayEnabled: Bool?
    var hideReCaptchaHint: Bool?
    var excludeCharityBanner: Bool?

    var payerFee: PayerFee?
    var feedback: FeedbackModel?

}

struct RatingComponentsModel: Codable {
    let id: String?
    let title: String?
    let imageUrl: String?
}

struct RatingModel: Codable {
    let enabled: Bool?
    let components: [RatingComponentsModel]?
}

struct FeedbackModel: Codable {
    let enabled: Bool?
    let rating: RatingModel?
    let availableFields: [String: PaymentPageFieldModel?]?
}
