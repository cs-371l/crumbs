//
//  PostCardViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/18/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

protocol TableManager {
    func updateTable() -> Void
    func refreshTable() -> Void
}

extension Double {
  func formatDistance(from originalUnit: UnitLength, to convertedUnit: UnitLength) -> String {
      return Measurement(value: self, unit: originalUnit).converted(to: convertedUnit).formatted(.measurement(width: .abbreviated, usage: .general))
  }
}

class PostCardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,TableManager {

    @IBOutlet weak var cardTable: UITableView!
    
    private final let ESTIMATED_ROW_HEIGHT = 1000
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"
    let deviceLocationService = DeviceLocationService.shared
    
    var query: Query!

    var discoverActive = true
    var posts: [Post] = []
    
    private var pullControl = UIRefreshControl()
    
    func updateTable() {
        self.populatePosts()
    }
    
    func refreshTable() {
        self.cardTable.reloadData()
    }
    
    func refreshView() {
        self.cardTable.reloadData()
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
        let database = Firestore.firestore()
        let location = deviceLocationService.getLocation()!
        let geohash = Geohash.encode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: .nineteenMeters)
        self.query = database.collection("posts").whereField("geohash", isEqualTo: geohash)
        self.populatePosts() {
            DispatchQueue.main.async {
                self.pullControl.endRefreshing()
            }
        }
    }
    
    var userRef: DocumentReference!

    func populatePosts(completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        if !self.discoverActive {
            let uid = Auth.auth().currentUser?.uid
            let ref = db.collection("users").document(uid!)
            self.userRef = db.document("users/\(ref)")
            ref.getDocument{ (document, error) in
                if let error = error {
                    print("there is an error")
                    return
                }
                if let document = document, document.exists {
                    let followedPosts = document.get("followed_posts") as! [DocumentReference]
                    self.posts = []
                    if followedPosts.count == 0 {
                        self.cardTable.reloadData()
                        if completion != nil {
                            completion!()
                        }
                        return
                    }
                    db.collection("posts").whereField(FieldPath.documentID(), in: followedPosts).getDocuments() {
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
                        if completion != nil {
                            completion!()
                        }
                    }
                } else {
                    print("Document does not exist in cache")
                }
            }
        } else {
            query.order(by: "timestamp", descending: true).getDocuments() { (querySnapshot, err) in
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == POST_VIEW_SEGUE, let rowIndex = cardTable.indexPathForSelectedRow?.row {
            let post = posts[rowIndex]
            let location = deviceLocationService.getLocation()!
            let postLocation = CLLocation(latitude: post.latitude, longitude: post.longitude)
            let distance = location.distance(from: postLocation)
            if distance > 19 {
                // 19 meter radius
                self.showErrorAlert(title: "Post Restricted", message: "Post only viewable when near.  \(distance.formatDistance(from: .meters, to: .miles)) away")
                return false
            }
            return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_VIEW_SEGUE, let nextVC = segue.destination as? PostViewController, let rowIndex = cardTable.indexPathForSelectedRow?.row  {
            nextVC.post = posts[rowIndex]
            nextVC.tableManager = self
        }
    }
}
