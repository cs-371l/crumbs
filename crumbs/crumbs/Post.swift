//
//  Post.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import Foundation

class Post {
    var creator : User
    var author : String {
        return creator.username
    }
    var description: String
    var title: String
    var date: Date
    var likeCount: Int
    var commentCount: Int {
        return comments.count
    }
    var viewCount: Int
    var comments: [Comment]
    var createdAgo: String {
        return date.timeAgoDisplay()
    }
    
    init(creator: User, description: String, title: String, date: Date, likeCount: Int, viewCount: Int, comments: [Comment] = []) {
        self.title = title
        self.creator = creator
        self.description = description
        self.date = date
        self.likeCount = likeCount
        self.viewCount = viewCount
        self.comments = comments
    }
    
}
