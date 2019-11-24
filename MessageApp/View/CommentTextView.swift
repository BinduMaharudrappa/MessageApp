//
//  CommentTextView.swift
//  MessageApp
//
//  Created by Bindu Maharudrappa on 28/09/19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class CommentTextView: UITextView {
    
    // MARK: Properties
    public let placeholderLabel: UILabel = UILabel()
    
    // private var placeholderLabelConstraints = [NSLayoutConstraint]()
    /// Optional closure to observe text change from the caller class
    public var onChangeText: ((_ text: String?) -> Void)?
    public var onChangeTextForSegmentLayout: ((_ text: String?) -> Void)?
    
    @IBInspectable open var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    // Maximum length of text. 0 means no limit.
    var maximumLength: Int = 0
    
    override open var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    open var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override open var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override open var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    // MARK: - Constructor
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        #if swift(>=4.2)
        let notificationName = UITextView.textDidChangeNotification
        #else
        let notificationName = NSNotification.Name.UITextView.textDidChangeNotification
        #endif
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: notificationName,
                                               object: nil)
        
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    deinit {
        #if swift(>=4.2)
        let notificationName = UITextView.textDidChangeNotification
        #else
        let notificationName = NSNotification.Name.UITextView.textDidChangeNotification
        #endif
        
        NotificationCenter.default.removeObserver(self,
                                                  name: notificationName,
                                                  object: nil)
    }
    
    // MARK: - UITextView text change handlers
    @objc
    private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
        
        if maximumLength > 0 && text.count > maximumLength {
            let endIndex = text.index(text.startIndex, offsetBy: maximumLength)
            text = String(text[..<endIndex])
            undoManager?.removeAllActions()
        }
        setNeedsDisplay()
        
        // Call text change closure
        self.onChangeText?(text)
        self.onChangeTextForSegmentLayout?(text)
    }
    
    private func updateConstraintsForPlaceholderLabel() {
        placeholderLabel.constraints.forEach({ self.removeConstraint($0) })
        placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8.0).isActive = true
    }
    
    open override var canResignFirstResponder: Bool {
        return true
    }

}
