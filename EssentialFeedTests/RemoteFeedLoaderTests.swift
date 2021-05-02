//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 02/05/21.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedUrl:URL?
}

class RemoteFeedLoaderTest : XCTestCase {
    
    func test_init() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
    
}
