//
//  ExampleViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/11/2023.
//

import Foundation
import SwiftUI

class ExampleViewModel: ViewModel {
     enum LoadType: LoadCase {
        case LoadingListExample
    }
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isLoadingListExample: Bool = false
    
    func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.LoadingListExample:
                self.isLoadingListExample = value
                break
            default:
                break
            }
        }
    }
    
    func resetData() {
        DispatchQueue.main.async {
            self.message = nil
            self.messageColor = .red
            self.isLoadingListExample = false
        }
    }
}
