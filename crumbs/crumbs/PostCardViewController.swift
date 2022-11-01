//
//  PostCardViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import UIKit
import FirebaseFirestore

class PostCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cardTable: UITableView!
    private final let ESTIMATED_ROW_HEIGHT = 1000
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"
    var discoverActive = true
    var posts: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardTable.delegate = self
        self.cardTable.dataSource = self
        self.cardTable.rowHeight = UITableView.automaticDimension
        self.cardTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
        self.populatePosts()
    }
    
    func parseDocumentsToPosts(documents: [QueryDocumentSnapshot]) -> [Post] {
        var posts:[Post] = []
        for document in documents {
            let user = User(username: "username", firstName: "firstName", lastName: "lastName", biography: "biography", age: 19, karma: 10, views: 30)
            let timestamp = document.get("timestamp") as! Timestamp
            let post = Post(creator: user, description: document.get("content") as! String, title: document.get("title") as! String, date: timestamp.dateValue(), likeCount: document.get("likes") as! Int, viewCount: document.get("views") as! Int)
            posts.append(post)
        }
        return posts
    }
    
    func populatePosts() {
        let db = Firestore.firestore()
        if !self.discoverActive {
            self.posts = generatePostData()
            self.cardTable.reloadData()
            self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            return
        }
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts = self.parseDocumentsToPosts(documents: querySnapshot!.documents)
                self.cardTable.reloadData()
                self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CARD_IDENTIFIER, for: indexPath) as! PostTableViewCell
        let row = indexPath.row
        let p = posts[row]
        cell.assignAttributes(p: p)
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_VIEW_SEGUE, let nextVC = segue.destination as? PostViewController, let rowIndex = cardTable.indexPathForSelectedRow?.row  {
            nextVC.post = posts[rowIndex]
        }
    }

}
