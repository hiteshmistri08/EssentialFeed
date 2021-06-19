//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 16/05/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url:URL, completion:@escaping(HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url : URL
    private let client:HTTPClient
    
    public enum Error:Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion:@escaping(Result) -> Void) {
        ///Clients don't need to know about the specific URL. They just want to load a feed of items, so we hide the URL as an implementation detail.
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
