//
//  HTTP.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

enum HTTPResource {
    static let baseURLString = "https://pay.cloudtips.ru/"
    
    static let baseApiProdURLString = "https://api.cloudtips.ru/api/"
    static let baseApiPreprodURLString = "https://api-sandbox.cloudtips.ru/api/" // lk-sandbox.cloudtips.ru/api/ -> api-preprod.cloudtips.ru
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
            return baseURL.appending("layouts/list/\(phoneNumber)") // layouts/list/{phoneNumber} // done
        case .offlineRegister:
            return baseURL.appending("receivers") // auth/offlineregister -> receivers // done
        case .getPublicId:
            return baseURL.appending("payment/publicId") // payment/publicid // done
        case .authPayment:
            return baseURL.appending("payment/auth") // payment/auth
        case .post3ds:
            return baseURL.appending("payment/post3ds") // payment/post3ds
        case .captchaVerify:
            return baseURL.appending("captcha/verify") // captcha/verify
        case .getPaymentPages(let layoutId):
            return baseURL.appending("paymentpages/\(layoutId)") // paymentpages/{layoutId} // done
        case .getPayerFee:
            return baseURL.appending("payment/fee") // done
        }
    }
}


