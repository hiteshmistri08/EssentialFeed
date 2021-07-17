//
//  URLSessionsHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 17/07/21.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session:URLSession) {
        self.session = session
    }
    
    func get(from:URL) {
        session.dataTask(with: from) { _,_,_ in }
    }
}


class URLSessionsHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from:url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }

    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask {
        
    }
}
