//
//  GetPaymentPagesRequest.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 02.07.2021.
//  Copyright © 2021 Cloudtips. All rights reserved.
//

import CloudpaymentsNetworking

class GetPaymentPagesRequest: BaseRequest, CloudpaymentsRequestType {
    typealias ResponseType = PaymentPageModel
    
    private let layoutId: String
    
    init(layoutId: String) {
        self.layoutId = layoutId
    }
    
    var data: CloudpaymentsRequest {
        return CloudpaymentsRequest(path: HTTPResource.getPaymentPages(layoutId).asURL(), method: .get, params: params, headers: headers)
    }
}
