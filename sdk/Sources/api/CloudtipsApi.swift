//
//  CloudtipsApi.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import CloudpaymentsNetworking

class CloudtipsApi {
    private let defaultCardHolderName = "Cloudtips SDK"
    
    private let threeDsSuccessURL = "https://cloudtips.ru/success"
    private let threeDsFailURL = "https://cloudtips.ru/fail"
    
    func getLayout(by phoneNumber: String, completion: CloudtipsRequestCompletion<[Layout]>?) {
        GetLayoutRequest(phoneNumber: phoneNumber).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
        
    func offlineRegister(with phoneNumber: String, name: String?, agentCode: String?, completion: CloudtipsRequestCompletion<[Layout]>?) {
        let params = ["phoneNumber" : phoneNumber, "name" : name ?? "", "agentCode" : agentCode ?? ""]
        
        OfflineRegisterRequest(params: params).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPublicId(with layoutId: String, completion: CloudtipsRequestCompletion<PublicIdResponse>?) {
        let params = ["layoutId": layoutId]
        
        GetPublicIdRequest(params: params).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func auth(with paymentData: PaymentData, cryptogram: String, captchaToken: String, completion: CloudtipsRequestCompletion<PaymentResponse>?) {
        let params: [String: Any] =
            ["cardholderName": "Cloudtips SDK",
             "cardCryptogramPacket": cryptogram,
             "amount": paymentData.amount,
             "currency": paymentData.currency.rawValue,
             "comment": paymentData.comment ?? "",
             "layoutId": paymentData.layoutId,
             "captchaVerificationToken": captchaToken,
             "feeFromPayer": paymentData.feeFromPayer]
        
        AuthPaymentRequest(params: params).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    public func post3ds(md: String, paRes: String, completion: CloudtipsRequestCompletion<PaymentResponse>?) {
        let parameters = ["md": md,
                          "paRes": paRes]
        
        PostThreeDsRequest(params: parameters).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func verifyCaptcha(version: Int, token: String, amount: String, layoutId: String, completion: CloudtipsRequestCompletion<CaptchaVerifyResponse>?) {
        let parameters = ["version": version,
                          "token": token,
                          "amount": amount,
                          "layoutId": layoutId] as [String : Any]
        
        CaptchaVerifyRequest(params: parameters).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPaymentPages(by layoutId: String, completion: CloudtipsRequestCompletion<PaymentPagesResponse>?) {
        GetPaymentPagesRequest(layoutId: layoutId).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPayerFee(layoutId: String, amount: String, completion: CloudtipsRequestCompletion<PayerFeeResponse>?) {
        
        GetPayerFeeRequest(layoutId: layoutId, amount: amount).execute(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
}

public typealias CloudtipsRequestCompletion<T> = (_ response: T?, _ error: Error?) -> Void
