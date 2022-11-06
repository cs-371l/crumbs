//
//  PostViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostViewCell : UITableViewCell {
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var post: Post!
    
    var likeActive: Bool = false
    
    private final let activeLike = UIImage(systemName: "suit.heart.fill")
    private final let inactiveLike = UIImage(systemName: "suit.heart")
    private final let scaleUpFactor: CGFloat = 1.2
    private final let scaleDownFactor: CGFloat = 0.8
    private final let animationTime = 0.1
    
    func handlePostUpdate() {
        authorLabel.text = post.author
        titleLabel.text = post.title
        descriptionLabel.text = post.description
        likesLabel.text = String(post.likeCount)
        viewsLabel.text = String(post.viewCount)
    }

    @IBAction func likePressed(_ sender: Any) {
        likeActive = !likeActive
        
        // Handles pulsating animation,
        // reference: https://betterprogramming.pub/recreating-instagrams-like-%EF%B8%8F-animation-in-swift-6b95f74c9593
        // TODO: refactor this in case we want a generic UIButton that pulsates (e.g., for comments).
        UIView.animate(
            withDuration: animationTime,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                let scale = self.likeActive ? self.scaleUpFactor : self.scaleDownFactor
                self.likeButton.transform = self.likeButton.transform.scaledBy(x: scale, y: scale)
                self.likeButton.setImage(self.likeActive ? self.activeLike : self.inactiveLike, for: .normal)
            },
            completion: {
                finished in
                UIView.animate(withDuration: self.animationTime, delay: 0.0, options: .curveEaseIn, animations: {
                    self.likeButton.transform = CGAffineTransform.identity
                })
            }
        )
        post.likeCount += likeActive ? 1 : -1
        handlePostUpdate()
    }

    func assignAttributes(p: Post, user: User) {
        likeActive = user.hasLikedPost(p: p)
        print(likeActive)
        likeButton.setImage(likeActive ? activeLike : inactiveLike, for: .normal)
        post = p
        handlePostUpdate()
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
    
    var tableManager: TableManager!

    
    var originalLikeState: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postViewTable.delegate = self
        postViewTable.dataSource = self
        postViewTable.tableHeaderView = UIView()
        
        postViewTable.rowHeight = UITableView.automaticDimension
        postViewTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
        originalLikeState = CUR_USER.hasLikedPost(p: post)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // First cell is the post. Assign attributes and prevent selection.
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: POST_IDENTIFIER, for: indexPath) as! PostViewCell
            cell.assignAttributes(p: post, user: CUR_USER)
            cell.selectionStyle = .none
            return cell
        }
        
        // Remaining cells are comments.
        let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_IDENTIFIER, for: indexPath) as! CommentCardCell
        cell.assignAttributes(c: post.comments[row - 1])
        return cell
    }
    
    // Transaction to update both the number of likes on the post
    // and the liked posts for the user.
    func updateLikeForUserAndPost(isLiking: Bool) {
        let db = Firestore.firestore()
        
        // Atomically updates the user's liked posts and the number of likes
        // in the post. There is a small caveat here where the same user
        // could log in to the same account on two different devices and like/dislike
        // the same post -- this is not currently being handled.
        db.runTransaction({
            (transaction, errorPointer) -> Any? in
            
            guard self.post.docRef != nil else { return nil }
            
            let postDocument: DocumentSnapshot
            let userDocument: DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(self.post.docRef!)
                try userDocument = transaction.getDocument(CUR_USER.docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            let oldLikes = postDocument.data()?["likes"] as! Int
            var liked = userDocument.data()?["liked_posts"] as! [DocumentReference]
            liked.append(self.post.docRef!)
            
            let likeDelta = isLiking ? 1 : -1
            transaction.updateData(["likes": oldLikes + likeDelta], forDocument: self.post.docRef!)
            transaction.updateData(
                [
                    "liked_posts": isLiking ?
                        FieldValue.arrayUnion([self.post.docRef!]) :
                        FieldValue.arrayRemove([self.post.docRef!])
                ],
                forDocument: CUR_USER.docRef
            )
            return nil
        }){(object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            }
        }
        
        // For full parity between in-memory and database.
        if isLiking {
            CUR_USER.addLikedPost(p: self.post)
        } else {
            CUR_USER.removedLikedPost(p: self.post)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let firstIndex = IndexPath(row: 0, section: 0)
        let postCell = postViewTable.cellForRow(at: firstIndex) as! PostViewCell
        // Need to check if we have to update anything for
        // the user or the post.
        if postCell.likeActive != self.originalLikeState {
            print(postCell.likeActive)
            updateLikeForUserAndPost(isLiking: postCell.likeActive)
        }
        self.tableManager.updateTable()
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
