//
//  PostViewController.swift
//  crumbs
//
//  Created by Kevin Li on 10/17/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

public func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
}


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
        delegate.updateLikeState(likeState: likeActive)
    }
    
    @objc func clickedOnProfile(sender: UITapGestureRecognizer) {
        delegate.callSegueToProfile()
    }
    
    @objc func clickedOnImage(sender: UITapGestureRecognizer) {
        guard postImage.image != nil else { return }
        self.delegate.presentLightbox()
    }

    func assignAttributes(p: Post, user: User, image: UIImage?) {
        postImage.layer.masksToBounds = true
        likeActive = user.hasLikedPost(p: p)
        likeButton.setImage(likeActive ? activeLike : inactiveLike, for: .normal)
        post = p
        handlePostUpdate()
        // Check if there is a post image.
        if image != nil {
            postImage.contentMode = .scaleAspectFill
            postImage.image = image
        } else {
            postImage.frame = CGRect(x:0, y: 0, width:0, height:0)
        }
        
        
        // Enable clicks on the profile.
        let profileGesture = UITapGestureRecognizer(target: self, action: #selector(clickedOnProfile))
        profileStackView.isUserInteractionEnabled = true
        profileStackView.addGestureRecognizer(profileGesture)
        
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(clickedOnImage))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(imageGesture)
        delegate.updateLikeState(likeState: likeActive)
    }
}

class CommentCardCell : UITableViewCell {

    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    var comment: Comment!
    
    // 1 = upvoted, -1, downvoted, 0 not interacted
    var delta: Int!
    var originalDelta: Int!
    var delegate: PostCommentDelegator!
    var row: Int!
    
    
    let enabledUpvote: UIImage = UIImage(systemName: "arrowtriangle.up.circle")!.withRenderingMode(.alwaysTemplate)
    let disabledUpvote: UIImage = UIImage(systemName: "arrowtriangle.up.circle.fill")!.withRenderingMode(.alwaysTemplate)
    let enabledDownvote: UIImage = UIImage(systemName: "arrowtriangle.down.circle")!.withRenderingMode(.alwaysTemplate)
    let disabledDownvote: UIImage = UIImage(systemName: "arrowtriangle.down.circle.fill")!.withRenderingMode(.alwaysTemplate)

    @IBAction func upvotePressed(_ sender: Any) {
        // Already liked, removing like.
        if delta == 1 {
            delegate.removeFromUpvote(c: comment)
            delta = 0
            upvoteButton.setImage(enabledUpvote, for: .normal)
            comment.upvotes -= 1
            upvotesLabel.text = String(comment.upvotes)
            delegate.setDelta(row: row, delta: delta)
            return
        }
        
        if delta == 0 {
            delegate.addToUpvote(c: comment)
        } else if delta == -1 {
            delegate.removeFromDownvote(c: comment)
            delegate.addToUpvote(c: comment)
        }
        
        upvoteButton.setImage(disabledUpvote, for: .normal)
        downvoteButton.setImage(enabledDownvote, for: .normal)
        
        comment.upvotes += 1 - delta
        upvotesLabel.text = String(comment.upvotes)
        delta = 1
        delegate.setDelta(row: row, delta: delta)
    }
    
    @IBAction func downvotePressed(_ sender: Any) {
        
        // Already disliked, removing dislike.
        if delta == -1 {
            delegate.removeFromDownvote(c: comment)
            delta = 0
            downvoteButton.setImage(enabledDownvote, for: .normal)
            comment.upvotes += 1
            upvotesLabel.text = String(comment.upvotes)
            delegate.setDelta(row: row, delta: delta)
            return
        }
        
        if delta == 0 {
            delegate.addToDownvote(c: comment)
        } else if delta == 1 {
            delegate.removeFromUpvote(c: comment)
            delegate.addToDownvote(c: comment)
        }
        
        downvoteButton.setImage(disabledDownvote, for: .normal)
        upvoteButton.setImage(enabledUpvote, for: .normal)
        
        comment.upvotes -= delta + 1
        delta = -1
        upvotesLabel.text = String(comment.upvotes)
        delegate.setDelta(row: row, delta: delta)
    }
    
