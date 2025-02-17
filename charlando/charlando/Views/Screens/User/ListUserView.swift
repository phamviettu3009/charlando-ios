//
//  ListUser.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/11/2023.
//

import Foundation
import SwiftUI

struct ListUserView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: ListUserViewModel
    
    var body: some View {
        LazyVStack {
//            ForEach(viewModel.users, id: \.self) { user in
//                Button(action: {
//                    navigationManager.navigateTo(.userInfo(userID: user.id))
//                }, label: {
//                    UserItem(user: user)
//                })
//                .listSectionSeparator(.hidden, edges: .top)
//            }
//            
//            VStack {}
//                .listRowSeparator(.hidden)
//                .onAppear {
//                    viewModel.loadMoreListUser()
//                }
        }
    }
}

struct ListUserScreen_Preview: PreviewProvider {
    static var previews: some View {
        ListUserView()
    }
}
