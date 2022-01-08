//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/11/21.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionError = Result<Void,Error>
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Result<Void,Error>
    typealias InsertionCompletion = (InsertionError) -> Void

    typealias RetrievalResult = Result<CachedFeed?,Error>
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
