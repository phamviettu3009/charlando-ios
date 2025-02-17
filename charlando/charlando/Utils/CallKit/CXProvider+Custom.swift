//
//  CXProvider+Custom.swift
//  charlando
//
//  Created by Phạm Việt Tú on 04/07/2024.
//

import CallKit
import UIKit

extension CXProvider {
    // To ensure initializing only at once. Lazy stored property doesn't ensure it.
    static var custom: CXProvider {
        
        // Configure provider with sendbird's customzied configuration.
        let configuration = CXProviderConfiguration.custom
        let provider = CXProvider(configuration: configuration)
        
        return provider
    }
}

extension CXProviderConfiguration {
    
    static var custom: CXProviderConfiguration {
        let configuration = CXProviderConfiguration(localizedName: "App Name Here")
        
        // Native call log shows video icon if it was video call.
        configuration.supportsVideo = true
        configuration.maximumCallsPerCallGroup = 1
        
        // Support generic type to handle *User ID*
        configuration.supportedHandleTypes = [.generic]
        
        // Icon image forwarding to app in CallKit View
        if let iconImage = UIImage(named: "App Icon") {
            configuration.iconTemplateImageData = iconImage.pngData()
        }
        
        // Ringing sound
        configuration.ringtoneSound = "Rington.caf"
        
        return configuration
    }
}
