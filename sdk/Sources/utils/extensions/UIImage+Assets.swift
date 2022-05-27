//
//  UIImage+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public class func bundle(_ name: String) -> UIImage? {
        return UIImage.init(named: name, in: Bundle.tipsSdk, compatibleWith: nil)
    }
    
    public class var iconProgress: UIImage {
        return self.bundle("ic_progress") ?? UIImage()
    }
    
    public class var iconSuccess: UIImage {
        return self.bundle("ic_success") ?? UIImage()
    }
    
    public class var iconFailed: UIImage {
        return self.bundle("ic_failure") ?? UIImage()
    }
}
