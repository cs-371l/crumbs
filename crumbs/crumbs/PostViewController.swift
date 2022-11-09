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
    
    
    @IBOutlet weak var profileStackView: UIStackView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var post: Post!
    
    var likeActive: Bool = false
    var delegate: PostCellDelegator!
    
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
    
    @objc func clickedOnProfile(sender: UITapGestureRecognizer) {
        delegate.callSegueToProfile()
    }

    func assignAttributes(p: Post, user: User, image: UIImage?) {
        postImage.layer.masksToBounds = true
        likeActive = user.hasLikedPost(p: p)
        likeButton.setImage(likeActive ? activeLike : inactiveLike, for: .normal)
        post = p
        handlePostUpdate()
        // Check if there is a post image.
        if image != nil {
            let scaled = image?.scale(with: CGSize(width: 348, height: 250))
            postImage.frame = CGRect(x: 0, y: 0, width: scaled!.size.width, height: scaled!.size.height)
            postImage.image = scaled
        }
        
        
        // Enable clicks on the profile.
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(clickedOnProfile))
        profileStackView.isUserInteractionEnabled = true
        profileStackView.addGestureRecognizer(profileGesture)
        
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

protocol PostCellDelegator {
    func callSegueToProfile()
}

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostCellDelegator {
    
    var post: Post!
    @IBOutlet weak var postViewTable: UITableView!
    
    private final let POST_IDENTIFIER = "PostIdentifier"
    private final let COMMENT_IDENTIFIER = "CommentCardIdentifier"
    private final let ESTIMATED_ROW_HEIGHT = 1000
    
    private final let PROFILE_VIEW_SEGUE = "PostToProfileSegue"
    
    var tableManager: TableManager?

    
    var originalLikeState: Bool!
    var postImage: UIImage? = nil
    
    func callSegueToProfile() {

        // Cached user.
        if post.user != nil {
            self.performSegue(withIdentifier: self.PROFILE_VIEW_SEGUE, sender: nil)
            return
        }
        
        // Fetch user.
        self.showSpinner(onView: self.view)
        
        post.creatorRef.getDocument {
            snapshot, error in
            guard error == nil else {
                self.showErrorAlert(title: "Error", message: "Unable to fetch user data")
                return
            }
            
            DispatchQueue.main.async {
                self.removeSpinner()
                let user = User(snapshot: snapshot!)
                
                self.post.user = user
                self.performSegue(withIdentifier: self.PROFILE_VIEW_SEGUE, sender: nil)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postViewTable.delegate = self
        postViewTable.dataSource = self
        postViewTable.tableHeaderView = UIView()
        
        postViewTable.rowHeight = UITableView.automaticDimension
        postViewTable.estimatedRowHeight = CGFloat(ESTIMATED_ROW_HEIGHT)
        originalLikeState = CUR_USER.hasLikedPost(p: post)
        
        if post.uiImage != nil {
            self.postImage = post.uiImage
        }
        
        if (!CUR_USER.hasViewedPost(p: self.post)){
            updateViewsForUserAndPost()
            post.viewCount += 1
        }
        
        if post.uiImage == nil && post.imageUrl != nil {
            self.showSpinner(onView: self.view)
            getData(from: URL(string: post.imageUrl!)!) {
                data, resp, error in
                guard let data = data, error == nil else {
                    self.showErrorAlert(title: "Error", message: "Unable to load post.")
                    return
                }
                DispatchQueue.main.async {
                    self.postImage = UIImage(data: data)
                    self.post.uiImage = self.postImage
                    self.removeSpinner()
                    self.postViewTable.reloadData()
                }
            }
        }
        
        if CUR_USER.hasFollowedPost(p: self.post) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .plain, target: self, action: #selector(unfollowPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followPressed))
        }
    }
    
    @objc func unfollowPressed() {
        print("unfollow pressed")
        // change button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(unfollowPressed))
        // perform action
        let db = Firestore.firestore()
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

            var followed = userDocument.data()?["followed_posts"] as! [DocumentReference]
            followed.append(self.post.docRef!)
            
            transaction.updateData(
                [
                    "followed_posts": FieldValue.arrayRemove([self.post.docRef!])],
                forDocument: CUR_USER.docRef
            )
            DispatchQueue.main.async {
                self.tableManager?.updateTable()
            }
            return nil
        }){(object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            }
        }
        
        // For full parity between in-memory and database.
        CUR_USER.removedFollwedPost(p: self.post)
    }
    
    @objc func followPressed() {
        print("follow pressed")
        // change button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .plain, target: self, action: #selector(unfollowPressed))
        // perform action
        let db = Firestore.firestore()
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

            var followed = userDocument.data()?["followed_posts"] as! [DocumentReference]
            followed.append(self.post.docRef!)
            
            transaction.updateData(
                [
                    "followed_posts": FieldValue.arrayUnion([self.post.docRef!])],
                forDocument: CUR_USER.docRef
            )
            DispatchQueue.main.async {
                self.tableManager?.updateTable()
            }
            return nil
        }){(object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            }
        }
        
        // For full parity between in-memory and database.
        CUR_USER.addFollwedPost(p: self.post)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        // First cell is the post. Assign attributes and prevent selection.
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: POST_IDENTIFIER, for: indexPath) as! PostViewCell

            cell.assignAttributes(p: post, user: CUR_USER, image: self.postImage)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
        
        // Remaining cells are comments.
        let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_IDENTIFIER, for: indexPath) as! CommentCardCell
        cell.assignAttributes(c: post.comments[row - 1])
        return cell
    }
    
    func updateViewsForUserAndPost() {
        let db = Firestore.firestore()
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
            
            let oldViews = postDocument.data()?["views"] as! Int
            var viewed = userDocument.data()?["viewed_posts"] as! [DocumentReference]
            viewed.append(CUR_USER.docRef)
            transaction.updateData(["views": oldViews + 1], forDocument: self.post.docRef!)
            transaction.updateData(
                ["viewed_posts": FieldValue.arrayUnion([self.post.docRef!])], forDocument: CUR_USER.docRef)
            return nil
        }){(object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            }
        }
        
        CUR_USER.addViewedPosts(p: self.post)
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
    
    override func viewWillAppear(_ animated: Bool) {
        if CUR_USER.hasFollowedPost(p: self.post) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .plain, target: self, action: #selector(unfollowPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followPressed))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let firstIndex = IndexPath(row: 0, section: 0)
        let postCell = postViewTable.cellForRow(at: firstIndex) as! PostViewCell
        // Need to check if we have to update anything for
        // the user or the post.
        if postCell.likeActive != self.originalLikeState {
            updateLikeForUserAndPost(isLiking: postCell.likeActive)
        }
        
        
        if self.tableManager == nil {
            return
        }
        self.tableManager!.updateTable()
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == PROFILE_VIEW_SEGUE {
            return self.post.user != nil
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PROFILE_VIEW_SEGUE {
            if let nextViewController = segue.destination as? ProfileViewController {
                nextViewController.user = self.post.user!
            }
        }
    }
}
