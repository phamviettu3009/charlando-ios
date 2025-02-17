//
//  ResourceRepositoryImpl.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation

struct ResourceRepositoryImpl: ResourceRepository {
    static let shared = ResourceRepositoryImpl()
    
    let apiManager = APIManager.shared
    
    func uploadResource(multipart: MultipartRequest) async throws -> [ResourceResponse] {
        let endpoint = UPLOAD_PRIVATE_MULTI
        let data = try await apiManager.performRequest(endpoint: endpoint, multipart: multipart)
        let resources = try JSONDecoder().decode([ResourceResponse].self, from: data)
        return resources
    }
    
    func uploadAvatar(multipart: MultipartRequest) async throws -> [ResourceResponse] {
        let endpoint = UPLOAD_PUBLIC_MULTI
        let data = try await apiManager.performRequest(endpoint: endpoint, multipart: multipart)
        let resources = try JSONDecoder().decode([ResourceResponse].self, from: data)
        return resources
    }
}
