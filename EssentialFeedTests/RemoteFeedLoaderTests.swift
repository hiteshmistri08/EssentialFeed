//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 02/05/21.
//

import XCTest

class RemoteFeedLoader {
    let client:HTTPClient
    
    init(client:HTTPClient) {
        self.client = client
    }
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url:URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedUrl:URL?
    
    func get(from url:URL) {
        requestedUrl = url
    }
}

class RemoteFeedLoaderTest : XCTestCase {
    
    func test_init() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client:client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client:client)
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
}
