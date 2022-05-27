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
        GetLayoutRequest(phoneNumber: phoneNumber).exec(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
        
    func offlineRegister(phoneNumber: String,
                         name: String?,
                         agentCode: String? = nil,
                         email: String? = nil,
                         type: Int? = nil,
                         placeId: String? = nil,
                         managerId: String? = nil,
                         password: String? = nil,
                         passwordConfirm: String? = nil,
                         sendPassword: Bool? = nil,
                         verifyPhone: Bool? = nil,
                         leadId: String? = nil,
                         salesCode: String? = nil,
                         registrationSource: Int? = nil,
                         utminfo: [String: String]? = nil,

                         completion: CloudtipsRequestCompletion<ReceiversResponse>?) {
        let params: [String : Any?] = [
            "phoneNumber": phoneNumber,
            "name": name ?? "",
            "email": email,
            "type": type,
            "placeId": placeId,
            "managerId": managerId,
            "password": password,
            "passwordConfirm": passwordConfirm,
            "sendPassword": sendPassword ?? false,
            "verifyPhone": verifyPhone ?? false,
            "leadId": leadId,
            "agentCode": agentCode ?? "",
            "salesCode" : salesCode,
            "registrationSource": registrationSource,
            "utminfo" : utminfo
        ]

        OfflineRegisterRequest(params: params).exec(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPublicId(with layoutId: String, completion: CloudtipsRequestCompletion<PublicIdResponse>?) {
        let params = ["layoutId": layoutId]
        
        GetPublicIdRequest(params: params).exec(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func auth(with paymentData: PaymentData,
              cryptogram: String,
              captchaToken: String,
              completion: CloudtipsRequestCompletion<PaymentResponse>?) {

        let params: [String: Any?] =
            ["cardholderName": "Cloudtips SDK",
             "cardCryptogramPacket": cryptogram,

             "amount": paymentData.amount,
             "currency": paymentData.currency.rawValue,
             "comment": paymentData.comment ?? "",
             "layoutId": paymentData.layoutId,
             "feeFromPayer": paymentData.feeFromPayer,

             "name": paymentData.name,
             "invoiceId": paymentData.invoiceId,
             "payerEmail": paymentData.payerEmail,
             "receiverSubscriptionSettingId": paymentData.receiverSubscriptionSettingId,
             "payerPhoneNumber": paymentData.payerPhoneNumber,
             "payerCity": paymentData.payerCity,
             "placeCode": paymentData.placeCode,
             "rating": paymentData.rating,

             "captchaVerificationToken": captchaToken,
             ]

//        if let theJSONData = try?  JSONSerialization.data(
//            withJSONObject: params,
//            options: .prettyPrinted
//        ),
//           let theJSONText = String(data: theJSONData,
//                                    encoding: String.Encoding.ascii) {
//            print("JSON string = \n\(theJSONText)")
//        }

        AuthPaymentRequest(params: params).exec(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    public func post3ds(md: String, paRes: String, completion: CloudtipsRequestCompletion<PaymentResponse>?) {
        let parameters = ["md": md,
                          "paRes": paRes]
        
        PostThreeDsRequest(params: parameters).exec(onSuccess: { layouts in
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
        
        CaptchaVerifyRequest(params: parameters).exec(onSuccess: { response in
            completion?(response, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPaymentPages(by layoutId: String, completion: CloudtipsRequestCompletion<PaymentPageModel>?) {
        GetPaymentPagesRequest(layoutId: layoutId).exec(dateDecodingStrategy: .customISO8601,
                                                           onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
    
    func getPayerFee(layoutId: String, amount: String, completion: CloudtipsRequestCompletion<PayerFeeResponse>?) {
        
        GetPayerFeeRequest(layoutId: layoutId, amount: amount).exec(onSuccess: { layouts in
            completion?(layouts, nil)
        }, onError: { error in
            completion?(nil, error)
        })
    }
}

public typealias CloudtipsRequestCompletion<T> = (_ response: T?, _ error: Error?) -> Void

// MARK: - CloudpaymentsRequestType

extension CloudpaymentsRequestType {
    func exec<T: Decodable>(dispatcher: CloudpaymentsNetworkDispatcher = CloudpaymentsURLSessionNetworkDispatcher.instance,
                 keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                 dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .customISO8601,
                 onSuccess: @escaping (T) -> Void,
                 onError: @escaping (Error) -> Void,
                 onRedirect: ((URLRequest) -> Bool)? = nil) {
        dispatcher.dispatch(
            request: self.data,
            onSuccess: { (responseData: Data) in
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
                    jsonDecoder.dateDecodingStrategy = dateDecodingStrategy
                    let apiResponse = try jsonDecoder.decode(ApiResponse<T>.self, from: responseData)
                    switch apiResponse {
                    case .success(let data):
                        DispatchQueue.main.async {
                            onSuccess(data)
                        }
                    case .failure(let error):
                        throw ApiError.apiError(error.errors.joined(separator: ", "))
                    }

                } catch let error {
                    DispatchQueue.main.async {
                        if error is DecodingError {
                            onError(CloudpaymentsError.parseError)
                        } else {
                            onError(error)
                        }
                    }
                }
            },
            onError: { (error: Error) in

                //let str = String(decoding: data, as: UTF8.self)

                DispatchQueue.main.async {
                    onError(error)
                }
            }, onRedirect: onRedirect
        )
    }
}
