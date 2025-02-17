//
//  Channel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/11/2023.
//

import SwiftUI
import Foundation

struct ListChannelView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var messageListener: MessageListener
    @EnvironmentObject var viewModel: ListChannelViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.channels, id: \.self) { channel in
                Button {
                    navigationManager.navigateTo(.messageScreen(channelID: channel.id))
                } label: {
                    ChannelItem(channel: Binding.constant(channel))
                }
            }
            .listRowSeparator(.hidden)
            
            VStack {}
                .onAppear {
                    viewModel.loadMoreListChannel()
                }
                .listRowSeparator(.hidden)
        }
        .onChange(of: messageListener.message) { message in
            switch message {
            case .removeChannel(let channelID):
                viewModel.removeChannel(channelID: channelID)
                DispatchQueue.main.async {
                    messageListener.message = nil
                }
            case .none:
                break
            }
        }
    }
}
