//
//  User.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    var posts: [Post]
    var likedPostIds: [DocumentReference]
    var followedPostIds: [DocumentReference]
    
    // Initialize based off of Firebase user. SETS THE CURRENT USER -- ONLY CALL FOR AUTHENTICATED USER.
    convenience init(firebaseUser: FirebaseAuth.User, callback: @escaping (_ success: Bool) -> Void) {
        let db = Firestore.firestore()
        let username = ""
        let biography = ""
        let dateJoined = Date()
        let karma = 0
        let views = 0
        

        self.init(username: username, biography: biography, dateJoined: dateJoined, karma: karma, views: views)
        db.collection("users").document(firebaseUser.uid).getDocument() { (snapshot, err) in
            if let err = err {
                print("Error getting user \(err)")

                callback(false)
            } else {
                self.assignFromSnapshot(snapshot: snapshot!)
                CUR_USER = self
                callback(true)
            }
        }
    }
    
    func assignFromSnapshot(snapshot: DocumentSnapshot) {
        self.username = snapshot.get("username") as! String
        self.biography = snapshot.get("bio") as! String
        let creationTimestamp = snapshot.get("creation_timestamp") as! Timestamp
        self.dateJoined = creationTimestamp.dateValue()
        self.karma = snapshot.get("karma") as! Int
        self.views = snapshot.get("views") as! Int
        self.likedPostIds = snapshot.get("liked_posts") as! [DocumentReference]
        self.followedPostIds =
        snapshot.get("followed_posts") as! [DocumentReference]
    }
    
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
        self.posts = []
    }
    
    // Full in-memory initializiation (eagerly loaded).
    // Note that this brings in all posts into memory.
    init(username: String, biography: String, dateJoined: Date, karma: Int, views: Int) {
        self.username = username
        self.biography = biography
        self.dateJoined = dateJoined
        self.karma = karma
        self.views = views
        self.posts = []
        self.likedPostIds = []
        self.followedPostIds = []
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        self.id = uid
        let userRef = db.collection("users").document(uid)
        self.docRef = userRef
        db.collection("posts").whereField("user", isEqualTo: userRef).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts = self.parseDocumentsToPosts(documents: querySnapshot!.documents)
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
            "followed_posts": self.followedPostIds
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
    
    func parseDocumentsToPosts(documents: [QueryDocumentSnapshot]) -> [Post] {
        var posts:[Post] = []
        for document in documents {
            let timestamp = document.get("timestamp") as! Timestamp
            let post = Post(
                creatorRef: self.docRef,
                creatorUsername: self.username,
                description: document.get("content") as! String,
                title: document.get("title") as! String,
                date: timestamp.dateValue(),
                likeCount: document.get("likes") as! Int,
                viewCount: document.get("views") as! Int
            )
            posts.append(post)
        }
        return posts
    }
    
    func addPost(p: Post) {
        self.posts.append(p)
    }
    
    func hasLikedPost(p: Post) -> Bool {
        return self.likedPostIds.contains(where: {$0.documentID == p.docRef?.documentID})
    }
    
    func addLikedPost(p: Post) -> Void {
        self.likedPostIds.append(p.docRef!)
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
}

