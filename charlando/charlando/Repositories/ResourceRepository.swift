//
//  ResourceRepository.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation

protocol ResourceRepository {
    func uploadResource(multipart: MultipartRequest) async throws -> [ResourceResponse]
    func uploadAvatar(multipart: MultipartRequest) async throws -> [ResourceResponse]
}
