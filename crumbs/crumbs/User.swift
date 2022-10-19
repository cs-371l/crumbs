//
//  User.swift
//  crumbs
//
//  Created by Amog Iska on 10/18/22.
//

import Foundation

class User {
    var username : String
    var firstName : String
    var lastName : String
    var biography : String
    var age : Int
    var karma : Int
    var postsCreated : Int {
        return posts.count
    }
    var views : Int
    var posts: [Post]

    init(username:String, firstName:String, lastName:String, biography:String, age:Int, karma : Int, views : Int) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.biography = biography
        self.age = age
        self.karma = karma
        self.views = views
        self.posts = []
    }
    
    convenience init(username:String, firstName:String, lastName:String, biography:String, age:Int, karma : Int, views : Int, posts: Int) {
        self.init(username: username, firstName: firstName, lastName: lastName, biography: biography, age: age, karma: karma, views: views)
        
        let posts = generatePostData(users: [self])
        
        for p in posts {
            self.addPost(p: p)
        }
    }
    
    func addPost(p: Post) {
        self.posts.append(p)
    }
}

