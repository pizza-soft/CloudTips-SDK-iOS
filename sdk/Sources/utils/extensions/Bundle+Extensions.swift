//
//  Bundle+Extensions.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

extension Bundle {
    class var tipsSdk: Bundle {
        let bundle = Bundle.init(for: TipsViewController.self)
        let bundleUrl = bundle.url(forResource: "CloudtipsSDK", withExtension: "bundle")
        return Bundle.init(url: bundleUrl!)!
    }
}

