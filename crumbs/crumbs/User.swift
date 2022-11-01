//
//  User.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class User {
    var username: String
    var biography: String
    var dateJoined: Date
    var karma: Int
    var views: Int
    var posts: [Post]
    
    convenience init(firebaseUser: FirebaseAuth.User) {
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
            } else {
                self.username = snapshot!.get("username") as! String
                self.biography = snapshot!.get("bio") as! String
                let creationTimestamp = snapshot!.get("creation_timestamp") as! Timestamp
                self.dateJoined = creationTimestamp.dateValue()
                self.karma = snapshot!.get("karma") as! Int
                self.views = snapshot!.get("views") as! Int
            }
        }
    }

    init(username: String, biography: String, dateJoined: Date, karma: Int, views: Int) {
        
        self.username = username
        self.biography = biography
        self.dateJoined = dateJoined
        self.karma = karma
        self.views = views
        self.posts = []
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let userRef = db.collection("users").document(uid)
        db.collection("posts").whereField("user", isEqualTo: userRef).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts = self.parseDocumentsToPosts(documents: querySnapshot!.documents)
            }
        }
    }
    
    func parseDocumentsToPosts(documents: [QueryDocumentSnapshot]) -> [Post] {
        var posts:[Post] = []
        for document in documents {
            let timestamp = document.get("timestamp") as! Timestamp
            let post = Post(creator: self, description: document.get("content") as! String, title: document.get("title") as! String, date: timestamp.dateValue(), likeCount: document.get("likes") as! Int, viewCount: document.get("views") as! Int)
            posts.append(post)
        }
        return posts
    }
    
    func addPost(p: Post) {
        self.posts.append(p)
    }
}

