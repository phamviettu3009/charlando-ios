//
//  CountryCode.swift
//  2lab
//
//  Created by Phạm Việt Tú on 16/06/2024.
//

import Foundation

struct Country: Identifiable, Hashable {
    let countryName: String
    let countryCode: String
    let flagSymbol: String
    var languageCode: String
    
    var id: String {
        return countryCode
    }
}
