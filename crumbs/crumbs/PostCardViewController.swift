//
//  PostCardViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import UIKit
import FirebaseFirestore

protocol TableManager {
    func updateTable() -> Void
}

class PostCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableManager {

    @IBOutlet weak var cardTable: UITableView!
    private final let ESTIMATED_ROW_HEIGHT = 1000
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"

    var discoverActive = true
    var posts: [Post] = []
    
    func updateTable() {
        cardTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardTable.delegate = self
        self.cardTable.dataSource = self
        self.cardTable.rowHeight = UITableView.automaticDimension
        self.cardTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
        self.populatePosts()
    }
    
    var userRef: DocumentReference!

    func populatePosts() {
        let db = Firestore.firestore()
        // on follow tab
        if !self.discoverActive {
            let ref = db.collection("users").document(CUR_USER.id!)
            self.userRef = db.document("users/\(ref)")
            ref.getDocument{ (document, error) in
                if let document = document, document.exists {
                    let followedPosts = document.get("followed_posts") as! [DocumentReference]
//                    let documentIDs = followedPosts.map {$0.documentID}
                    db.collection("posts").whereField(FieldPath.documentID(), in: followedPosts).getDocuments(){
                        (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            self.posts = querySnapshot!.documents.map {Post(snapshot: $0)}
                            self.cardTable.reloadData()
                            
                            if self.posts.count > 0 {
                                self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                            }
                        }
                    }
                } else {
                    print("Document does not exist in cache")
                }
            }
        }
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts = querySnapshot!.documents.map {Post(snapshot: $0)}
                self.cardTable.reloadData()
                
                if self.posts.count > 0 {
                    self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
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
            nextVC.tableManager = self
        }
    }

}
