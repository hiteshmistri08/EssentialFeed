//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Hitesh on 25/04/21.
//

import Foundation

public struct FeedItem:Equatable {
    let id:UUID
    let description:String?
    let location:String?
    let imageURL:URL
}
