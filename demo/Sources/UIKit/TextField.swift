//
//  TextField.swift
//  Cloudtips-SDK-iOS-Demo
//
//  Created by a.ignatov on 02.11.2021.
//

import Foundation
import UIKit

class TextField: UITextField, UITextFieldDelegate {
    private var underlineView : UIView?
    
    @IBInspectable var defaultTextColor: UIColor = UIColor.black
    @IBInspectable var errorColor: UIColor = UIColor.red
    
    @IBInspectable var activeUnderlineColor: UIColor = UIColor.clear
    @IBInspectable var passiveUnderlineColor: UIColor = UIColor.clear

    @IBInspectable var activeBgColor: UIColor = UIColor.clear
    @IBInspectable var passiveBgColor: UIColor = UIColor.clear

    @IBInspectable var activeBorderColor: UIColor = UIColor.clear
    @IBInspectable var passiveBorderColor: UIColor = UIColor.clear

    var isErrorMode = false {
        didSet {
            self.updateColors()
        }
    }
    
    public var shouldBeginEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    public  var didBeginEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    public var shouldEndEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    public var didEndEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    public var shouldChangeCharactersInRange : ((_ range: NSRange, _ replacement: String) -> Bool)?{
        didSet{
            delegateIfNeeded()
        }
    }
    public var shouldClear : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    public var shouldReturn : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    public var didChange : (() -> ())?
    
    @IBInspectable var leftImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:leftImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.leftViewSize)
            self.leftView = imageView
            self.leftViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var leftViewSize = CGSize.zero {
        didSet{
            if let view = self.leftView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: leftViewSize)
            }
        }
    }
    
    @IBInspectable var rightImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:rightImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.rightViewSize)
            self.rightView = imageView
            self.rightViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var rightViewSize = CGSize.zero {
        didSet{
            if let view = self.rightView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: rightViewSize)
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        self.addTarget(self, action:#selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func delegateIfNeeded() -> Void {
        if self.delegate == nil {
            self.delegate = self
        }
//        else if !self.delegate!.isEqual(self){
//            self.delegate = self
//        }
    }
    
    private func getActiveBorderColor() -> UIColor {
        var color = self.activeBorderColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func getPassiveBorderColor() -> UIColor {
        var color = self.passiveBorderColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func getTextColor() -> UIColor {
        var color = self.defaultTextColor
        if isErrorMode {
            color = self.errorColor
        }
        
        return color
    }
    
    private func updateColors(){
        if self.isEditing {
            self.borderColor = getActiveBorderColor()
        } else {
            self.borderColor = getPassiveBorderColor()
        }
        
        self.textColor = getTextColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) -> Void {
        didChange?()
        setNeedsDisplay()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?() ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.underlineView?.backgroundColor = activeUnderlineColor
        self.backgroundColor = activeBgColor
        self.borderColor = getActiveBorderColor()
        
        didBeginEditing?()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing?() ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.underlineView?.backgroundColor = passiveUnderlineColor
        self.backgroundColor = passiveBgColor
        self.borderColor = getPassiveBorderColor()
        
        didEndEditing?()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return shouldChangeCharactersInRange?(range, string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return shouldClear?() ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }
    
    private func initialize(){
        self.clipsToBounds = false
        self.delegateIfNeeded()
        
        self.backgroundColor = passiveBgColor
        self.borderColor = getPassiveBorderColor()
        
        self.underlineView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.height, width: self.frame.width, height: 1))
        if let underlineView = self.underlineView {
            self.addSubview(underlineView)
            underlineView.translatesAutoresizingMaskIntoConstraints = false
            underlineView.backgroundColor = self.passiveUnderlineColor
            
            NSLayoutConstraint.activate([
                underlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                underlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
                underlineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
}

