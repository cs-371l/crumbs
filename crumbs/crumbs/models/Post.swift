//
//  Post.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import Foundation
import FirebaseFirestore
import UIKit

class Post {
    var creatorRef : DocumentReference
    var author : String
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
    var imageUrl: String?
    var uiImage: UIImage? = nil
    var latitude: Float64
    var longitude: Float64
    var geohash: String
    
    var user: User? = nil
    
    init(
        creatorRef: DocumentReference,
        creatorUsername: String,
        description: String,
        title: String,
        date: Date,
        likeCount: Int,
        viewCount: Int,
        latitude: Float64,
        longitude: Float64,
        geohash: String,
        comments: [Comment] = [],
        imageUrl: String? = nil
    ) {
        self.title = title
        self.creatorRef = creatorRef
        self.author = creatorUsername
        self.description = description
        self.date = date
        self.likeCount = likeCount
        self.viewCount = viewCount
        self.comments = comments
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.longitude = longitude
        self.geohash = geohash
        
        self.comments = self.comments.sorted {
            $0.date < $1.date
        }
    }
    
    convenience init(snapshot: QueryDocumentSnapshot) {
        let timestamp = snapshot.get("timestamp") as! Timestamp

        self.init(
            creatorRef: snapshot.get("user") as! DocumentReference,
            creatorUsername: snapshot.get("creator_username") as! String,
            description: snapshot.get("content") as! String,
            title: snapshot.get("title") as! String,
            date: timestamp.dateValue(),
            likeCount: snapshot.get("likes") as! Int,
            viewCount: snapshot.get("views") as! Int,
            latitude: snapshot.get("latitude") as! Float64,
            longitude: snapshot.get("longitude") as! Float64,
            geohash: snapshot.get("geohash") as! String,
            imageUrl: snapshot.get("image_url") as! String?
        )
        self.docRef = snapshot.reference
    }
    
    func serialize(userRef: DocumentReference, name: String) -> [String: Any] {
        // TODO: Include image URL in serialization
        // TODO: Link user properly
        var base = [
            "title": self.title,
            "content": self.description,
            "likes": self.likeCount,
            "views": self.viewCount,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "geohash": self.geohash,
            "comments": self.comments,
            "timestamp": Timestamp(date: self.date),
            "user": userRef,
            "creator_username": name
        ] as [String : Any]
        
        if self.imageUrl != nil {
            base["image_url"] = self.imageUrl!
        }
        
        return base
    }
    
    private func getDeltaForComment(
        comment: DocumentReference,
        upvotedRefs: [DocumentReference],
        downvotedRefs: [DocumentReference]
    ) -> Int {
        for upvotedRef in upvotedRefs {
            if upvotedRef.documentID == comment.documentID {
                return 1
            }
        }
        
        for downvotedRef in downvotedRefs {
            if downvotedRef.documentID == comment.documentID {
                return -1
            }
        }
        return 0
    }
    
    func getCommentDeltaDoc(user: DocumentReference) async throws -> DocumentReference {
        let db = Firestore.firestore()
        let query = db.collection("comment_upvotes").whereField("post", isEqualTo: self.docRef!).whereField("user", isEqualTo: user)
        
        let results = try await query.getDocuments()
        if !results.documents.isEmpty {
            return results.documents[0].reference
        }
        
        var base = [
            "post": self.docRef!,
            "user": user,
            "upvoted": [] as [DocumentReference],
            "downvoted": [] as [DocumentReference]
        ] as [String : Any]
        
        let ref = db.collection("comment_upvotes").document()
        try await ref.setData(base)
        
        return ref
        
        
    }
    
    // Returns state delta for each comment in order for posts -- for example
    // [1, 0, -1] => upvote for comment 1, no state for comment 2, downvote for comment 3.
    // Sorted order based on dates.
    func getCommentDeltaForUser(upvoteRelation: DocumentReference) async throws -> [Int] {
        var deltas: [Int] = []
        
        let doc = try await upvoteRelation.getDocument()
        let upvotedReferences: [DocumentReference] = doc.get("upvoted") as! [DocumentReference]
        let downvotedReferences: [DocumentReference] = doc.get("downvoted") as! [DocumentReference]
        
        let sortedComments = self.comments.sorted {
            $0.date < $1.date
        }
        for comment in sortedComments {
            deltas.append(
                getDeltaForComment(
                    comment: comment.docRef,
                    upvotedRefs: upvotedReferences,
                    downvotedRefs: downvotedReferences
                )
            )
        }
        return deltas
    }
    
}
