//
//  NavigationManager.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import Foundation

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var stacks = [Destination]()
    
    func navigateTo(_ destination: Destination) {
        DispatchQueue.main.async {
            self.stacks.append(destination)
        }
    }
    
    func navigateTo(_ destination: [Destination]) {
        DispatchQueue.main.async {
            self.stacks.append(contentsOf: destination)
        }
    }
    
    func back() {
        DispatchQueue.main.async {
            if self.stacks.isEmpty {
                return
            }
            self.stacks.removeLast()
        }
    }
    
    func back(_ count: Int) {
        DispatchQueue.main.async {
            if (self.stacks.count < count) {
                return
            }
            self.stacks.removeLast(count)
        }
    }
}
