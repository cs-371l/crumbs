//
//  Comment.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import Foundation

class Comment {
    var creator : User
    var comment: String
    var upvotes: Int
    var author: String {
        return creator.username
    }
    var date: Date
    var timeAgo: String {
        return date.timeAgoDisplay()
    }
    
    init(comment: String, upvotes: Int, creator: User, date: Date) {
        self.comment = comment
        self.upvotes = upvotes
        self.creator = creator
        self.date = date
    }
}
