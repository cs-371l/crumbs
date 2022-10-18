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
    var postsCreated : Int
    var views : Int

    init(username:String, firstName:String, lastName:String, biography:String, age:Int, karma : Int, postsCreated : Int, views : Int) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.biography = biography
        self.age = age
        self.karma = karma
        self.postsCreated = postsCreated
        self.views = views
    }
    
}

