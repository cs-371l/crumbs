//
//  Comment.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import Foundation
import FirebaseFirestore

class Comment {
    var userRef : DocumentReference
    var docRef: DocumentReference
    var comment: String
    var upvotes: Int
    var username: String
    var date: Date
    var timeAgo: String {
        return date.timeAgoDisplay()
    }
    
    init(
        comment: String,
        upvotes: Int,
        username: String,
        userRef: DocumentReference,
        date: Date,
        docRef: DocumentReference
    ) {
        self.comment = comment
        self.upvotes = upvotes
        self.username = username
        self.userRef = userRef
        self.date = date
        self.docRef = docRef
    }
    
    convenience init(snapshot: QueryDocumentSnapshot) {
        let timestamp = snapshot.get("timestamp") as! Timestamp
        
        self.init(
            comment: snapshot.get("content") as! String,
            upvotes: snapshot.get("upvotes") as! Int,
            username: snapshot.get("username") as! String,
            userRef: snapshot.get("user") as! DocumentReference,
            date: timestamp.dateValue(), docRef: snapshot.reference
        )
    }
    
    func serialize() -> [String: Any] {
        return [
            "content": self.comment,
            "timestamp": Timestamp(date: self.date),
            "upvotes": self.upvotes,
            "user": self.userRef,
            "username": self.username,
        ] as [String : Any]
    }
}
