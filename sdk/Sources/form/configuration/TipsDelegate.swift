//
//  TipsDelegate.swift
//  Cloudtips-SDK-iOS
//
//  Created by a.ignatov on 15.07.2021.
//  Copyright © 2021 Cloudtips. All rights reserved.
//

import Foundation

public protocol TipsDelegate: AnyObject {
    func onTipsSuccessed()
    func onTipsCancelled()
}

