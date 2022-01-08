//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/04/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion:@escaping(LoadFeedResult) -> Void)
}
