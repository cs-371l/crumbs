//
//  PostViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import UIKit

class PostViewCell : UITableViewCell {
    
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    func assignAttributes(p: Post) {
        authorLabel.text = p.author
        titleLabel.text = p.title
        descriptionLabel.text = p.description
        likesLabel.text = String(p.likeCount)
        viewsLabel.text = String(p.viewCount)
    }
}

class CommentCardCell : UITableViewCell {

    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    func assignAttributes(c: Comment) {
        upvotesLabel.text = String(c.upvotes)
        commentsLabel.text = c.comment
        authorLabel.text = c.author
        createdLabel.text = c.timeAgo
    }
}

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var post: Post!
    @IBOutlet weak var postViewTable: UITableView!
    
    private final let POST_IDENTIFIER = "PostIdentifier"
    private final let COMMENT_IDENTIFIER = "CommentCardIdentifier"
    private final let ESTIMATED_ROW_HEIGHT = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postViewTable.delegate = self
        postViewTable.dataSource = self
        postViewTable.tableHeaderView = UIView()
        
        postViewTable.rowHeight = UITableView.automaticDimension
        postViewTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // First cell is the post. Assign attributes and prevent selection.
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: POST_IDENTIFIER, for: indexPath) as! PostViewCell
            cell.assignAttributes(p: post)
            cell.selectionStyle = .none
            return cell
        }
        
        // Remaining cells are comments.
        let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_IDENTIFIER, for: indexPath) as! CommentCardCell
        cell.assignAttributes(c: post.comments[row - 1])
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // +1 for the post.
        return 1 + post.commentCount
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
