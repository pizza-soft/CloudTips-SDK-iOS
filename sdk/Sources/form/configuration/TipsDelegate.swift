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

internal class TipsDelegateImpl {
    weak var delegate: TipsDelegate?
    
    init(delegate: TipsDelegate?) {
        self.delegate = delegate
    }
    
    func tipsSuccessed(){
        self.delegate?.onTipsSuccessed()
    }
    
    func tipsCancelled() {
        self.delegate?.onTipsCancelled()
    }
}
