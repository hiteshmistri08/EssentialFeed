//
//  URLSessionsHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 17/07/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session:URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _,_,error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionsHTTPClientTests : XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStubs.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStubs.stopInterceptingRequests()
    }
    
    func test_getFromURL_perfoemGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStubs.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in}
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = anyURL()
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStubs.stub(data: nil, response: nil, error: error)
                
        let exp = expectation(description: "Wait for completion")
        
        makeSUT().get(from:url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                debugPrint("received Error : ",receivedError)
                debugPrint("Error : ",error)
                if #available(iOS 14.0, *) {
                    XCTAssertEqual(receivedError.code, error.code)
                    XCTAssertEqual(receivedError.domain, error.domain)
                } else {
                    XCTAssertEqual(receivedError, error)
                }
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file:StaticString = #file, line:UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class URLProtocolStubs : URLProtocol {
        
        private static var stubs : Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        
        private struct Stub {
            let data:Data?
            let response:URLResponse?
            let error: Error?
        }
        
        static func stub(data:Data?, response:URLResponse?, error:Error? = nil) {
            stubs = Stub(data:data, response: response, error: error)
        }
        
        static func observeRequests(observer : @escaping(URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStubs.self)
        }
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStubs.self)
            stubs = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStubs.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStubs.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStubs.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
