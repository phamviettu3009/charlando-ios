//
//  ContentViewViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/11/2023.
//

import Foundation
import SwiftUI

class ContentViewViewModel: ViewModel {
    let apiManager: APIManager = APIManager.shared
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isLoggedIn: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: Notification.Name("logout"), object: nil)
        guard let data = KeyChainManager.get(
            service: SERVICE_NAME,
            account: ACCOUNT_NAME
        ) else {
            return
        }
        
        let decoder = JSONDecoder()
        let token = try? decoder.decode(Token.self, from: data)
            
        if (token?.accessToken != nil) {
            Task {
                await apiManager.getNewAccessToken()
                SocketIOManager.shared.setup() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        NotificationCenter.default.post(name: Notification.Name("initSocketListChannel"), object: nil)
                    }
                }
            }
            self.isLoggedIn = true
        }
    }
    
    @objc private func logout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            self.isLoggedIn = false
        }
    }
    
    func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    func loader(_ value: Bool, _ caseLoader: LoadCase?) {
        DispatchQueue.main.async {}
    }
    
    func resetData() {
        DispatchQueue.main.async {
            self.message = nil
            self.messageColor = .red
            self.isLoggedIn = false
        }
    }
}
