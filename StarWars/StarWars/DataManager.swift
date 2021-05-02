//
//  DataManager.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    var persons: [Person] = []
    var paginationMeta: PaginationMeta = PaginationMeta(count: -1, next: URL(string: ApiUtil.PEOPLE_ENDPOINT), previous: nil)
    var favourites: [FavouritePerson] = []
    
    private init () {
        
    }
}

