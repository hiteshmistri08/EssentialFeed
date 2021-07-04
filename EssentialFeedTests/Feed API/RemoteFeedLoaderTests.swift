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
        
        expect(sut, toCompleteWith:.failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let sample = [199, 201, 300, 400, 500]
        
        sample.enumerated().forEach { (index,code) in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200, data:invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJOSN = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyJOSN)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model,item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
        
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var captureResults = [RemoteFeedLoader.Result]()
        sut?.load{ captureResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    // MARK: - Helpers

    private func makeSUT(url:URL = URL(string: "http://a-url.com")!, file:StaticString = #file, line:UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    private func trackForMemoryLeaks(_ instance:AnyObject, file:StaticString = #file, line:UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memeory leak.", file: file, line: line)
        }
    }
    private func makeItem(id:UUID, description:String? = nil, location:String? = nil, imageURL:URL) -> (model:FeedItem,json:[String:Any]) {
        let model = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let itemJSON = [
            "id":model.id.uuidString,
            "description":model.description,
            "location":model.location,
            "image":model.imageURL.absoluteString
        ].reduce(into: [String:Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        return (model, itemJSON)
    }
    private func makeItemJSON(_ items:[[String:Any]]) -> Data {
        let json = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    private func expect(_ sut:RemoteFeedLoader, toCompleteWith result:RemoteFeedLoader.Result, when action:() -> Void, file:StaticString = #filePath, line:Int = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load{ capturedResults.append($0) }
        
        action()
        
        
        XCTAssertEqual(capturedResults, [result], file:file, line:UInt(line))
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
        func complete(withStatusCode code:Int, data:Data, at index:Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil
            )!
            messages[index].completion(.success(data,response))
        }
    }
}
