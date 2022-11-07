//
//  UIButtonExtensions.swift
//  crumbs
//
//  Created by Kevin Li on 11/7/22.
//

import Foundation
import UIKit

extension UIButton {
    
    func imageOverlay(
        image: UIImage,
        backgroundColor: UIColor,
        overlayBackgroundColor: UIColor,
        overlayImage: UIImage,
        imageMargins: CGFloat
    ) {
        let frame = self.frame
        let scaled = image.scale(with: CGSize(width: frame.width, height: frame.height))
        
        self.setImage(scaled, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.contentMode = .left
        
        let transpView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        transpView.backgroundColor = overlayBackgroundColor
        transpView.contentMode = .scaleAspectFit
        
        transpView.image = overlayImage.with(UIEdgeInsets(top: imageMargins, left: imageMargins, bottom: imageMargins, right: imageMargins))
        

        self.imageView?.addSubview(transpView)
        
        
        self.imageView?.clipsToBounds = true
        self.imageView?.layer.cornerRadius = 20
        self.backgroundColor = backgroundColor
    }
}
