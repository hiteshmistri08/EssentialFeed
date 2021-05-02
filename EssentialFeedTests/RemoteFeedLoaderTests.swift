//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 02/05/21.
//

import XCTest

class RemoteFeedLoader {
    
    func load() {
        HTTPClient.shared.requestedUrl = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    var requestedUrl:URL?
    
    private init() {}
}

class RemoteFeedLoaderTest : XCTestCase {
    
    func test_init() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
}
