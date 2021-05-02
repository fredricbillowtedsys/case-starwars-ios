//
//  ApiUtil.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import Foundation

class ApiUtil {
    static let PEOPLE_ENDPOINT = "https://swapi.dev/api/people/"
    static let PEOPLE_SEARCH_ENDPOINT = "\(PEOPLE_ENDPOINT)?search="

    static func fetch<T: Codable>(_ type: T.Type, url: URL, completion: @escaping ((T?) -> Void)) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                completion(decoded)
            } catch let ex {
                print(ex)
                completion(nil)
            }
        }.resume()
    }
}
