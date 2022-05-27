//
//  BasePaymentViewController.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 07.10.2020.
//

import Foundation
import WebKit
import ReCaptcha
import Cloudpayments

public class BasePaymentViewController: BaseViewController, PaymentDelegate {

    internal var configuration: TipsConfiguration!
    internal var paymentData: PaymentData?
    internal var paymentError: CloudtipsError?

    private let threeDsProcessor = ThreeDsProcessor()
    private var threeDsView: UIView?

    var isTipsSuccessed: Bool = false
    
    @IBOutlet weak var captchaWebViewContainer: UIView?
    var captchaWebView: WKWebView?
    lazy var recaptchaViewModel: RecaptchaViewModel = {
        RecaptchaViewModel(isSandboxMode: configuration.testMode)
    }()
    
    private lazy var recaptchaV2 = {
        try? ReCaptcha(
            apiKey: configuration.testMode ? "6Ld_xtkZAAAAAA2IooQrY2ecIhhuftTG_n_3xodn" : "6LcXy9YZAAAAAOkgXGwEPNKKsYqAHcT6DYhCSkg4",
            baseURL: URL(string: HTTPResource.baseURLString)
        )}()

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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.bundle("ic_close"), style: .plain, target: self, action: #selector(close))
    }
    
    @objc func close() {
        self.dismiss(animated: true)
        if (self.isTipsSuccessed) {
            self.configuration.delegate?.onTipsSuccessed()
        } else {
            self.configuration.delegate?.onTipsCancelled()
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

    internal func showThreeDs(with acsUrl: String, md: String, paReq: String) {
        let threeDsData = ThreeDsData.init(transactionId: md, paReq: paReq, acsUrl: acsUrl)
        self.threeDsProcessor.make3DSPayment(with: threeDsData, delegate: self)
    }
    
    func askForV3Captcha(with layoutId: String, amount: String, completion: ((_ token: String?) -> ())?){
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        recaptchaViewModel.onCaptchaVerified = { [unowned self] token in
            if let token = token {
                self.validateCaptchaToken(version: 3, token: token, amount: amount, layoutId: layoutId) { (token) in
                    completion?(token)
                }
            } else {
                completion?(nil)
            }
        }
        recaptchaViewModel.start()

        let contentController = WKUserContentController()
        contentController.add(recaptchaViewModel, name: recaptchaViewModel.handlerName)

        configuration.userContentController = contentController

        captchaWebView = WKWebView.init(frame: captchaWebViewContainer?.bounds ?? .zero, configuration: configuration)
        captchaWebViewContainer?.addSubview(captchaWebView!)
        captchaWebViewContainer?.bindFrameToSuperviewBounds()
        captchaWebView!.loadHTMLString(recaptchaViewModel.html, baseURL: URL.init(string: HTTPResource.baseURLString))
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

// MARK: - ThreeDsDelegate -

extension BasePaymentViewController: ThreeDsDelegate {

    public func willPresentWebView(_ webView: WKWebView) {
        if let view = self.navigationController?.view {
            let threeDsContainerView = UIView.init(frame: view.bounds)
            threeDsContainerView.translatesAutoresizingMaskIntoConstraints = false
            threeDsContainerView.backgroundColor = .white
            view.addSubview(threeDsContainerView)
            threeDsContainerView.bindFrameToSuperviewBounds()

            let headerView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: threeDsContainerView.frame.width, height: 56)))
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.backgroundColor = .veryLightBlue

            headerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
            headerView.layer.shadowRadius = 4.0
            headerView.layer.shadowOffset = CGSize.init(width: 0, height: -2)
            headerView.layer.shadowOpacity = 0.5
            headerView.layer.shadowPath = UIBezierPath(rect: headerView.bounds).cgPath
            headerView.layer.masksToBounds = false

            threeDsContainerView.addSubview(headerView)
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: threeDsContainerView.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: threeDsContainerView.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: threeDsContainerView.trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: 56)
            ])

            let closeButton = UIButton.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 56, height: 56)))
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.setImage(UIImage.bundle("ic_close"), for: .normal)
            closeButton.addTarget(self, action: #selector(onCloseThreeDs(_:)), for: .touchUpInside)
            headerView.addSubview(closeButton)
            NSLayoutConstraint.activate([
                closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                closeButton.heightAnchor.constraint(equalToConstant: 56),
                closeButton.widthAnchor.constraint(equalToConstant: 56)
            ])

            webView.frame = threeDsContainerView.bounds
            webView.translatesAutoresizingMaskIntoConstraints = false
            threeDsContainerView.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: threeDsContainerView.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: threeDsContainerView.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: threeDsContainerView.bottomAnchor)
            ])

            threeDsContainerView.bringSubviewToFront(webView)

            threeDsContainerView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                threeDsContainerView.alpha = 1
            }

            self.threeDsView = threeDsContainerView
        }
    }

    public func onAuthorizationCompleted(with md: String, paRes: String) {
        self.hideThreeDs()
        //self.showProgress()

        self.post3ds(md: md, paRes: paRes) { (response, error) in
            //self.hideProgress()
            if let response = response {
                if response.statusCode == .success {
                    self.onPaymentSucceeded()
                } else {
                    let error = CloudtipsError.init(message: response.message ?? "Ошибка")
                    self.onPaymentFailed(with: error)
                }
            } else {
                let error = CloudtipsError.init(message: error?.localizedDescription ?? "Ошибка")
                self.onPaymentFailed(with: error)
            }
        }
    }

    public func onAuthorizationFailed(with html: String) {
        self.hideThreeDs()
        //self.hideProgress()

        let error = CloudtipsError.init(message: html)
        self.onPaymentFailed(with: error)
    }

    @objc private func onCloseThreeDs(_ sender: UIButton) {
        self.hideThreeDs()
    }

    private func hideThreeDs(){
        UIView.animate(withDuration: 0.3) {
            self.threeDsView?.alpha = 0
        } completion: { (status) in
            self.threeDsView?.removeFromSuperview()
            self.threeDsView = nil
        }

    }
}
