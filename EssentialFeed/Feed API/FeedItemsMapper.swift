//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Hitesh on 04/07/21.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root:Decodable {
        let items : [RemoteFeedItem]
    }
    
    private static var OK_200:Int { return 200 }
    
    private init() { }
    
    internal static func map(_ data:Data, from response:HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
