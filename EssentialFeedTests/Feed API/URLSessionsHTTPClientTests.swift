//
//  URLSessionsHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 17/07/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient : HTTPClient {
    private let session: URLSession
    
    init(session:URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (data,response,error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}


class URLSessionsHTTPClientTests : XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStubs.startInterceptingRequests()
    }
    
    override func tearDown() {
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
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.code, requestError.code)
        XCTAssertEqual(receivedError?.domain, requestError.domain)
//        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
    
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
    
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file:StaticString = #file, line:UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data(bytes: "any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultValuesFor(data:Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> (data:Data, response:HTTPURLResponse)? {
        let result = resultValues(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure with error, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data:Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultValues(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error as NSError):
            return error
        default:
            XCTFail("Expected failure with error, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValues(data:Data?, response: URLResponse?, error:Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStubs.stub(data: data, response: response, error: error)
        let sut = makeSUT(file:file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult:HTTPClientResult!
        sut.get(from: anyURL()) { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    private class URLProtocolStubs : URLProtocol {
        
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest) -> Void)?
        
        private struct Stub {
            let data:Data?
            let response:URLResponse?
            let error: Error?
        }
        
        static func stub(data:Data?, response:URLResponse?, error:Error? = nil) {
            stub = Stub(data:data, response: response, error: error)
        }
        
        static func observeRequests(observer : @escaping(URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStubs.self)
        }
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStubs.self)
            stub = nil
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
            if let data = URLProtocolStubs.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStubs.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStubs.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
