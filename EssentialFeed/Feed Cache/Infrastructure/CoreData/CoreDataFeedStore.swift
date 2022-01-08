//
//  CoreDataFeedStore.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 23/12/21.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundel: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundel)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map{ cache in
                    return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = currentDate
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    // - MARK: Helper
    private func perform(_ action:@escaping(NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
