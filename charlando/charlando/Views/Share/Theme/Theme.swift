//
//  Theme.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/03/2024.
//

import Foundation
import SwiftUI

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
