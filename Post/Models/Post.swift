//
//  Post.swift
//  Post
//
//  Created by David Sadler on 4/29/19.
//  Copyright © 2019 David Sadler. All rights reserved.
//


// Remember: JSONEncoder uses the names of each property as the key in the associated array -- so spelling of the properties as well as their capitalization must be the same -- note no camel case as with Post properties.
import Foundation

struct Post: Codable {
    
    // MARK: - Internal Properties
    
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
    
    // MARK: - Initialier
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
