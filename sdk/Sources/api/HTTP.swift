//
//  HTTP.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

enum HTTPResource {
    static let baseURLString = "https://pay.cloudtips.ru/"
    
    static let baseApiProdURLString = "https://lk.cloudtips.ru/api/"
    static let baseApiPreprodURLString = "https://lk-sandbox.cloudtips.ru/api/"
    static var baseApiURLString = baseApiProdURLString
    
    case getLayout(String)
    case offlineRegister
    case getPublicId
    case authPayment
    case post3ds
    case captchaVerify
    case getPaymentPages(String)
    case getPayerFee
    
    func asURL() -> String {
        let baseURL = HTTPResource.baseApiURLString
        
        switch self {
        case .getLayout(let phoneNumber):
            return baseURL.appending("layouts/list/\(phoneNumber)")
        case .offlineRegister:
            return baseURL.appending("auth/offlineregister")
        case .getPublicId:
            return baseURL.appending("payment/publicId")
        case .authPayment:
            return baseURL.appending("payment/auth")
        case .post3ds:
            return baseURL.appending("payment/post3ds")
        case .captchaVerify:
            return baseURL.appending("captcha/verify")
        case .getPaymentPages(let layoutId):
            return baseURL.appending("paymentPages/\(layoutId)")
        case .getPayerFee:
            return baseURL.appending("payment/fee")
        }
    }
}
