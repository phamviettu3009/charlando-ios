//
//  ListResponse.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 25/11/2023.
//

import Foundation

struct ListResponse<T: Decodable>: Decodable {
    var data: [T] = []
    var meda: Meta? = nil
}


struct Meta: Decodable {
    var currentPage: Int
    var totalPages: Int
    var sizePerPage: Int
    var totalElements: Int
    var numberOfElements: Int
    var last: Bool
}
