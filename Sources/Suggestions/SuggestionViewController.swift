//
//  SLSuggestionViewController.swift
//  myluv
//
//  Created by donghyun on 12/11/17.
//  Copyright © 2017 donghyun. All rights reserved.
//

import Foundation
import UIKit

public struct Suggestion {
    public struct Info {
        public let bundleIdentifier: String
        public let appVersion: String
        public let systemVersion: String
        public let locale: String
        public let date: Date
    }

    public struct Content {
        public let email: String?
        public let content: String
    }

    public struct Options {
        public let title: String?
        public let text: String?
        public let useMail: Bool

        public init(title: String? = nil, text: String? = nil, useMail: Bool = false) {
            self.title = title
            self.text = text
            self.useMail = useMail
        }
    }

    public let info: Info
    public let content: Content
}


public protocol SuggestionViewControllerDelegate: AnyObject {
    func suggestionViewController(_ controller: SuggestionViewController, didFinishWith suggestion: Suggestion)
    func suggestionViewControllerDidCancel(_ controller: SuggestionViewController)
}

private extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: .module, comment: "")
    }
}

public class SuggestionViewController: UIViewController {
    private var alreadyAppeared = false
    
    public weak var delegate: SuggestionViewControllerDelegate?

    public var text: String?
    public var placeholder: String?
    public var useMail = true

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak private var textViewTop: NSLayoutConstraint!
    @IBOutlet weak private var mailContainer: UIView!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var containerLayoutBottom: NSLayoutConstraint!
    @IBOutlet weak var containerSuperviewBottom: NSLayoutConstraint!
    
    var systemCode: String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let model = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return model
    }
    
    static public func instantiate(options: Suggestion.Options? = nil, delegate: SuggestionViewControllerDelegate? = nil) -> UIViewController {
        let storyboard = UIStoryboard(name: "Support", bundle: Bundle.module)
        let identifier = "SLSuggestionNavigationController"
        let navigationController = storyboard.instantiateViewController(withIdentifier: identifier) as! UINavigationController
        let suggestionController = navigationController.topViewController as! SuggestionViewController

        if let options {
            suggestionController.title = options.title
            suggestionController.text = options.text
            suggestionController.useMail = options.useMail
        }

        suggestionController.delegate = delegate

        return navigationController
    }
    
    static public func canSendText() -> Bool {
        return true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.title ?? "Suggestions".localized()
        
        updateSendButton(false)
        
        mailField.placeholder = "Suggestion email placeholder".localized()
        textViewPlaceHolderLabel.text = placeholder ?? "Suggestion content placeholder".localized()
        textViewPlaceHolderLabel.isHidden = (text?.count ?? 0) > 0

        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true
        sendButton.setTitle("Submit".localized(), for: .normal)

        textView.text = text
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textViewTop.priority = UILayoutPriority(rawValue: useMail ? 700 : 900)
        mailContainer.isHidden = useMail == false
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setNeedsLayout()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if alreadyAppeared == false {
            textView.becomeFirstResponder()
        }
        alreadyAppeared = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let animationCurve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        
        if let keyboardFrame = keyboardFrame, let animationDuration = animationDuration, let animationCurve = animationCurve {
            let curve = UIView.AnimationOptions(rawValue: animationCurve.uintValue << 16)
            let duration = animationDuration.doubleValue
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, curve], animations: {
                [weak self] in
                self?.containerSuperviewBottom.priority = UILayoutPriority(rawValue: 900)
                self?.containerSuperviewBottom.constant = keyboardFrame.size.height
                self?.view.layoutIfNeeded()
                }, completion: nil)
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let animationCurve = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        
        if let _ = keyboardFrame, let animationDuration = animationDuration, let animationCurve = animationCurve {
            let curve = UIView.AnimationOptions(rawValue: animationCurve.uintValue << 16)
            let duration = animationDuration.doubleValue
            UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, curve], animations: {
                [weak self] in
                self?.containerSuperviewBottom.priority = UILayoutPriority(rawValue: 700)
                self?.containerSuperviewBottom.constant = 0
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func updateSendButton(_ enabled: Bool) {
        sendButton.isEnabled = enabled
        sendButton.backgroundColor = enabled ? UIColor.init(red: 23 / 255, green: 127 / 255, blue: 251 / 255, alpha: 1) : UIColor.lightGray
    }
    
    @IBAction func done() {
        view.endEditing(false)
        updateSendButton(false)
        
        let bundle = Bundle.main
        let bundleIdentifier = bundle.bundleIdentifier!
        let appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as! String
        let systemVersion = UIDevice.current.systemVersion
        let locale = Locale.current.identifier
        
        let info = Suggestion.Info(bundleIdentifier: bundleIdentifier, appVersion: appVersion, systemVersion: systemVersion, locale: locale, date: Date())
        let content = Suggestion.Content(email: self.mailField.text, content: self.textView.text)
        
        let suggestion = Suggestion(info: info, content: content)
        
        if let delegate = delegate {
            delegate.suggestionViewController(self, didFinishWith: suggestion)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(){
        if let delegate = delegate {
            delegate.suggestionViewControllerDidCancel(self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SuggestionViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        updateSendButton(textView.text.count > 0)
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolderLabel.isHidden = textView.text.count > 0
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolderLabel.isHidden = textView.text.count > 0
        updateSendButton(textView.text.count > 0)
    }
}

extension SuggestionViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}
