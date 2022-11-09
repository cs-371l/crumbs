//
//  FeedViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/14/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class PostTableViewCell : UITableViewCell {
    
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!

    @IBOutlet weak var activeIcon: UIImageView!
    @IBOutlet weak var activeLabel: UILabel!
    
    func assignAttributes(p: Post) {
        authorLabel.text = p.author
        titleLabel.text = p.title
        descriptionLabel.text = p.description
        
        likesLabel.text = String(p.likeCount)
        commentsLabel.text = String(p.commentCount)
        viewsLabel.text = String(p.viewCount)
        
        activeLabel.text = p.createdAgo
        statusIcon.image = statusIcon.image?.withRenderingMode(.alwaysTemplate)
        statusIcon.tintColor = p.date.getColorFromDateAgo()
    }
}

class FeedViewController: UIViewController, TableManager {
    
    @IBOutlet weak var cardTable: UITableView!
    private final let DISCOVER_IDX = 0
    private final let FOLLOW_IDX = 1
    private final let CARD_IDENTIFIER = "PostCardIdentifier"

    private final let POST_CARD_EMBED_SEGUE = "FeedToCardSegue"
    private final let POST_CREATION_SEGUE = "ToPostCreationSegue"
    private var embeddedView: PostCardViewController!
    
    let deviceLocationService = DeviceLocationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToPostCreate))
        
        // check if dark mode
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "Dark") {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .light
        }
    }

    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        self.embeddedView.discoverActive = sender.selectedSegmentIndex == DISCOVER_IDX
        updateTable()
    }
    
    func updateTable() {
        self.embeddedView.populatePosts()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_CARD_EMBED_SEGUE, let nextVC = segue.destination as? PostCardViewController {
            self.embeddedView = nextVC
            let database = Firestore.firestore()
            let location = deviceLocationService.getLocation()!
            let geohash = Geohash.encode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: .nineteenMeters)
            let query = database.collection("posts").whereField("geohash", isEqualTo: geohash)
            nextVC.query = query
        } else if segue.identifier == POST_CREATION_SEGUE, let nextVC = segue.destination as? PostCreationViewController {
            nextVC.tableManager = self
        }
    }
    
    @objc func goToPostCreate() {
        performSegue(withIdentifier: POST_CREATION_SEGUE, sender: self)
    }
}
