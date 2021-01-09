//
//  Models.swift
//  MoviePlaylist
//
//  Created by Shreyas Thiagaraj on 1/8/21.
//  Copyright © 2021 Shreyas. All rights reserved.
//

import Foundation

struct Movie: Hashable, Codable {
    var Title: String
    var Year: String
    var imdbID: String
    var `Type`: String
    var Poster: String
}

struct SearchResults: Hashable, Codable {
    var Search: [Movie]
    var totalResults: String
    var Response: String
}
