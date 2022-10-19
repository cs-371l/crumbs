//
//  FeedViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/14/22.
//

import UIKit

class PostTableViewCell : UITableViewCell {
    
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
    }
}

class FeedViewController: UIViewController {
    
    @IBOutlet weak var cardTable: UITableView!
    private final let DISCOVER_IDX = 0
    private final let FOLLOW_IDX = 1
    private final let CARD_IDENTIFIER = "PostCardIdentifier"

    private final let POST_CARD_EMBED_SEGUE = "FeedToCardSegue"
    private var embeddedView: PostCardViewController!
    // Defaulted to discover active.
    var discoverActive = true
    var discoverPosts : [Post] = generatePostData()
    var followPosts : [Post]  = generatePostData()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == DISCOVER_IDX {
            embeddedView.posts = self.discoverPosts
            embeddedView.cardTable.reloadData()
            embeddedView.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            
        } else if sender.selectedSegmentIndex == FOLLOW_IDX {
            embeddedView.posts = self.followPosts
            embeddedView.cardTable.reloadData()
            embeddedView.cardTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Going into post view, pass in the post.
        if segue.identifier == POST_CARD_EMBED_SEGUE, let nextVC = segue.destination as? PostCardViewController {
            self.embeddedView = nextVC
            nextVC.posts = self.discoverActive ? self.discoverPosts : self.followPosts
        }
    }
}
