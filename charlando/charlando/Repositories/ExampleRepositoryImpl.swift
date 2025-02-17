//
//  ExampleRepositoryImpl.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 23/11/2023.
//

import Foundation

class ExampleRepositoryImpl: ExampleRepository {
    static let shared = ExampleRepositoryImpl()
    
    let apiManager = APIManager.shared
}
