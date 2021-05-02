//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 02/05/21.
//

import XCTest

class RemoteFeedLoader {
    let client:HTTPClient
    let url : URL
    
    init(url:URL = URL(string: "https://a-url.com")!,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    func load() {
        client.get(from: url)
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
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url:url,client:client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url:url, client:client)
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
    
}
