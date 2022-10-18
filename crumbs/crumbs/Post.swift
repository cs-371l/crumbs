//
//  Post.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import Foundation


class Post {
    var author : String
    var description: String
    var title: String
    var active: String
    var likeCount: Int
    var commentCount: Int
    var viewCount: Int
    
    init(author: String, description: String, title: String, active: String, likeCount: Int, commentCount: Int, viewCount: Int) {
        self.title = title
        self.author = author
        self.description = description
        self.active = active
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.viewCount = viewCount
    }
    
}
