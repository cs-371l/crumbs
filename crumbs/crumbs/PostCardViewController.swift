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

class PostCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,TableManager {

    @IBOutlet weak var cardTable: UITableView!
    private final let ESTIMATED_ROW_HEIGHT = 1000
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"
    
    var query: Query!

    var discoverActive = true
    var posts: [Post] = []
    
    private var pullControl = UIRefreshControl()
    
    func updateTable() {
        cardTable.reloadData()
    }
    
    func refreshView() {
        self.cardTable.reloadData()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.populatePosts()
        refreshView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardTable.delegate = self
        self.cardTable.dataSource = self
        self.cardTable.rowHeight = UITableView.automaticDimension
        self.cardTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
        self.populatePosts()
        self.navigationController?.delegate = self
        
        // Taken from: https://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.cardTable.refreshControl = pullControl
        } else {
            self.cardTable.addSubview(pullControl)
        }
    }
    @objc private func refreshListData(_ sender: Any) {
        self.populatePosts() {
            DispatchQueue.main.async {
                self.pullControl.endRefreshing()
            }
        }
    }
    
    func populatePosts(completion: (() -> Void)? = nil) {
        if !self.discoverActive {
            self.posts = []
            self.cardTable.reloadData()
            
            if self.posts.count > 0 {
                self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
            return
        }
        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts = querySnapshot!.documents.map {Post(snapshot: $0)}
                self.cardTable.reloadData()
                
                if self.posts.count > 0 {
                    self.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
            }
            if completion != nil {
                completion!()
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
