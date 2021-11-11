//
//  TipsConfiguration.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 09.10.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

public class TipsConfiguration {
    internal let phoneNumber: String
    internal let userName: String?
    internal let agentCode: String?
    internal var feeFromPayerEnabled: Bool?
    internal var feeFromPayerState: String?
    internal private(set) var applePayMerchantId: String = ""
    internal private(set) var testMode: Bool = false
    
    internal private(set) var tipsDelegate: TipsDelegateImpl? = nil
    
    var layout: Layout?
    var profile: Profile = Profile()
    
    public init(phoneNumber: String, userName: String?, partner: String? = nil, testMode: Bool = false) {
        self.phoneNumber = phoneNumber
        self.userName = userName
        self.agentCode = partner
        self.testMode = testMode
    }

    public func setApplePayMerchantId(_ merchantId: String) {
        self.applePayMerchantId = merchantId
    }
    
    public func setTipsDelegate(_ delegate: TipsDelegate) {
        self.tipsDelegate = TipsDelegateImpl.init(delegate: delegate)
    }
}

