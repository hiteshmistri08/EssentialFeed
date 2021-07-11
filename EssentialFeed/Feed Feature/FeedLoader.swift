//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/04/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion:@escaping(LoadFeedResult) -> Void)
}
