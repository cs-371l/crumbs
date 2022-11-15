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
import DZNEmptyDataSet

protocol TableManager {
    func updateTable() -> Void
    func refreshTable() -> Void
}

protocol PostPopulator {
    func populatePosts(completion: ((_ posts: [Post]) -> Void)?) -> Void
    func emptyPlaceholderString() -> String
}

extension Double {
  func formatDistance(from originalUnit: UnitLength, to convertedUnit: UnitLength) -> String {
      return Measurement(value: self, unit: originalUnit).converted(to: convertedUnit).formatted(.measurement(width: .abbreviated, usage: .general))
  }
}

class PostCardViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UINavigationControllerDelegate,
    DZNEmptyDataSetSource,
    DZNEmptyDataSetDelegate,
    TableManager {

    @IBOutlet weak var cardTable: UITableView!
    
    private final let ESTIMATED_ROW_HEIGHT = 1000
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"
    let deviceLocationService = DeviceLocationService.shared
    
    var delegate: PostPopulator!
    var query: Query!

    var posts: [Post] = []
    
    private var pullControl = UIRefreshControl()
    
    func updateTable() {
        self.delegate.populatePosts() { posts in
            self.posts = posts
            self.refreshTable()
        }
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
        self.delegate.populatePosts() { posts in
            self.posts = posts
            self.refreshTable()
        }
        self.navigationController?.delegate = self
        
        // For empty dataset.
        self.cardTable.emptyDataSetSource = self
        self.cardTable.emptyDataSetDelegate = self
        
        // Taken from: https://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.cardTable.refreshControl = pullControl
        } else {
            self.cardTable.addSubview(pullControl)
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Crumbs"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = self.delegate.emptyPlaceholderString()
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    @objc private func refreshListData(_ sender: Any) {
        self.delegate.populatePosts() { posts in
            self.posts = posts
            self.refreshTable()
            DispatchQueue.main.async {
                self.pullControl.endRefreshing()
            }
        }
    }
    
    var userRef: DocumentReference!
    
    
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
            if distance > 19 && post.author != CUR_USER.username {
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