    func displayForDelta(delta: Int) {
        if self.delta == 1 {
            downvoteButton.setImage(enabledDownvote, for: .normal)
            upvoteButton.setImage(disabledUpvote, for: .normal)
        } else if self.delta == -1 {
            downvoteButton.setImage(disabledDownvote, for: .normal)
            upvoteButton.setImage(enabledUpvote, for: .normal)
        } else {
            upvoteButton.setImage(enabledUpvote, for: .normal)
            downvoteButton.setImage(enabledDownvote, for: .normal)
        }
    }

    func assignAttributes(c: Comment, delta: Int) {
        upvotesLabel.text = String(c.upvotes)
        commentsLabel.text = c.comment
        authorLabel.text = c.username
        createdLabel.text = c.timeAgo
        comment = c
        self.delta = delta
        self.originalDelta = delta
        displayForDelta(delta: delta)
    }
}

// Provides link for functionality between post cell and view controller.
protocol PostCellDelegator {
    func callSegueToProfile()
    func presentLightbox()
    func updateLikeState(likeState: Bool)
}

// Provides link for functionality between comments and view controller.
protocol PostCommentDelegator {
    func removeFromUpvote(c: Comment)
    func removeFromDownvote(c: Comment)
    func addToUpvote(c: Comment)
    func addToDownvote(c: Comment)
    func setDelta(row: Int, delta: Int)
}


class PostViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    LightboxControllerPageDelegate,
    LightboxControllerDismissalDelegate,
    PostCellDelegator,
    PostCommentDelegator {
    
    var post: Post!
    var followActive: Bool = false

    @IBOutlet weak var postViewTable: UITableView!
    @IBOutlet weak var addCommentButton: UIButton!
    
    private final let POST_VIEW_TO_COMMENT_SEGUE = "PostViewToCommentSegue"
    private final let POST_IDENTIFIER = "PostIdentifier"
    private final let COMMENT_IDENTIFIER = "CommentCardIdentifier"
    private final let ESTIMATED_ROW_HEIGHT = 1000
    
    private final let PROFILE_VIEW_SEGUE = "PostToProfileSegue"
    
    var tableManager: TableManager?
    var commentDeltas: [Int] = []
    var commentDeltasDoc: DocumentReference!

    
    var originalLikeState: Bool!
    var currentLikeState: Bool = false
    var postImage: UIImage? = nil
    
    func updateLikeState(likeState: Bool) {
        currentLikeState = likeState
    }
    
    func setDelta(row: Int, delta: Int) {
        commentDeltas[row] = delta
    }

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
    
    // Initializes and sets image data.
    private func initializeImageData() async throws -> UIImage? {
        guard post.uiImage == nil && post.imageUrl != nil else {
            return nil
        }
        let (data, _) = try await URLSession.shared.data(from: URL(string: post.imageUrl!)!)
        
        return UIImage(data: data)
    }
    
    // Initializes comments delta data.
    private func initializeCommentsDeltaData() async throws {
        let doc = try await self.post.getCommentDeltaDoc(user: CUR_USER.docRef)
        let deltas = try await self.post.getCommentDeltaForUser(upvoteRelation: doc)
        self.commentDeltas = deltas
        self.commentDeltasDoc = doc
    }
    
    private func loadData() {
        
        self.showSpinner(onView: self.view)
        Task {
            async let imageDataPromise: UIImage? = initializeImageData()
            async let commentsDeltaPromise: Void = initializeCommentsDeltaData()
            
            let image: UIImage? = try await imageDataPromise
            try await commentsDeltaPromise
            
            
            DispatchQueue.main.async {
                self.removeSpinner()
                if image != nil {
                    self.post.uiImage = image
                    self.postImage = image
                }
                self.postViewTable.reloadData()
            }
        }
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
        loadData()
        self.populateComments()
        followActive = CUR_USER.hasFollowedPost(p: self.post)
        // fix later
        var buttonLabel: String {
                // Compute the label based on button state
            followActive ? "Unfollow" : "Follow"
            }
        
        if !followActive {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonLabel, style: .plain, target: self, action: #selector(followPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonLabel, style: .plain, target: self, action: #selector(unfollowPressed))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        followActive = CUR_USER.hasFollowedPost(p: self.post)

        // fix later
        var buttonLabel: String {
                // Compute the label based on button state
            followActive ? "Unfollow" : "Follow"
            }
        
        if !followActive {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonLabel, style: .plain, target: self, action: #selector(followPressed))
        } else {
            followPressed()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonLabel, style: .plain, target: self, action: #selector(unfollowPressed))
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let row = indexPath.row
            
            if row == post.commentCount + 1 {
                return 100
            }
            
            return UITableView.automaticDimension
        }
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        // pass
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        // pass
    }

    func presentLightbox() {
        let images = [LightboxImage(image: postImage!)]
        let controller = LightboxController(images: images)
        
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self

        // Use dynamic background.
        controller.dynamicBackground = true

        // Present your controller.
        self.present(controller, animated: true, completion: nil)
    }
    
    private func updateUpvotes(c: Comment) async throws {
        try await c.docRef.updateData([
            "upvotes": c.upvotes
        ])
    }
    
    // Delegator functions for Comments.
    func removeFromUpvote(c: Comment) {
        Task {
            try await commentDeltasDoc.updateData([
                "upvoted": FieldValue.arrayRemove([c.docRef])
            ])
            try await updateUpvotes(c: c)
        }
    }
    func removeFromDownvote(c: Comment) {
        Task {
            try await commentDeltasDoc.updateData([
                "downvoted": FieldValue.arrayRemove([c.docRef])
            ])
            try await updateUpvotes(c: c)
        }
    }
    func addToUpvote(c: Comment) {
        Task {
            try await commentDeltasDoc.updateData([
                "upvoted": FieldValue.arrayUnion([c.docRef])
            ])
            try await updateUpvotes(c: c)
        }
    }
    func addToDownvote(c: Comment) {
        Task {
            try await commentDeltasDoc.updateData([
                "downvoted": FieldValue.arrayUnion([c.docRef])
            ])
            try await updateUpvotes(c: c)
        }
    }
    
    @objc func unfollowPressed() {
        // change button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followPressed))
        followActive = false

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
        followActive = true
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

            cell.delegate = self
            cell.assignAttributes(p: post, user: CUR_USER, image: self.postImage)
            cell.selectionStyle = .none
            return cell
        } else if row == post.commentCount + 1 {
            let cell = UITableViewCell()
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        // Remaining cells are comments.
        let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_IDENTIFIER, for: indexPath) as! CommentCardCell
        cell.row = row - 1
        let sortedComments = post.comments.sorted {
            $0.date < $1.date
        }
        // Edge case for adding comment.
        if row - 1 == commentDeltas.count {
            commentDeltas.append(0)
        }
        cell.assignAttributes(c: sortedComments[row - 1], delta: commentDeltas[row - 1])
        cell.selectionStyle = .none
        cell.delegate = self
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
    
    func populateComments() {
        self.post.docRef?.collection("comments").getDocuments(completion: {
            (querySnapshot, error) in
            guard error == nil else {
                print("Error getting comments: \(String(describing: error))")
                return
            }
            
            self.post.comments = querySnapshot!.documents.map {Comment(snapshot: $0)}
            self.postViewTable.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.currentLikeState != self.originalLikeState {
            updateLikeForUserAndPost(isLiking: self.currentLikeState)
        }
        
        
        if self.tableManager == nil {
            return
        }
        self.tableManager!.refreshTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // +1 for the post, +1 for the empty cell.
        return 2 + post.commentCount
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
        if segue.identifier == POST_VIEW_TO_COMMENT_SEGUE, let nextVC = segue.destination as? AddCommentViewController {
            nextVC.post = self.post
            nextVC.postViewTable = self.postViewTable
        }
    }
}
