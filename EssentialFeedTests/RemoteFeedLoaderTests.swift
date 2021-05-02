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

class RemoteFeedLoaderTest : XCTestCase {
    
    func test_init() {
        let (_ ,client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url:url)
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "http://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrl:URL?
        
        func get(from url:URL) {
            requestedUrl = url
        }
    }
}
