//
//  User.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

// Global User
var CUR_USER: User!

class User {
    var id: String?
    var docRef: DocumentReference
    var username: String
    var biography: String
    var dateJoined: Date
    var karma: Int
    var views: Int
    var posts: [Post]? = nil
    var likedPostIds: [DocumentReference]
    var followedPostIds: [DocumentReference]
    var viewedPostIds: [DocumentReference]
    var viewedProfileIds: [DocumentReference]
    var imageUrl: String?
    var uiImage: UIImage? = nil

    init(snapshot: DocumentSnapshot) {
        self.docRef = snapshot.reference
        self.username = snapshot.get("username") as! String
        self.biography = snapshot.get("bio") as! String
        let creationTimestamp = snapshot.get("creation_timestamp") as! Timestamp
        self.dateJoined = creationTimestamp.dateValue()
        self.karma = snapshot.get("karma") as! Int
        self.views = snapshot.get("views") as! Int
        self.likedPostIds = snapshot.get("liked_posts") as! [DocumentReference]
        self.followedPostIds =
        snapshot.get("followed_posts") as! [DocumentReference]
        self.viewedPostIds = snapshot.get("viewed_posts") as! [DocumentReference]
        self.viewedProfileIds = snapshot.get("viewed_profiles") as! [DocumentReference]
        self.imageUrl = snapshot.get("image_url") as! String?
    }
    
    func getPosts(callback: @escaping (_ success: Bool, _ data: [Post]?) -> Void) {
        if self.posts != nil {
            callback(true, self.posts)
            return
        }

        let db = Firestore.firestore()
        db.collection("posts").whereField("user", isEqualTo: self.docRef).getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                callback(false, nil)
            } else {
                self.posts = querySnapshot!.documents.map { Post(snapshot: $0) }
                callback(true, self.posts)
            }
        }
    }
    
    // Lightweight initialization for new users -- stores in database.
    init(uid: String, username: String, birthday: Date, callback: @escaping (_ success: Bool) -> Void) {
        self.id = uid
        self.username = username
        self.dateJoined = birthday
        self.biography = ""
        self.karma = 0
        self.views = 0
        self.posts = []
        self.likedPostIds = []
        self.followedPostIds = []
        self.viewedPostIds = []
        self.viewedProfileIds = []
        self.imageUrl = ""
        
        // Persist to Firestore.
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        self.docRef = ref
        ref.setData([
            "username": self.username,
            "birthday": Timestamp(date: self.dateJoined),
            "creation_timestamp": FieldValue.serverTimestamp(),
            "bio": self.biography,
            "karma": self.karma,
            "views": self.views,
            "liked_posts": self.likedPostIds,
            "followed_posts": self.followedPostIds,
            "viewed_posts": self.viewedPostIds,
            "viewed_profiles": self.viewedProfileIds,
            "image_url": self.imageUrl!
        ]) {
            err in
            if let err = err {
                print("Error adding document: \(err)")
                callback(false)
            } else {
                print("Document added with username: \(self.username)")
                callback(true)
            }
        }
    }
    
    func addPost(p: Post) {
        guard self.posts != nil else { return }
        self.posts!.append(p)
    }
    
    func hasLikedPost(p: Post) -> Bool {
        return self.likedPostIds.contains(where: {$0.documentID == p.docRef?.documentID})
    }
    
    func addLikedPost(p: Post) -> Void {
        self.likedPostIds.append(p.docRef!)
    }
    
    func addViewedPosts(p: Post) -> Void {
        self.viewedPostIds.append(p.docRef!)
    }
    
    func hasViewedPost(p: Post) -> Bool {
        return self.viewedPostIds.contains(where: {$0.documentID == p.docRef?.documentID})
    }
    
    func removedLikedPost(p: Post) {
        self.likedPostIds = self.likedPostIds.filter {$0.documentID != p.docRef?.documentID}
    }
    
    func hasFollowedPost(p: Post) -> Bool {
        return self.followedPostIds.contains(where: {$0.documentID == p.docRef?.documentID})
    }
    
    func addFollwedPost(p: Post) -> Void {
        self.followedPostIds.append(p.docRef!)
    }
    
    func removedFollwedPost(p: Post) {
        self.followedPostIds = self.followedPostIds.filter {$0.documentID != p.docRef?.documentID}
    }
    
    func addViewedProfile(u: User) -> Void{
        self.viewedProfileIds.append(u.docRef)
    }
    
    func hasViewedProfile(u: User) -> Bool {
        return self.viewedProfileIds.contains(where: {$0.documentID == u.docRef.documentID})
    }
}

