//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/11/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion:@escaping DeletionCompletion)
    func insert(_ feed:[LocalFeedImage], _ currentDate:Date, completion:@escaping InsertionCompletion)
}
