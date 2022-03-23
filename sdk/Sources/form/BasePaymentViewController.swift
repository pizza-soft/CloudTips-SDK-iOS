//
//  BasePaymentViewController.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 07.10.2020.
//

import Foundation
import WebKit
import ReCaptcha

public class BasePaymentViewController: BaseViewController, PaymentDelegate {
    internal var configuration: TipsConfiguration!
    internal var paymentData: PaymentData?
    internal var paymentError: CloudtipsError?
    
    var isTipsSuccessed: Bool = false
    
    @IBOutlet weak var captchaWebViewContainer: UIView?
    var captchaWebView: WKWebView?
    var recaptchaViewModel: RecaptchaViewModel = RecaptchaViewModel()
    
    private let recaptchaV2 = try? ReCaptcha(
        apiKey: "6LcXy9YZAAAAAOkgXGwEPNKKsYqAHcT6DYhCSkg4",
        baseURL: URL(string: HTTPResource.baseURLString)!
    )
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = configuration.navigationTintColor ?? UIColor.init(named: "azure")
        navigationController?.navigationBar.backgroundColor = configuration.navigationBackgroundColor ?? .white

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = configuration.navigationBackgroundColor ?? .white
                //            appearance.shadowColor = .white
                //            appearance.shadowImage = UIImage.color(.white)
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        recaptchaV2?.configureWebView({ (webview) in
            webview.frame = self.view.bounds
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.named("ic_close"), style: .plain, target: self, action: #selector(close))
    }
    
    @objc func close() {
        self.dismiss(animated: true)
        if (self.isTipsSuccessed) {
            self.configuration.tipsDelegate?.delegate?.onTipsSuccessed()
        } else {
            self.configuration.tipsDelegate?.delegate?.onTipsCancelled()
        }
    }
    
    internal func onPaymentSucceeded() {
        self.paymentError = nil
        self.performSegue(withIdentifier: .toResultSegue, sender: self)
    }
    
    internal func onPaymentFailed(with error: CloudtipsError?){
        self.paymentError = error
        self.performSegue(withIdentifier: .toResultSegue, sender: self)
    }
    
    func askForV3Captcha(with layoutId: String, amount: String, completion: ((_ token: String?) -> ())?){
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        self.recaptchaViewModel = RecaptchaViewModel()
        self.recaptchaViewModel.onCaptchaVerified = {[unowned self] token in
            if let token = token {
                self.validateCaptchaToken(version: 3, token: token, amount: amount, layoutId: layoutId) { (token) in
                    completion?(token)
                }
            } else {
                completion?(nil)
            }
        }
        self.recaptchaViewModel.start()

        let contentController = WKUserContentController()
        contentController.add(self.recaptchaViewModel, name: self.recaptchaViewModel.handlerName)

        configuration.userContentController = contentController

        self.captchaWebView = WKWebView.init(frame: self.captchaWebViewContainer?.bounds ?? .zero, configuration: configuration)
        self.captchaWebViewContainer?.addSubview(self.captchaWebView!)
        self.captchaWebViewContainer?.bindFrameToSuperviewBounds()
        self.captchaWebView!.loadHTMLString(self.recaptchaViewModel.html, baseURL: URL.init(string: HTTPResource.baseURLString))
    }
    
    private func askForV2Captcha(with layoutId: String, amount: String, completion: ((_ token: String?) -> ())?){
        recaptchaV2?.validate(on: self.view) { [unowned self] (result: ReCaptchaResult) in
            if let token = try? result.dematerialize() {
                self.validateCaptchaToken(version: 2, token: token, amount: amount, layoutId: layoutId) { (token) in
                    completion?(token)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    private func validateCaptchaToken(version: Int, token: String, amount: String, layoutId: String, completion: ((_ token: String?) -> ())?) {
        self.verifyCaptcha(version: version, token: token, amount: amount, layoutId: layoutId) { (response, error) in
            
            if response?.status?.lowercased() == "passed" {
                completion?(response!.token)
            } else if response?.status?.lowercased() == "shouldverifyv2" {
                self.askForV2Captcha(with: layoutId, amount: amount) { (token) in
                    completion?(token)
                }
            } else {
                completion?(nil)
            }
        }
    }
    
    //MARK: - Prepare for segue -
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case .toResultSegue:
                if let controller = segue.destination as? CompletionViewController {
                    controller.paymentError = self.paymentError
                    controller.configuration = self.configuration
                }
            default:
                super.prepare(for: segue, sender: sender)
                break
            }
        }
    }
}
