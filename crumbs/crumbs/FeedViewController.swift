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
        
        activeLabel.text = p.active
        
    }
}

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cardTable: UITableView!
    private final let DISCOVER_IDX = 0
    private final let FOLLOW_IDX = 1
    private final let CARD_IDENTIFIER = "PostCardIdentifier"
    private final let POST_VIEW_SEGUE = "FeedToPostSegue"
    
    var discoverActive = true
    
    var posts : [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardTable.delegate = self
        self.cardTable.dataSource = self
        
        for _ in 1...10 {
            posts.append(Post(author: "@author", description: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus malesuada consectetur metus, at sagittis nibh eleifend et. Praesent quis nisl dignissim, interdum dolor vitae, pulvinar nulla. Donec eu nisi quis nunc sagittis viverra et vitae augue. Integer ac dapibus elit, tempor ullamcorper est. In porta ut sem ut efficitur. Sed mollis eget dolor vel tempor. Nullam sem neque, luctus in dolor sit amet, vehicula porttitor nisi. Phasellus a nisi leo. Duis maximus gravida tellus, quis pulvinar lectus vulputate a. Sed non rhoncus tortor. Cras augue dolor, malesuada id imperdiet quis, dapibus dictum diam. Sed non orci id ligula varius vulputate ac quis mauris. Nullam dignissim lectus dui. Duis arcu ante, scelerisque sit amet volutpat consequat, vulputate eget massa. Cras nec nulla egestas, feugiat risus in, aliquet elit. Morbi nisi felis, porta ut gravida non, aliquam eget ex.

            Pellentesque ante felis, placerat a rutrum at, mattis quis leo. Maecenas tincidunt massa est, quis lacinia magna convallis sit amet. Maecenas nec nunc arcu. Praesent sed velit fermentum, volutpat felis ac, sodales sem. Integer sagittis cursus elit, id posuere massa placerat nec. Morbi et turpis ac urna tristique semper in et sapien. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aliquam elementum pellentesque purus, sed pretium dolor luctus ac. Nulla quis ex dapibus, malesuada ante nec, imperdiet neque. Aliquam eget nisl metus. Donec iaculis nec erat eu vestibulum.

            """, title: "some title", active: "1 hour ago", likeCount: 10000, commentCount: 1, viewCount: 1))
        }
        
        self.cardTable.rowHeight = UITableView.automaticDimension
        self.cardTable.estimatedRowHeight = 1000
    }
    
    @objc
    func navigateNext(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToDesignSegue", sender: self)
    }
    

    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == DISCOVER_IDX {
            discoverActive = true
            
        } else if sender.selectedSegmentIndex == FOLLOW_IDX {
            discoverActive = false
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
        if segue.identifier == POST_VIEW_SEGUE, let nextVC = segue.destination as? PostViewController, let rowIndex = cardTable.indexPathForSelectedRow?.row  {
            nextVC.post = posts[rowIndex]
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
