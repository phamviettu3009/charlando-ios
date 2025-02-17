//
//  JSONEncodable.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 21/11/2023.
//

import Foundation

protocol JSONEncodable {
    func asJson() -> Data?
}

extension JSONEncodable where Self: Encodable {
    func asJson() -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Error encoding struct to JSON: \(error)")
            return nil
        }
    }
}
