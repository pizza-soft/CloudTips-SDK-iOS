//
//  InputCardDataViewController.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import UIKit
import Cloudpayments
import WebKit

class CardViewController: BasePaymentViewController, WKNavigationDelegate {
    @IBOutlet private weak var cardNumberTextField: TextField!
    @IBOutlet private weak var cardExpDateTextField: TextField!
    @IBOutlet private weak var cardCvcTextField: TextField!
    @IBOutlet private weak var progressContainerView: UIView!
    @IBOutlet private weak var progressView: ProgressView!
    @IBOutlet weak var payButton: Button!
    @IBOutlet weak var psIcon: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet private weak var googleWebView: WKWebView!
    
    private var threeDsView: UIView?
    
    private let threeDsProcessor = ThreeDsProcessor()

    //MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareUI()
        
        self.googleWebView.isOpaque = false
        self.googleWebView.backgroundColor = UIColor.clear
        self.googleWebView.scrollView.isScrollEnabled = false
        self.googleWebView.scrollView.backgroundColor = UIColor.clear
        self.googleWebView.loadHTMLString(RecaptchaViewModel.googleLicenseHtmlString, baseURL: nil)
        self.googleWebView.navigationDelegate = self
    }
    
    private func prepareUI(){
        self.payButton.onAction = {
            if self.isValid() {
                self.showProgress()
                self.askForV3Captcha(with: self.configuration.layout?.layoutId ?? "", amount: self.paymentData?.amount.stringValue ?? "0") { (token) in

                    self.pay(token: token ?? "")
                }
            }
        }
        
        //let amountForTitle = self.paymentData!.feeFromPayer ? self.paymentData?.amountPayerFee : self.paymentData?.amount
        
        if let amount = self.paymentData!.feeFromPayer ? self.paymentData?.amountPayerFee : self.paymentData?.amount {
            self.payButton.setTitle("Оплатить " + NumberFormatter.currencyString(from: amount), for: .normal)
        }
        
        self.cardNumberTextField.inputAccessoryView = self.toolbar
        self.cardExpDateTextField.inputAccessoryView = self.toolbar
        self.cardCvcTextField.inputAccessoryView = self.toolbar
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mainText]
        self.cardNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Номер карты", attributes: attributes)
        self.cardExpDateTextField.attributedPlaceholder = NSAttributedString.init(string: "ММ/ГГ", attributes: attributes)
        self.cardCvcTextField.attributedPlaceholder = NSAttributedString.init(string: "CVC", attributes: attributes)
        
        self.cardNumberTextField.didChange = {
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                self.cardNumberTextField.text = cardNumber
                
                if cardNumber.cardNumberIsValid() {
                    self.cardExpDateTextField.becomeFirstResponder()
                    self.cardNumberTextField.isErrorMode = false
                } else {
                    let cleanCardNumber = cardNumber.clearCardNumber()
                    
                    //MAX CARD NUMBER LENGHT
                    self.cardNumberTextField.isErrorMode = cleanCardNumber.count == 19
                }
                
                self.updatePaymentSystemIcon(cardNumber: cardNumber)
            }
        }
        
        self.cardNumberTextField.didEndEditing = {
            self.validateAndErrorCardNumber()
        }
        
        self.cardExpDateTextField.didChange = {
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                self.cardExpDateTextField.text = cardExp
                
                self.cardExpDateTextField.isErrorMode = false
                if cardExp.count == 5 {
                    self.cardCvcTextField.becomeFirstResponder()
                }
            }
        }
        
        self.cardExpDateTextField.didEndEditing = {
            self.validateAndErrorCardExp()
        }

        self.cardCvcTextField.didChange = {
            if let text = self.cardCvcTextField.text?.formattedCardCVV() {
                self.cardCvcTextField.text = text
                
                self.cardCvcTextField.isErrorMode = false
                if text.count == 3 {
                    self.cardCvcTextField.resignFirstResponder()
                }
            }
        }
        
        self.cardCvcTextField.didEndEditing = {
            self.validateAndErrorCardCVV()
        }
        
        self.cardNumberTextField.shouldReturn = {
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                if cardNumber.cardNumberIsValid() {
                    self.cardExpDateTextField.becomeFirstResponder()
                }
            }
            return false
        }
        
        self.cardExpDateTextField.shouldReturn = {
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                if cardExp.count == 5 {
                    self.cardCvcTextField.becomeFirstResponder()
                }
            }
            
            return false
        }

        self.cardCvcTextField.shouldReturn = {
            if let text = self.cardCvcTextField.text?.formattedCardCVV() {
                if text.count == 3 {
                    self.cardCvcTextField.resignFirstResponder()
                }
            }
            
            return false
        }
    }
    
    private func isValid() -> Bool {
        let cardNumberIsValid = self.cardNumberTextField.text?.formattedCardNumber().cardNumberIsValid() == true
        let cardExpIsValid = self.cardExpDateTextField.text?.formattedCardExp().count == 5
        let cardCvcIsValid = self.cardCvcTextField.text?.formattedCardCVV().count == 3
        
        self.validateAndErrorCardNumber()
        self.validateAndErrorCardExp()
        self.validateAndErrorCardCVV()
        
        return cardNumberIsValid && cardExpIsValid && cardCvcIsValid
    }
    
    private func validateAndErrorCardNumber(){
        if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
            self.cardNumberTextField.isErrorMode = !cardNumber.cardNumberIsValid()
        }
    }
    
    private func validateAndErrorCardExp(){
        if let cardExp = self.cardExpDateTextField.text?.cleanCardExp(), cardExp.count == 4 {
            let indexTwo = cardExp.index(cardExp.startIndex, offsetBy: 2)
            let firstTwo = String(cardExp[..<indexTwo])
            let firstTwoNum = Int(firstTwo) ?? 0
            
            self.cardExpDateTextField.isErrorMode = firstTwoNum == 0 || firstTwoNum > 12
            
        } else {
            self.cardExpDateTextField.isErrorMode = true
        }
    }
    
    private func validateAndErrorCardCVV(){
        self.cardCvcTextField.isErrorMode = self.cardCvcTextField.text?.count != 3
    }
    
    private func updatePaymentSystemIcon(cardNumber: String?){
        if let number = cardNumber {
            let cardType = Card.cardType(from: number)
            let icon: UIImage?
            switch cardType {
            case .visa:
                icon = UIImage.named("ic_visa")
            case .americanExpress:
                icon = UIImage.named("ic_amex")
            case .jcb:
                icon = UIImage.named("ic_jcb")
            case .maestro:
                icon = UIImage.named("ic_maestro")
            case .masterCard:
                icon = UIImage.named("ic_master")
            case .mir:
                icon = UIImage.named("ic_mir")
            case .troy:
                icon = UIImage.named("ic_troy")
            default:
                icon = nil
            }
            self.psIcon.image = icon
        } else {
            self.psIcon.image = nil
        }
    }
    
    //MARK: - Actions -
    
    private func pay(token: String) {
        print("PAY")
        if let paymentData = self.paymentData {
            self.getPublicId(with: paymentData.layoutId) { (publicId, error) in
                if let publicId = publicId, let cryptogram = Card.makeCardCryptogramPacket(with: self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.text!, cvv: self.cardCvcTextField.text!, merchantPublicID: publicId) {
                    self.auth(with: paymentData, cryptogram: cryptogram, captchaToken: token) { (response, error) in
                        self.hideProgress()
                        if let response = response {
                            if response.statusCode == .need3ds, let acsUrl = response.acsUrl, let md = response.md, let paReq = response.paReq {
                                self.showThreeDs(with: acsUrl, md: md, paReq: paReq)
                            } else if response.statusCode == .success {
                                self.onPaymentSucceeded()
                            } else if response.statusCode == .failure {
                                let ctError = CloudtipsError.init(message: response.message ?? "Ошибка")
                                self.onPaymentFailed(with: ctError)
                            }
                        } else {
                            let ctError = CloudtipsError.init(message: error?.localizedDescription ?? "Ошибка")
                            self.onPaymentFailed(with: ctError)
                        }
                    }
                } else {
                    self.hideProgress()
                }
            }
        }
    }
    
    private func showThreeDs(with acsUrl: String, md: String, paReq: String) {
        let threeDsData = ThreeDsData.init(transactionId: md, paReq: paReq, acsUrl: acsUrl)
        self.threeDsProcessor.make3DSPayment(with: threeDsData, delegate: self)
    }
    
    @IBAction private func onDone(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //MARK: - Progress -
    
    private func showProgress(){
        self.progressView.startAnimation()
        
        self.progressContainerView.alpha = 0
        self.progressContainerView.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.progressContainerView.alpha = 1
        }
    }
    
    private func hideProgress() {
        UIView.animate(withDuration: 0.25) {
            self.progressContainerView.alpha = 0
        } completion: { (status) in
            if status {
                self.progressContainerView.isHidden = true
                self.progressView.stopAnimation()
            }
        }
    }
    
    //MARK: - WKNavigationDelegate -
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

//MARK: - ThreeDsDelegate -

extension CardViewController: ThreeDsDelegate {
    func willPresentWebView(_ webView: WKWebView) {
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
            closeButton.setImage(UIImage.named("ic_close"), for: .normal)
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
    
    func onAuthorizationCompleted(with md: String, paRes: String) {
        self.hideThreeDs()
        self.showProgress()
        
        self.post3ds(md: md, paRes: paRes) { (response, error) in
            self.hideProgress()
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
    
    func onAuthorizationFailed(with html: String) {
        self.hideThreeDs()
        self.hideProgress()
        
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
