//
//  ContentView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import SwiftUI
import NavigationStackBackport

struct ContentView: View {
    @StateObject var viewModel = ContentViewViewModel()
    @StateObject var navigationManager = NavigationManager()
    let messageListener = MessageListener()
    
    @AppStorage("language") private var language: String = "default"
    @AppStorage("useTheme") private var useTheme: Theme = .systemDefault
    
    init() {
        APIManager.language = language == "default" ? systemLanguageCode : language
        if let token = APIManager.shared.getTokenFromKeyChainManager() {
            APIManager.shared.setToken(token: token.accessToken)
        }
    }
    
    var body: some View {
        NavigationStackBackport.NavigationStack(path: $navigationManager.stacks) {
            Group {
                if viewModel.isLoggedIn {
                    BottomNavigation()
                } else {
                    LoginScreen()
                        .navigationBarHidden(true)
                }
            }
            .backport.navigationDestination(for: Destination.self) { destination in
                Group {
                    switch (destination) {
                    case .messageScreen(let channelID):
                        MessageScreen(channelID: channelID)
                    case .register:
                        RegisterScreen()
                            .navigationBarTitleDisplayMode(.inline)
                    case .createGroupChannel:
                        CreateGroupChannelScreen()
                    case .groupChannel(channelID: let channelID):
                        GroupChannelScreen(channelID: channelID)
                    case .userInfo(userID: let userID):
                        UserInfoScreen(userID: userID)
                    case .requestAddFriend:
                        ListRequestAddFriendScreen()
                    case .deviceManager:
                        DeviceManagerScreen()
                    case .changePassword:
                        ChangePasswordScreen()
                    case .forgotPassword:
                        ForgotPassword()
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        .environmentObject(navigationManager)
        .environmentObject(viewModel)
        .environmentObject(messageListener)
        .preferredColorScheme(useTheme.colorScheme)
        .environment(\.locale, .init(identifier: language == "default" ? systemLanguageCode : language))
        .environment(\.managedObjectContext, CoreDataProvider.shared.viewContext)
        .onChange(of: language) { lang in
            APIManager.language = lang == "default" ? systemLanguageCode : lang
        }
        .onOpenURL { url in
            deepLinkHandler(url: url)
        }
    }
    
    private func deepLinkHandler(url: URL) {
        let string = url.absoluteString
        let components = string.components(separatedBy: "?")
        let endpoint = extractEndpoint(rawURL: components[0])
        let paramsHashMap = extractParams(components: components)
        
        switch endpoint {
        case "message-screen":
            guard let channelIDString = paramsHashMap["channelID"] else { return }
            guard let channelID: UUID = UUID(uuidString: channelIDString) else { return }
            navigationManager.navigateTo(.messageScreen(channelID: channelID))
            break
        case "user-info-screen":
            guard let userIDString = paramsHashMap["userID"] else { return }
            guard let userID: UUID = UUID(uuidString: userIDString) else { return }
            navigationManager.navigateTo(.userInfo(userID: userID))
            break
        default:
            break
        }
    }
    
    private func extractEndpoint(rawURL: String) -> String {
        let endpoint = rawURL.replacingOccurrences(of: "appCharlando://", with: "")
        return endpoint
    }
    
    private func extractParams(components: [String]) -> [String:String] {
        var paramsHashMap = [String: String]()
        
        if (components.count >= 2) {
            let paramStrings = components[1].components(separatedBy: "&")
            for paramString in paramStrings {
                let componentParams = paramString.components(separatedBy: "=")
                if componentParams.count == 2 {
                    let key = componentParams[0]
                    let value = componentParams[1]
                    paramsHashMap[key] = value
                }
            }
        }
        
        return paramsHashMap
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
