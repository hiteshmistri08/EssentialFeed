//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 16/05/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL, completion:@escaping(Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url : URL
    private let client:HTTPClient
    
    public enum Error:Swift.Error {
        case connectivity
    }
    
    public init(url:URL,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion:@escaping(Error) -> Void = { _ in }) {
        ///Clients don't need to know about the specific URL. They just want to load a feed of items, so we hide the URL as an implementation detail.
        client.get(from: url) { (error) in
            completion(.connectivity)
        }
    }
}
