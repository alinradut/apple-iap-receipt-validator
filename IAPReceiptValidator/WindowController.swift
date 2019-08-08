//
//  WindowController.swift
//  IAPReceiptValidator
//
//  Created by clawoo on 08/08/2019.
//  Copyright © 2019 clawoo. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let closeButton = window?.standardWindowButton(.closeButton)
        closeButton?.target = self
        closeButton?.action = #selector(onCloseBtnPressed)
    }
    
    @objc func onCloseBtnPressed(_ sender: Any?) {
        NSApplication.shared.terminate(sender)
    }
}
