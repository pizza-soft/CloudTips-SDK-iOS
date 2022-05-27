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
    internal let name: String?
    internal let agentCode: String?
    internal let email: String?
    internal let type: Int?
    internal let placeId: String?
    internal let managerId: String?
    internal let password: String?
    internal let passwordConfirm: String?
    internal let sendPassword: Bool?
    internal let verifyPhone: Bool?
    internal let leadId: String?
    internal let salesCode: String?
    internal let registrationSource: Int?
    internal let utminfo: [String: String]?

    internal var feeFromPayerEnabled: Bool?
    internal var feeFromPayerState: String?
    internal private(set) var applePayMerchantId: String = ""
    internal private(set) var testMode: Bool = false
    
    internal private(set) weak var delegate: TipsDelegate?

    var layout: Layout?
    var profile: Profile = Profile()

    public var navigationTintColor: UIColor?
    public var navigationBackgroundColor: UIColor?

    public init(phoneNumber: String,
                userName: String?,
                partner: String? = nil,
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
                testMode: Bool = false) {

        self.phoneNumber = phoneNumber
        self.name = userName
        self.agentCode = partner
        self.email = email
        self.type = type
        self.placeId = placeId
        self.managerId = managerId
        self.password = password
        self.passwordConfirm = passwordConfirm
        self.sendPassword = sendPassword
        self.verifyPhone = verifyPhone
        self.leadId = leadId
        self.salesCode = salesCode
        self.registrationSource = registrationSource
        self.utminfo = utminfo
        self.testMode = testMode
    }

    public func setApplePayMerchantId(_ merchantId: String) {
        self.applePayMerchantId = merchantId
    }
    
    public func setTipsDelegate(_ delegate: TipsDelegate) {
        self.delegate = delegate
    }
}

