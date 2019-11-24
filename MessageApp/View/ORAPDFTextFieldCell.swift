//
//  ORAPDFTextFieldCell.swift
//  Aconex
//
//  Created by Bindu Maharudrappa on 28.09.19.
//  Copyright © 2019 Bindu Maharudrappa. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class KeyboardTextFieldSendButton: UIButton {
    
    // MARK: Properties
    private var selectedBackgroundColor = UIColor.blue
    
    private var deselectedBackgroundColor = UIColor.gray
    
    @IBInspectable var isRounded: Bool = true {
        didSet {
            self.layer.cornerRadius = self.frame.size.width / 2.0
            self.layer.masksToBounds = true
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? selectedBackgroundColor : deselectedBackgroundColor
        }
    }
}

class ORAPDFTextFieldCell: UIView, UITextViewDelegate {
    
    @IBOutlet weak var chatTextView: CommentTextView! {
        didSet {
            chatTextView.autocorrectionType = .no
            chatTextView.delegate = self
            chatTextView.showsVerticalScrollIndicator = true
            chatTextView.isScrollEnabled = false
        }
    }
    
    @IBOutlet weak var sendButton: KeyboardTextFieldSendButton! {
        didSet {
            sendButton.isEnabled = false
        }
    }
    
    /// Callback on tap of send button
    var onSendComment: ((_ comment: String?) -> Void)?
    var onTextChangeSend: ((_ text: String?) -> Void)?
    var onReturnFromKeyboard: (() -> Void)?
    
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = self.chatTextView.sizeThatFits(CGSize(width: self.chatTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
    
    // MARK: - Initializer
    static func initialize() -> ORAPDFTextFieldCell? {
        if let chatView = UINib(nibName: "ORAPDFTextFieldCell", bundle: .main).instantiate(withOwner: self, options: nil).first as? ORAPDFTextFieldCell {
            return chatView
        }
        return nil
    }
    
//    func updateCountLabel() {
//        self.counterLabel.text = "\(self.chatTextView.text.count)/\(self.chatTextView.maximumLength + 1)"
//    }
    
    func updateTopConstraint(with constant: CGFloat) {
        self.textViewTopConstraint.constant = constant
    }

    // MARK: - Action

    @IBAction func onSendComment(_ sender: Any) {
        self.onSendComment?(self.chatTextView.text)
        self.chatTextView.text = ""
//        self.counterLabel.text = "\(self.chatTextView.text.count)/\(self.chatTextView.maximumLength + 1)"
        self.sendButton.isEnabled = true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {

           // counterLabel.text = "\(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count)/\(chatTextView.maximumLength + 1)"
             self.onTextChangeSend?(textView.text)
            // Enable Disable
            sendButton.isEnabled = true//(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            
            var frame = textView.frame
            frame.size.height = textView.contentSize.height
            chatTextView.frame = frame
            chatTextView.isScrollEnabled = false
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == "\n" {
            onReturnFromKeyboard?()
            return false
        }
        // Avoid Blank space is acceptence in Input field text area.
        if !newText.isEmpty {
            if trimmedText.isEmpty {
                return false
            }
        }
        
        return true
    }
}
