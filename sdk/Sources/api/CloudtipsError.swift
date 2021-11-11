//
//  CloudtipsError.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

class CloudtipsError: Error {
    static let defaultCardError = CloudtipsError.init(message: "Unable to determine bank")
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
