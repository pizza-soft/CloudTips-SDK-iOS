//
//  TipsViewController.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import UIKit
import SDWebImage
import PassKit
import WebKit

public class TipsViewController: BasePaymentViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WKNavigationDelegate {
    @IBOutlet private weak var progressContainerView: UIView!
    @IBOutlet private weak var progressView: ProgressView!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var purposeLabel: UILabel!
    @IBOutlet private weak var amountTextField: TextField!
    @IBOutlet private weak var amountHelperLabel: UILabel!
    @IBOutlet private weak var amountsCollectionView: UICollectionView!
    @IBOutlet private weak var commentTextField: TextField!
    @IBOutlet private weak var applePayButtonContainer: UIView!
    @IBOutlet private weak var payButton: Button!
    @IBOutlet private weak var eulaButton: Button!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var googleWebView: WKWebView!
    @IBOutlet private var containerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var feeFromPayerView: UIView!
    @IBOutlet weak var feeFromPayerSwitch: UISwitch!
    @IBOutlet weak var feeFromPayerLabel: UILabel!
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard, .JCB]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            
            return arr
        }
    }
    
    private let defaultAmounts = [100, 200, 300, 500, 1000, 2000, 3000, 5000]
    private var amount = NSNumber.init(value: 0)
    private var amountPayerFee = NSNumber.init(value: 0)
    private var captchaToken: String?

    
    private var applePaySucceeded = false
    private var amountSettings: AmountSettings?
    
    
    //MARK: - Present -
    
    public class func present(with configuration: TipsConfiguration, from: UIViewController) {
        let navController = UIStoryboard.init(name: "Main", bundle: Bundle.mainSdk).instantiateInitialViewController() as! UINavigationController
        let controller = navController.topViewController as! TipsViewController
        controller.configuration = configuration
        from.present(navController, animated: true, completion: nil)
    }
    
    //MARK: - Lifecycle -

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.init(named: "azure")
        
        HTTPResource.baseApiURLString = configuration.testMode ? HTTPResource.baseApiPreprodURLString : HTTPResource.baseApiProdURLString
        
        self.prepareUI()
        
        self.updateLayout()
        
        self.googleWebView.isOpaque = false
        self.googleWebView.backgroundColor = UIColor.clear
        self.googleWebView.scrollView.isScrollEnabled = false
        self.googleWebView.scrollView.backgroundColor = UIColor.clear
        self.googleWebView.loadHTMLString(RecaptchaViewModel.googleLicenseHtmlString, baseURL: nil)
        self.googleWebView.navigationDelegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.progressContainerView.isHidden {
            self.progressView.startAnimation()
        } else {
            self.progressView.stopAnimation()
        }
    }
    
    @IBAction func unwindToTips(_ segue: UIStoryboardSegue) {
        self.amountTextField.text = ""
        self.commentTextField.text = ""
        
        self.amountsCollectionView.indexPathsForSelectedItems?.forEach {
            self.amountsCollectionView.deselectItem(at: $0, animated: true)
        }
        
        self.amountsCollectionView.reloadData()
    }
    
    //MARK: - Private -
    
    private func initializeApplePay() {
        if !self.configuration.applePayMerchantId.isEmpty && PKPaymentAuthorizationViewController.canMakePayments() {
            let button: PKPaymentButton
            if PKPaymentAuthorizationController.canMakePayments(usingNetworks: self.supportedPaymentNetworks) {
                button = PKPaymentButton.init(paymentButtonType: .plain, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onApplePay(_:)), for: .touchUpInside)
            } else {
                button = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onSetupApplePay(_:)), for: .touchUpInside)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 12.0, *) {
                button.cornerRadius = 4
            } else {
                button.layer.cornerRadius = 4
                button.layer.masksToBounds = true
            }
            
            self.applePayButtonContainer.isHidden = false
            self.applePayButtonContainer.addSubview(button)
            button.bindFrameToSuperviewBounds()
        } else {
            self.applePayButtonContainer.isHidden = true
        }
    }
    
    private func updateLayout() {
        self.contentScrollView.isHidden = true
        self.progressContainerView.isHidden = false
        
        self.api.getLayout(by: self.configuration.phoneNumber) { [weak self] (layouts, error) in
            guard let `self` = self else {
                return
            }
            
            self.checkLayouts(layouts: layouts, error: error, createIfEmpty: true)
        }
    }
    
    private func checkLayouts(layouts: [Layout]?, error: Error?, createIfEmpty: Bool) {
        if let layout = layouts?.first {
            self.configuration.layout = layout
            
            if let layoutId = layout.layoutId {
                DispatchQueue.global().async { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    let updateGroup = DispatchGroup()
                                        
                    updateGroup.enter()
                    self.getPaymentPages(by: layoutId) {
                        updateGroup.leave()
                    }
                    
                    updateGroup.wait()
                    
                    DispatchQueue.main.async {
                        self.contentScrollView.isHidden = false
                        self.progressContainerView.isHidden = true
                        self.progressView.stopAnimation()
                        
                        self.updateUI()
                    }
                }
            }
        } else if createIfEmpty && layouts?.isEmpty == true {
            self.api.offlineRegister(with: self.configuration.phoneNumber, name: self.configuration.userName, agentCode: self.configuration.agentCode) { [weak self] (layouts, error) in
                guard let `self` = self else {
                    return
                }
                
                self.checkLayouts(layouts: layouts, error: error, createIfEmpty: false)
            }
        } else {
            if let msg = error?.localizedDescription {
                print(msg)
            }
        }
    }
        
    private func getPaymentPages(by layoutId: String, completion: @escaping () -> ()) {
        api.getPaymentPages(by: layoutId) { [weak self] (response, error) in
            guard let `self` = self else {
                return
            }
            
            self.configuration.profile.name = response?.nameText
            self.configuration.profile.photoUrl = response?.avatarUrl
            self.configuration.profile.purposeText = response?.paymentMessage?.ru
            self.configuration.profile.successPageText = response?.successMessage?.ru
            self.configuration.feeFromPayerEnabled = response?.payerFee?.enabled
            self.configuration.feeFromPayerState = response?.payerFee?.initialState
            self.amountSettings = response?.amount
            
            completion()
        }
    }
    
    private func prepareUI(){
        self.initializeApplePay()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        
        self.amountTextField.inputAccessoryView = self.toolbar
        self.commentTextField.inputAccessoryView = self.toolbar
        
        self.amountTextField.shouldReturn = {
            self.commentTextField.becomeFirstResponder()
            return false
        }
        self.amountTextField.shouldChangeCharactersInRange = { range, text in
            let possibleCharacters = CharacterSet.decimalDigits.union(CharacterSet.init(charactersIn: ",."))
            var should = possibleCharacters.isSuperset(of: CharacterSet.init(charactersIn: text))
            
            let amountText = self.amountTextField.text ?? ""
            
            if (text.elementsEqual(",") || text.elementsEqual(".")) {
                should = !amountText.contains(",") && !amountText.contains(".")
            } else {
                let string = (self.amountTextField.text ?? "") as NSString
                let newText = string.replacingCharacters(in: range, with: text)
                
                let separator: String?
                if newText.contains(",") {
                    separator = ","
                } else if newText.contains(".") {
                    separator = "."
                } else {
                    separator = nil
                }

                if should {
                    if let separator = separator {
                        let comps = newText.split(separator: separator.first!)
                        if comps.count <= 2 {
                            should = (comps.first?.count ?? 0) < 6
                            
                            if should && comps.count == 2 {
                                should = comps[1].count < 3
                            }
                        }
                    } else {
                        should = newText.count < 6
                    }
                }
            }
        
            return should
        }
        
        self.commentTextField.shouldReturn = {
            self.commentTextField.resignFirstResponder()
            return false
        }
        
        self.amountTextField.didChange = {
            self.setErrorMode(false)
            
            self.amountsCollectionView.indexPathsForSelectedItems?.forEach {
                self.amountsCollectionView.deselectItem(at: $0, animated: true)
            }
            
            self.amountsCollectionView.reloadData()
            
            self.updatePayerFee()
        }
        
        
                
        self.amountsCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
        
        let attributes1: [NSAttributedString.Key : Any] =
            [.foregroundColor : UIColor.mainText,
             .font: UIFont.systemFont(ofSize: 11)]
        let attributedTitle1 = NSMutableAttributedString.init(string: "Совершая платеж, вы соглашаетесь с ", attributes: attributes1)
        
        let attributes2: [NSAttributedString.Key : Any] =
            [.foregroundColor : UIColor.waterBlue,
             .font: UIFont.systemFont(ofSize: 11)]
        let attributedTitle2 = NSMutableAttributedString.init(string: "условиями сервиса", attributes: attributes2)
        
        attributedTitle1.append(attributedTitle2)
        self.eulaButton.setAttributedTitle(attributedTitle1, for: .normal)
        
        self.eulaButton.onAction = {
            if let url = URL.init(string: "https://static.cloudpayments.ru/docs/cloudtips_oferta.pdf"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        self.payButton.onAction = {
            self.onPay()
        }
        
        self.feeFromPayerSwitch.addTarget(self, action: #selector(payerFeeSwitchChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func payerFeeSwitchChanged() {
        
        if (self.feeFromPayerSwitch.isOn) {
            configuration.feeFromPayerState = "Enabled"
        } else {
            configuration.feeFromPayerState = "Disabled"
        }
    }
        
    @objc func updatePayerFee() {
        
        if let amountString = self.amountTextField.text, let amount = NumberFormatter.currencyNumber(from: amountString) {
        
            if let layoutId = self.configuration.layout?.layoutId {
                DispatchQueue.global().async { [weak self] in
                    guard let `self` = self else {
                        return
                    }

                    let updateGroup = DispatchGroup()

                    updateGroup.enter()
                    self.getPayerFee(layoutId: layoutId, amount: amountString) {
                        updateGroup.leave()
                    }

                    updateGroup.wait()

                    DispatchQueue.main.async {
                        self.contentScrollView.isHidden = false
                        self.progressContainerView.isHidden = true
                        self.progressView.stopAnimation()

                        self.updateUI()
                    }
                }
            }
        } else {
            
            self.amountPayerFee = 0
            //self.feeFromPayerLabel.text = "Так вы компенсируете комиссию сервиса, а с вашей карты спишется 0 Р"
        }
    }
    
    private func getPayerFee(layoutId: String, amount: String, completion: @escaping () -> ()) {
        api.getPayerFee(layoutId: layoutId, amount: amount) { [weak self] (response, error) in
            guard let `self` = self else {
                return
            }
            
            self.amountPayerFee = NSNumber.init(value: response?.amountFromPayer ?? 0.00)
            //self.feeFromPayerLabel.text = "Так вы компенсируете комиссию сервиса, а с вашей карты спишется \(response?.amountFromPayer ?? 0.00) Р"
            
            completion()
        }
    }
    
    private func updateUI() {
        //if let profile = self.configuration.profile
            let name = self.configuration.profile.name ?? ""
            if name.isEmpty {
                self.nameLabel.isHidden = true
                self.purposeLabel.text = self.configuration.profile.purposeText ?? "Надеюсь, вам понравилось"
            } else {
                self.nameLabel.isHidden = false
                self.nameLabel.text = name
                self.configuration.profile.purposeText = ""
                self.purposeLabel.text = self.configuration.profile.purposeText ?? "Получит ваши чаевые"
            }
            
        if let photoUrl = self.configuration.profile.photoUrl, let url = URL.init(string: photoUrl) {
                self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage.named("ic_avatar_placeholder"), options: .avoidAutoSetImage, completed: { (image, error, cacheType, url) in
                    if cacheType == .none && image != nil {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.profileImageView.alpha = 0
                        }, completion: { (status) in
                            self.profileImageView.image = image
                            UIView.animate(withDuration: 0.2, animations: {
                                self.profileImageView.alpha = 1
                            })
                        })
                    } else {
                        self.profileImageView.image = image ?? UIImage.named("ic_avatar_placeholder")
                        self.profileImageView.alpha = 1
                    }
                })
            }
        
        
        let minAmount = self.getMinAmount()
        let maxAmount = self.getMaxAmount()
        let minAmountString = NumberFormatter.currencyString(from: NSNumber.init(value: minAmount), withDigits: 0)
        let maxAmountString = NumberFormatter.currencyString(from: NSNumber.init(value: maxAmount), withDigits: 0)
        
        let minMaxString = "Введите сумму от \(minAmountString) до \(maxAmountString)"
        self.amountHelperLabel.text = minMaxString
        
        self.feeFromPayerSwitch.onTintColor = .azure
        
        if (configuration.feeFromPayerEnabled ?? false) {
            self.feeFromPayerView.isHidden = false
        } else {
            self.feeFromPayerView.isHidden = true
        }
        
        if (configuration.feeFromPayerState == "Enabled") {
            self.feeFromPayerSwitch.isOn = true
        } else {
            self.feeFromPayerSwitch.isOn = false

        }
        
        self.feeFromPayerLabel.text = "Так вы компенсируете комиссию сервиса, а с вашей карты спишется \(self.amountPayerFee) Р"
    }
    
    private func getMinAmount() -> Double {
        return self.amountSettings?.getMinAmount() ?? 49
    }
    
    private func getMaxAmount() -> Double {
        return self.amountSettings?.getMaxAmount() ?? 10000
    }
    
    private func showProgress(){
        self.progressContainerView.isHidden = false
        self.progressView.startAnimation()
    }
    
    private func hideProgress(){
        self.progressContainerView.isHidden = true
        self.progressView.stopAnimation()
    }
    
    //MARK: - Actions -
    
    @objc private func onApplePay(_ sender: UIButton) {
        self.amount = NSNumber(value: 0)
        self.applePaySucceeded = false
        
        if let amountString = self.amountTextField.text, let amount = NumberFormatter.currencyNumber(from: amountString), self.validateAmount(amount) {
            self.amount = amount
            
            let amountForPay = feeFromPayerSwitch.isOn ? self.amountPayerFee : self.amount
            
            self.captchaToken = nil
            
                let request = PKPaymentRequest()
                request.merchantIdentifier = self.configuration.applePayMerchantId
                request.supportedNetworks = self.supportedPaymentNetworks
                request.merchantCapabilities = PKMerchantCapability.capability3DS
                request.countryCode = "RU"
                request.currencyCode = "RUB"
                request.paymentSummaryItems = [PKPaymentSummaryItem(label: "CloudTips", amount: NSDecimalNumber.init(value: amountForPay.doubleValue))]
                if let applePayController = PKPaymentAuthorizationViewController(paymentRequest:
                        request) {
                    applePayController.delegate = self
                    applePayController.modalPresentationStyle = .formSheet
                    self.present(applePayController, animated: true, completion: nil)
                }
           
        } else {
            self.setErrorMode(true)
        }
    }
    
    @objc private func onSetupApplePay(_ sender: UIButton) {
        PKPassLibrary().openPaymentSetup()
    }
    
    private func onPay() {
        self.amount = NSNumber(value: 0)
        
        if let amountString = self.amountTextField.text, let amount = NumberFormatter.currencyNumber(from: amountString), self.validateAmount(amount) {
            self.amount = amount
            self.performSegue(withIdentifier: .tipsToCardSegue, sender: self)
        } else {
            self.setErrorMode(true)
        }
    }
    
    private func validateAmount(_ amount: NSNumber) -> Bool {
        var isValid = true
        
        let minAmount = NSNumber(value: self.getMinAmount())
        let maxAmount = NSNumber(value: self.getMaxAmount())
        
        if amount.compare(minAmount) == .orderedAscending {
            isValid = false
        }
        
        if amount.compare(maxAmount) == .orderedDescending {
            isValid = false
        }
        
        if !isValid {
            self.setErrorMode(true)
        }
        return isValid
    }
    
    private func setErrorMode(_ errorMode: Bool) {
        self.amountTextField.isErrorMode = errorMode
        self.amountHelperLabel.textColor = errorMode ? .mainRed : .mainText
    }
    
    @IBAction private func onDone(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //MARK: - UICollectionViewDataSource -
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.defaultAmounts.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultAmountCell", for: indexPath) as! DefaultAmountCell
        let amount = self.defaultAmounts[indexPath.item]
        cell.titleLabel.text = NumberFormatter.currencyString(from: NSNumber(value: amount), withDigits: 0)
        cell.setSelected(cell.isSelected)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DefaultAmountCell {
            let amount = self.defaultAmounts[indexPath.item]
            self.amountTextField.text = String(amount)
            self.setErrorMode(false)
            cell.setSelected(true)
            self.updatePayerFee()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DefaultAmountCell {
            cell.setSelected(false)
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout -
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6.0
    }
    
    //MARK: - Prepare for segue -
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case .tipsToCardSegue:
                if let controller = segue.destination as? CardViewController, let layoutId = self.configuration.layout?.layoutId {
                    let paymentData = PaymentData.init(
                        layoutId: layoutId,
                        amount: self.amount,
                        comment: self.commentTextField.text,
                        amountPayerFee: self.amountPayerFee,
                        feeFromPayer: self.feeFromPayerSwitch.isOn
                    )
                    controller.paymentData = paymentData
                    controller.configuration = self.configuration
                    
                    self.captchaToken = nil
                }
            default:
                super.prepare(for: segue, sender: sender)
                break
            }
        }
    }
    
    //MARK: - Keyboard -
    
    @objc internal override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        
        self.containerBottomConstraint.constant = self.keyboardFrame.height
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    @objc internal override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)

        self.containerBottomConstraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        print("hide")
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

//MARK: - PKPaymentAuthorizationViewControllerDelegate -

extension TipsViewController: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            if let error = self.paymentError {
                self.onPaymentFailed(with: error)
            } else if self.applePaySucceeded {
                self.applePaySucceeded = false
                self.onPaymentSucceeded()
            }
        }
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        if let layoutId = self.configuration.layout?.layoutId, let cryptogram = payment.convertToString() {
            let paymentData = PaymentData.init(
                layoutId: layoutId,
                amount: self.amount,
                comment: self.commentTextField.text,
                amountPayerFee: self.amountPayerFee,
                feeFromPayer: self.feeFromPayerSwitch.isOn
            )
            self.auth(with: paymentData, cryptogram: cryptogram, captchaToken: self.captchaToken ?? "") { (response, error) in
                if response?.statusCode == .success {
                    self.paymentError = nil
                    self.applePaySucceeded = true
                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: []))
                } else {
                    let error = CloudtipsError.init(message: response?.message ?? error?.localizedDescription ?? "")
                    self.paymentError = error
                    completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
                }
            }
            
            self.captchaToken = nil
        } else {
            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
        }

    }
}
