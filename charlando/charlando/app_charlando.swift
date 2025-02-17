//
//  flow_iosApp.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import SwiftUI

@main
struct app_charlando: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
