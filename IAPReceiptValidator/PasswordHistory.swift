//
//  PasswordHIstory.swift
//  IAPReceiptValidator
//
//  Created by clawoo on 08/08/2019.
//  Copyright © 2019 clawoo. All rights reserved.
//

import Foundation


class PasswordHistory {
    private(set) var passwords: [String] = []
    
    private lazy var destinationPath: String? = {
        guard let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return applicationSupport.appendingPathComponent("Passwords.plist").path
    }()
    
    init() {
        load()
    }
    
    private func load() {
        if let destinationPath = destinationPath, let passwords = NSKeyedUnarchiver.unarchiveObject(withFile: destinationPath) as? [String] {
            self.passwords = passwords
        }
    }
    
    private func save() {
        guard let destinationPath = destinationPath else {
            return
        }
        NSKeyedArchiver.archiveRootObject(passwords, toFile: destinationPath)
    }
    
    func add(password: String) {
        guard !password.isEmpty else {
            return
        }
        passwords = [password] + passwords.filter({ $0 != password })
        save()
    }
}
