//
//  GetPaymentFee.swift
//  Cloudtips-SDK-iOS
//
//  Created by a.ignatov on 09.11.2021.
//  Copyright © 2021 Cloudtips. All rights reserved.
//

import CloudpaymentsNetworking

class GetPayerFeeRequest: BaseRequest, CloudpaymentsRequestType {
    private let layoutId: String
    private let amount: String
    init(layoutId: String, amount: String) {
        self.layoutId = layoutId
        self.amount = amount
    }
    
    typealias ResponseType = PayerFeeResponse
        
    var data: CloudpaymentsRequest {
        return CloudpaymentsRequest(path: HTTPResource.getPayerFee.asURL() + "/?layoutId=\(layoutId)&amount=\(amount)", method: .get, headers: headers)
    }
}
