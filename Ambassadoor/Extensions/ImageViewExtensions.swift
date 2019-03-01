//
//  ImageViewExtensions.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/6/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, AnyObject>()

public extension UIImageView {
    
    struct Holder {
        static var activityIndicatorProperty: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    }
    
    var activityIndicator: UIActivityIndicatorView {
        get {
            return UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        }
        set(newValue) {
            Holder.activityIndicatorProperty = newValue
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2);
        self.addBorder()
        
        OperationQueue.main.addOperation({ () -> Void in
            self.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        })
    }
    
    func addBorder() {
//        self.layer.borderColor = UIColor.gray.cgColor
//        self.layer.borderWidth = 1
		self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func removeBorder() {
//        self.layer.borderColor = UIColor.white.cgColor
    }
	
	func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, makeImageCircular isCircle: Bool = true) {
        contentMode = mode
        self.showActivityIndicator()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data
				else { return }
                var image = UIImage(data: data)
				if image == nil {
					return
				}
				if isCircle {
					image = makeImageCircular(image: image!)
				}
            DispatchQueue.main.async() {
                self.image = image
                self.activityIndicator.stopAnimating()
                self.removeBorder()
            }
            }.resume()
    }
    
    func downloadImageUsingCacheWithLink(_ urlLink: String, isCircle: Bool = true){
        self.showActivityIndicator()
        self.image = nil
        
        if urlLink.isEmpty {
            return
        }
        // check cache first
        if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
            if isCircle {
                self.image = makeImageCircular(image: cachedImage)
            } else {
                self.image = cachedImage
            }
            return
        }
        
        // otherwise, download
        let url = URL(string: urlLink)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let err = error {
                print(err)
                return
            }
            DispatchQueue.main.async {
                if let newImage = UIImage(data: data!) {
                    imageCache.setObject(newImage, forKey: urlLink as NSString)
                    if isCircle {
                        self.image = makeImageCircular(image: newImage)
                    } else {
                        self.image = newImage
                    }
                    self.removeBorder()
                    self.activityIndicator.stopAnimating()
                }
            }
        }).resume()
        
    }
}
