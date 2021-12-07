//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Hitesh on 07/12/21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
