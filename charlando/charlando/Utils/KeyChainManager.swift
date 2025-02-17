//
//  KeyChainManager.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/11/2023.
//

import Foundation

class KeyChainManager {    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
    }
    
    static func save(service: String, account: String, data: Data) throws {
        let query = [
            kSecValueData: data,
            kSecAttrAccount: account,
            kSecAttrServer: service,
            kSecClass: kSecClassInternetPassword
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        guard status != errSecDuplicateItem else {
            try update(service: service, account: account, data: data)
            return
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("SAVED")
    }
    
    static func get(service: String, account: String) -> Data? {
        let query = [
            kSecAttrAccount: account,
            kSecAttrServer: service,
            kSecClass: kSecClassInternetPassword,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ] as CFDictionary
        
        var result: AnyObject?
        _ = SecItemCopyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    static func update(service: String, account: String, data: Data) throws {
        let query = [
            kSecAttrAccount: account,
            kSecAttrServer: service,
            kSecClass: kSecClassInternetPassword
        ] as CFDictionary
        
        let attributes = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    static func delete(service: String, account: String) throws {
        let query = [
            kSecAttrAccount: account,
            kSecAttrService: service,
            kSecClass: kSecClassInternetPassword,
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        
        print("status ======> \(status)")
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}
