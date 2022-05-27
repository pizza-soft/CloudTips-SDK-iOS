//
//	ReCAPTCHAViewModel.swift 
//	ciarf 
//
//	Created by ciarf.ru on 21.09.2020 
//	Copyright © 2020 ciarf.ru. All rights reserved. 
//

import Foundation
import WebKit

final class RecaptchaViewModel: NSObject {

    static let googleLicenseHtmlString = """
<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>
<p style="text-align: center;"><span style="color: #393962; opacity: 70%;">This site is protected by reCAPTCHA and the <a href="https://policies.google.com/privacy" style="color: #393962;">Google Privacy Policy</a> and <a href="https://policies.google.com/terms" style="color: #393962;">Terms of Service</a> apply.</span></p><body style='margin:0;padding:0;'><style type=\"text/css\">body{font-family: -apple-system; font-size:12;}</style>
"""
    var onCaptchaVerified: ((_ token: String?) -> ())?
    
    let handlerName = "recaptcha"

    private let key: String

    var html: String {
        """
            <!DOCTYPE html>
            <html>
              <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <script src="https://www.google.com/recaptcha/api.js?render=\(key)"></script>
                <title></title>
                <script type="text/javascript">
                  const post = function(value) {
                      window.webkit.messageHandlers.\(handlerName).postMessage(value);
                  };

                  console.log = function(message) {
                      post(message);
                  };
                    grecaptcha.ready(function() {
                    // do request for recaptcha token
                    // response is promise with passed token
                        grecaptcha.execute('\(key)')
                                  .then(function(token) {
                            post(token);
                        });
                    });
                </script>
              </head>
              <body>
                  <div id="recaptcha"></div>
              </body>
            </html>
        """
    }
    
    private var timeoutWorker: DispatchWorkItem?
    private let isSandboxMode: Bool

    init(isSandboxMode: Bool) {
        self.isSandboxMode = isSandboxMode
        key = isSandboxMode ? "6LeXxtkZAAAAAD_qHY6RTPZczu8qc-0ziIQq9MXQ" : "6LeTy9YZAAAAAGkzdnNg64z67vimf3zkD7woujli"
    }

    func start(){
        self.timeoutWorker?.cancel()
        self.timeoutWorker = DispatchWorkItem.init {
            self.timeoutWorker?.cancel()
            self.onCaptchaVerified?(nil)
            self.onCaptchaVerified = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: self.timeoutWorker!)
    }
}

// MARK: - WKScriptMessageHandler
extension RecaptchaViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let message = message.body as? String else {
            assertionFailure("Expected a string")
            return
        }
        
        self.onCaptchaVerified?(message)
        self.timeoutWorker?.cancel()
        self.timeoutWorker = nil
    }
}
