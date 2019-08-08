//
//  ViewController.swift
//  IAPReceiptValidator
//
//  Created by clawoo on 07/08/2019.
//  Copyright © 2019 clawoo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    enum ValidationStatus {
        case idle
        case validating
        case success
        case failed(String)
    }
    
    @IBOutlet weak var inputTextView: NSTextView!
    @IBOutlet weak var outputTextView: NSTextView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusIndicator: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var passwordField: NSComboBox!

    private var status = ValidationStatus.idle {
        didSet {
            switch status {
            case .idle:
                spinner.stopAnimation(nil)
                statusIndicator.isHidden = true
                statusLabel.stringValue = ""
            case .validating:
                spinner.startAnimation(nil)
                statusIndicator.isHidden = true
                statusLabel.stringValue = "Validating..."
            case .success:
                spinner.stopAnimation(nil)
                statusIndicator.stringValue = "✅"
                statusIndicator.isHidden = false
                statusLabel.stringValue = "Done."

            case .failed(let error):
                spinner.stopAnimation(nil)
                statusIndicator.stringValue = "❌"
                statusIndicator.isHidden = false
                statusLabel.stringValue = error
            }
        }
    }
    
    private var history = PasswordHistory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        status = .idle
        
        passwordField.removeAllItems()
        passwordField.addItems(withObjectValues: history.passwords)
    }
    
    @IBAction func onValidateBtnTapped(_ sender: Any) {
        
        guard !inputTextView.string.isEmpty else {
            status = .failed("Please paste the receipt data")
            return
        }
        
        history.add(password: passwordField.stringValue)
        passwordField.removeAllItems()
        passwordField.addItems(withObjectValues: history.passwords)
        
        validate(useSandbox: false)
    }
    
    private func validate(useSandbox: Bool) {
        status = .validating
        
        Network.shared.validate(receipt: inputTextView.string, password: passwordField.stringValue, useSandbox: useSandbox) { (response, error) in
            if let error = error {
                self.handle(error: error)
                return
            }
            if let response = response, let status = response["status"] as? Int {
                self.handle(response: response, status: status)
            }
        }
    }
    
    private func handle(response: [String : Any], status: Int) {
        
        guard status != 21007 else {
            validate(useSandbox: true)
            return
        }

        spinner.stopAnimation(nil)
        self.outputTextView.string = String(data: try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted), encoding: .utf8)!

        if status == 0 {
            self.status = .success
        }
        else {
            let errors: [Int : String] = [
                21000 : "The App Store could not read the JSON object you provided.",
                21002 : "The data in the receipt-data property was malformed or missing.",
                21003 : "The receipt could not be authenticated.",
                21004 : "The shared secret you provided does not match the shared secret on file for your account.",
                21005 : "The receipt server is not currently available.",
                21006 : "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.",
                21007 : "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.",
                21008 : "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.",
                21010 : "This receipt could not be authorized. Treat this the same as if a purchase was never made.",
            ]
            let error = errors[status] ?? "Internal data access error. (\(status))"
            self.status = .failed(error)
        }
    }
    
    func handle(error: Error) {
        status = .failed(error.localizedDescription)
    }
}
