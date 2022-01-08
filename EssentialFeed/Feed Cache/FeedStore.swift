//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/11/21.
//

import Foundation

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    typealias RetrievalResult = Result<CachedFeed,Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion:@escaping DeletionCompletion)

    /// The completion handler can be invoked in any
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed:[LocalFeedImage], _ currentDate:Date, completion:@escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion:@escaping RetrievalCompletion)
}
