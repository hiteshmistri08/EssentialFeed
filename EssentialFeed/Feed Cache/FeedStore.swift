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
    func insert(_ items:[LocalFeedItem], _ currentDate:Date, completion:@escaping InsertionCompletion)
}

public struct LocalFeedItem:Equatable {
    public let id:UUID
    public let description:String?
    public let location:String?
    public let imageURL:URL
    
    public init(id:UUID, description:String?, location:String?, imageURL:URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
