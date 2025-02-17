//
//  ConverterUtils.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 26/03/2024.
//

import Foundation

class ConverterUtils {
    static let shared = ConverterUtils()
    
    func convertToData(from anyObject: Any) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: anyObject, options: [])
            return jsonData
        } catch {
            print("Error converting to Data: \(error)")
            return nil
        }
    }
}
