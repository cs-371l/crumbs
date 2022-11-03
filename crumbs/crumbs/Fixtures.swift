//
//  Fixtures.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import Foundation

let AUTHOR = "@author"
let SMALL_TEXT = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
"""
let MED_TEXT_1 = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullamcondimentum in mi nec pharetra. Cras pretium, libero vel sodales consectetur, ipsum magna ultricies nibh, et euismod sapien mi sit amet ex. Aenean risus ante
"""
let MED_TEXT_2 = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullamcondimentum in mi nec pharetra. Cras pretium, libero vel sodales consectetur, ipsum magna ultricies nibh, et euismod sapien mi sit amet ex. Aenean risus ante, fermentum non vestibulum et, porta nec mauris. Nullam tempus tellus eget tortor tristique viverra. Integer imperdiet pulvinar urna accumsan rutrum. In nec vulputate velit. In consequat lectus dui, in molestie lorem iaculis ac. Vestibulum tempor nibh at purus pharetra, sed vehicula justo egestas. Etiam eget leo vitae justo euismod luctus.
"""

let LARGE_TEXT = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean cursus tortor quis ligula ornare condimentum. Nullam ut aliquet lorem, non tempor sapien. Vestibulum at ipsum pretium, facilisis leo ut, efficitur odio. Morbi convallis aliquam eleifend. Suspendisse porta, mauris id maximus sodales, arcu metus feugiat neque, et bibendum eros urna in leo. Donec non ligula non magna luctus sagittis. Duis gravida ante a erat consequat efficitur. Integer egestas tempus nisl feugiat vehicula. Nullam sed velit et justo malesuada faucibus in eget diam. Morbi aliquam lacinia nulla efficitur aliquet. Ut maximus eleifend semper. Nam non nisi quam.Mauris non elementum nisi. Donec vestibulum pellentesque risus at luctus. Ut vel erat eu augue venenatis tincidunt id at metus. Curabitur eu ipsum facilisis, fermentum velit sed, condimentum magna. Morbi id purus et libero ornare ultrices. Cras in tincidunt nulla, id mollis risus. Nunc sit amet risus vitae sem posuere iaculis. Aenean diam dui, dictum nec consectetur non, tincidunt eget ante. Nunc faucibus iaculis neque. In quis pharetra orci, non fringilla eros. Donec eget lacus tincidunt, vulputate justo vel, semper ante. Donec eleifend ac mi in commodo. Nulla nec enim sit amet massa molestie lobortis semper nec diam. Integer at ipsum nec arcu convallis laoreet ac ut lectus.Nam id nibh volutpat, condimentum leo sed, laoreet velit. Duis iaculis dignissim ante quis consequat. Pellentesque sed mauris non velit semper rutrum. Mauris eget mi id nunc fermentum mattis. Etiam condimentum elit eu eleifend scelerisque. Nullam auctor malesuada tellus vitae ultricies. Nunc sit amet dui placerat, feugiat lorem et, fringilla risus. Pellentesque sem dolor, elementum quis tristique ac, tempor vel elit. Nulla id elementum nibh.
"""

let TEXT_FIXTURES = [SMALL_TEXT, MED_TEXT_1, MED_TEXT_2, LARGE_TEXT]
let TITLE_FIXTURES = [SMALL_TEXT, MED_TEXT_1]

let COUNT_BOUND = 100
let COMMENT_BOUND = 50
let POST_BOUND = 50

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

func generateUsersWithPosts(userBound: Int = COUNT_BOUND, postsBound: Int = COUNT_BOUND, countBound: Int = COUNT_BOUND) -> [User]{
    let users = generateUsers(userBound: 1)
    
   return users
}

func generateUsers(userBound: Int = COUNT_BOUND, bound: Int = COUNT_BOUND) -> [User] {
    let numUsers = Int.random(in: 1...userBound)
    var ret: [User] = []
    
    for _ in 1...numUsers {
        let username = randomString(length: 5)
        let biography = TEXT_FIXTURES.randomElement()!
        let karma = Int.random(in: 1...bound)
        let views = Int.random(in: 1...bound)
        ret.append(User(username: username, biography: biography, dateJoined: Date(), karma: karma, views: views))
    }
    return ret
}

/**
 Generates fixtures for `Posts`, returns anywhere between 1 and `bound` posts.
 */
func generatePostData(bound: Int = POST_BOUND, commentBound: Int = COMMENT_BOUND, countBound: Int = COUNT_BOUND, users: [User] = generateUsers()) -> [Post] {
    let numPosts = Int.random(in: 1...bound)
    var ret: [Post] = []
    
    for _ in 1...numPosts {
        let description = TEXT_FIXTURES.randomElement()!
        let title = TITLE_FIXTURES.randomElement()!
        let likes = Int.random(in: 1...countBound)
        let views = Int.random(in: 1...countBound)
        let comments = generateCommentData(bound: commentBound, countBound: countBound, users: users)
        let user = users.randomElement()!
        let newPost = Post(creator: user, description: description, title: title, date: Date(), likeCount: likes, viewCount: views, comments: comments)
        ret.append(newPost)
        user.addPost(p: newPost)
    }
    return ret
}
/**
 Generates fixtures for comments. returns anywhere between 1 and `bound` comments.
 */
func generateCommentData(bound: Int = COMMENT_BOUND, countBound: Int = COUNT_BOUND, users: [User]) -> [Comment] {
    let numComments = Int.random(in: 1...bound)
    var ret: [Comment] = []
    for _ in 1...numComments {
        let comment = TEXT_FIXTURES.randomElement()!
        let upvotes = Int.random(in: 1...countBound)
        let date = Date()
        let user = users.randomElement()!
        ret.append(Comment(comment: comment, upvotes: upvotes, creator: user, date: date))
    }
    return ret
}

