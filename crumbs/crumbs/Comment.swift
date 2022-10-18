//
//  Comment.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import Foundation

class Comment {
    var comment: String
    var upvotes: Int
    var author: String
    var date: Date
    var timeAgo: String {
        return date.timeAgoDisplay()
    }
    
    init(comment: String, upvotes: Int, author: String, date: Date) {
        self.comment = comment
        self.upvotes = upvotes
        self.author = author
        self.date = date
    }
}
