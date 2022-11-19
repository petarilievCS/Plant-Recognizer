//
//  ImageData.swift
//  Plant-Recognizer
//
//  Created by Petar Iliev on 19.11.22.
//

import Foundation

struct ImageData: Codable {
    let query: QueryImage
}

struct QueryImage: Codable {
    let pageids: [String]
    let pages: [String : PagesImage]
}

struct PagesImage: Codable {
    let thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    let source: String
}
