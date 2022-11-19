//
//  FlowerData.swift
//  Plant-Recognizer
//
//  Created by Petar Iliev on 19.11.22.
//

import Foundation

struct FlowerData: Codable {
    let query: Query
}

struct Query: Codable {
    let pageids: [String]
    let pages: [String : Pages]
}

struct Pages: Codable {
    let extract: String
}
