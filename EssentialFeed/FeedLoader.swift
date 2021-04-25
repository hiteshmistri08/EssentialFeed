//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/04/21.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case failed(Error)
}

protocol FeedLoader {
    func load(completion:@escaping(LoadFeedResult) -> Void)
}
