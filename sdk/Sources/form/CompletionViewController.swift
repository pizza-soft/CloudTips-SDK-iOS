//
//  CompletionViewController.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import UIKit

class CompletionViewController: BasePaymentViewController {
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var statusIcon: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var errorTitleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var repeatButton: Button!
    @IBOutlet private weak var closeButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareUI()
        self.updateUI()
    }
    
    private func prepareUI(){
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.masksToBounds = true
        
        self.repeatButton.onAction = {
            self.performSegue(withIdentifier: .unwindToTipsSegue, sender: self)
        }
        
        self.closeButton.onAction = {
            self.dismiss(animated: true)
            
            if (self.isTipsSuccessed) {
                self.configuration.delegate?.onTipsSuccessed()
            } else {
                self.configuration.delegate?.onTipsCancelled()
            }
        }
    }
    
    private func updateUI() {
        if let photoUrl = self.configuration.profile.photoUrl, let url = URL.init(string: photoUrl) {
            self.profileImageView.sd_setImage(with: url, placeholderImage: UIImage.bundle("ic_avatar_placeholder"), options: .avoidAutoSetImage, completed: { (image, error, cacheType, url) in
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
                    self.profileImageView.image = image ?? UIImage.bundle("ic_avatar_placeholder")
                    self.profileImageView.alpha = 1
                }
            })
        }
        
        let name = self.configuration.profile.name ?? ""
        self.nameLabel.isHidden = name.isEmpty
        self.nameLabel.text = name
        
        if let error = self.paymentError {
            
            self.isTipsSuccessed = false
            
            self.statusIcon.image = .iconFailed
            
            self.errorTitleLabel.isHidden = false
            self.messageLabel.text = error.message
            self.messageLabel.textColor = .mainRed
            
            self.repeatButton.setTitle("Попробовать ещё раз", for: .normal)
        } else {
            
            self.isTipsSuccessed = true
            
            var successPageText = self.configuration.profile.successPageText ?? ""
            
            if name.isEmpty {
                successPageText = "Спасибо за платеж с CloudTips!"
            } else if successPageText.isEmpty {
                successPageText = "Радуется чаевым!"
            }
            
            self.statusIcon.image = .iconSuccess
            
            self.errorTitleLabel.isHidden = true
            self.messageLabel.text = successPageText
            self.messageLabel.textColor = .sectionTitleColor
            
            self.repeatButton.setTitle("Отправить ещё", for: .normal)
        }
    }
}
