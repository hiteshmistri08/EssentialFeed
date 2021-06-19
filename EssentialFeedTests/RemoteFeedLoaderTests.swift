//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 02/05/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest : XCTestCase {
    
    func test_init() {
        let (_ ,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url:url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url:url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let sample = [199, 201, 300, 400, 500]
        
        sample.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200, data:invalidJSON)
        })
    }
    
//    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
//        let (sut, client) = makeSUT()
//
//        var capturedError
//
//    }
    
    // MARK: - Helpers
    
    private func makeSUT(url:URL = URL(string: "http://a-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client:client)
        return (sut, client)
    }
    
    private func expect(_ sut:RemoteFeedLoader, toCompleteWithError error:RemoteFeedLoader.Error, when action:() -> Void, file:StaticString = #filePath, line:Int = #line) {
        var capturedErrors = [RemoteFeedLoader.Result]()
        sut.load{ capturedErrors.append($0) }
        
        action()
        
        
        XCTAssertEqual(capturedErrors, [.failure(error)], file:file, line:UInt(line))
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url:URL, completion:(HTTPClientResult) -> Void)]()
        var requestedURLs : [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url:URL, completion:@escaping(HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        func complete(with error:Error, at index:Int = 0) {
            messages[index].completion(.failure(error))
            
        }
        func complete(withStatusCode code:Int, data:Data = Data(), at index:Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil
            )!
            messages[index].completion(.success(data,response))
        }
    }
}
