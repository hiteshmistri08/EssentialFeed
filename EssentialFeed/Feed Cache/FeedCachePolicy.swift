//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Hitesh on 11/12/21.
//

import Foundation

internal final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar.init(identifier: .gregorian)
    
    private static var maxAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp:Date, against date:Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
