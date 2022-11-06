//
//  Post.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import Foundation
import FirebaseFirestore

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
    var docRef: DocumentReference?
    
    init(creator: User, description: String, title: String, date: Date, likeCount: Int, viewCount: Int, comments: [Comment] = []) {
        self.title = title
        self.creator = creator
        self.description = description
        self.date = date
        self.likeCount = likeCount
        self.viewCount = viewCount
        self.comments = comments
    }
    
    convenience init(snapshot: QueryDocumentSnapshot) {
        let timestamp = snapshot.get("timestamp") as! Timestamp
        let user = User(
            username: "username",
            biography: "biography",
            dateJoined: timestamp.dateValue(),
            karma: 10,
            views: 30
        )
        self.init(
            creator: user,
            description: snapshot.get("content") as! String,
            title: snapshot.get("title") as! String,
            date: timestamp.dateValue(),
            likeCount: snapshot.get("likes") as! Int,
            viewCount: snapshot.get("views") as! Int
        )
        self.docRef = snapshot.reference
    }
    
    func serialize(userRef: DocumentReference) -> [String: Any] {
        // TODO: Include image URL in serialization
        // TODO: Link user properly
        return [
            "title": self.title,
            "content": self.description,
            "likes": self.likeCount,
            "views": self.viewCount,
            "comments": self.comments,
            "image": "",
            "timestamp": Timestamp(date: self.date),
            "user": userRef
        ]
    }
    
}
