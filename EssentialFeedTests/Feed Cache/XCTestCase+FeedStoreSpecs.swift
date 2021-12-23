//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 23/12/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp:Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var inserationError:Error?
        sut.insert(cache.feed, cache.timestamp) { receivedInsertionError in
            inserationError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return inserationError
    }

    @discardableResult
    func deleteCache(from sut:FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError:Error?
        sut.deleteCachedFeed { (receivedDeletionError) in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line:UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file:StaticString = #file, line:UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
                
            case let (.found(feed: expectedFeed, timestamp: expectedTimeStamp), .found(feed: retrievedFeed, timestamp: retrievedTimeStamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimeStamp, expectedTimeStamp, file: file, line: line)
        
            default:
                XCTFail("Expecetd to retrieve \(expectedResult), got \(retrievedResult) insted", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
