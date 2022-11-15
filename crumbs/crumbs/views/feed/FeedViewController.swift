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

class FeedViewController: UIViewController, TableManager, PostPopulator {
    
    @IBOutlet weak var cardTable: UITableView!
    private final let DISCOVER_IDX = 0
    private final let FOLLOW_IDX = 1
    private final let CARD_IDENTIFIER = "PostCardIdentifier"

    private final let POST_CARD_EMBED_SEGUE = "FeedToCardSegue"
    private final let POST_CREATION_SEGUE = "ToPostCreationSegue"
    private final let HEATMAP_SEGUE = "FeedToHeatmapSegue"
    private var embeddedView: PostCardViewController!
    
    let deviceLocationService = DeviceLocationService.shared
    var discoverActive = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(goToPostCreate))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(goToHeatmap))
        
        addNavBarImage()
        // check if dark mode
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "Dark") {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.overrideUserInterfaceStyle = .light
        }
    }
    
    func addNavBarImage() {
            let navController = navigationController!
            let image = UIImage(named: "NavbarLogo.png") //Your logo url here
            let imageView = UIImageView(image: image)
            let bannerWidth = navController.navigationBar.frame.size.width
            let bannerHeight = navController.navigationBar.frame.size.height
            let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
            let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
            imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        self.discoverActive = sender.selectedSegmentIndex == DISCOVER_IDX
        updateTable()
    }
    
    func updateTable() {
        self.embeddedView.updateTable()
    }
    
    func refreshTable() {
        self.embeddedView.refreshTable()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_CARD_EMBED_SEGUE, let nextVC = segue.destination as? PostCardViewController {
            self.embeddedView = nextVC
            nextVC.delegate = self
        } else if segue.identifier == POST_CREATION_SEGUE, let nextVC = segue.destination as? PostCreationViewController {
            nextVC.tableManager = self
        } else if segue.identifier == HEATMAP_SEGUE {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func emptyPlaceholderString() -> String {
        return discoverActive ? "Move around to find some Crumbs or drop your own." : "Follow some Crumbs to see them here."
    }
    
    func populatePosts(completion: ((_: [Post]) -> Void)?) {
        let db = Firestore.firestore()
        let location = deviceLocationService.getLocation()!
        let geohash = Geohash.encode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: .nineteenMeters)
        
        if discoverActive {
            let query = db.collection("posts").whereField("geohash", isEqualTo: geohash)
            query.order(by: "timestamp", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                let posts = querySnapshot!.documents.map {Post(snapshot: $0)}
                if completion != nil {
                    completion!(posts)
                }
            }
        } else {
            CUR_USER.docRef.getDocument{ (document, error) in
                if error != nil {
                    print("there is an error")
                    return
                }
                if let document = document, document.exists {
                    let followedPosts = document.get("followed_posts") as! [DocumentReference]
                    var posts: [Post] = []
                    if followedPosts.count == 0 {
                        if completion != nil {
                            completion!(posts)
                        }
                        return
                    }
                    db.collection("posts").whereField(FieldPath.documentID(), in: followedPosts).getDocuments() {
                        (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            posts = querySnapshot!.documents.map {Post(snapshot: $0)}
                        }
                        if completion != nil {
                            completion!(posts)
                        }
                    }
                } else {
                    print("Document does not exist in cache")
                }
            }
        }
    }
    
    @objc func goToPostCreate() {
        performSegue(withIdentifier: POST_CREATION_SEGUE, sender: self)
    }
    
    @objc func goToHeatmap() {
        performSegue(withIdentifier: HEATMAP_SEGUE, sender: self)
    }
}
