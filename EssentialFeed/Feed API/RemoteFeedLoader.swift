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
        ///Clients don't need to know about the specific URL. They just want to load a feed of items, so we hide the URL as an implementation detail.
        client.get(from: url)
    }
}
