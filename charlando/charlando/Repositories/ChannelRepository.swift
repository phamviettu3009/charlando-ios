//
//  ChannelRepository.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation

protocol ChannelRepository {
    func getListChannel(page: Int, keyword: String) async throws -> [Channel]
    func createChannelGroup(channelGroupRequest: ChannelGroupRequest) async throws -> Any
    func getChannel(channelID: UUID) async throws -> Channel
    func updateChannel(channelID: UUID, groupChannelUpdateRequest: GroupChannelUpdateRequest) async throws -> Channel
    func getRole(channelID: UUID) async throws -> MyRole
    func removeMembers(channelID: UUID, members: GroupChannelMembers) async throws -> Channel
    func addMembers(channelID: UUID, members: GroupChannelMembers) async throws -> Channel
    func getFriendOutsideChannel(page: Int, keyword: String, channelID: UUID) async throws -> [User]
    func leaveGroup(channelID: UUID) async throws -> Any
    func addAdminRole(channelID: UUID, members: GroupChannelMembers) async throws -> Any
    func revokeAdminRole(channelID: UUID, members: GroupChannelMembers) async throws -> Any
    func setOwnerRole(channelID: UUID, member: GroupChannelMember) async throws -> Any
}
