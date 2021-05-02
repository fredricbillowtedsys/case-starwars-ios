//
//  PersonsResponse.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import Foundation

struct PersonsResponse: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Person]?
}
