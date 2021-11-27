//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/11/21.
//

import Foundation

public final class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate:() -> Date
    
    public typealias SaveResult = Error?
    
    public init(store:FeedStore, currentDate:@escaping() -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items:[FeedItem], completion:@escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ item:[FeedItem], with completion: @escaping(Error?) -> Void) {
        store.insert(item.toLocal(), self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return self.map{ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    }
}
