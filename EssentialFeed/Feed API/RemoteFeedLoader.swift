//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitesh on 16/05/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL)
}

public final class RemoteFeedLoader {
    private let url : URL
    private let client:HTTPClient
    
    public init(url:URL = URL(string: "https://a-url.com")!,client:HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load() {
        client.get(from: url)
    }
}
