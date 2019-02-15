//
//  ImageViewExtensions.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/6/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import Foundation

let imageCache = NSCache<NSString, AnyObject>()

public extension UIImageView {
	
	func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, makeImageCircular isCircle: Bool = true) {
        contentMode = mode
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
            }
            }.resume()
    }
    
    func downloadImageUsingCacheWithLink(_ urlLink: String){
        self.image = nil
        
        if urlLink.isEmpty {
            return
        }
        // check cache first
        if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
            self.image = cachedImage
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
                    
                    self.image = newImage
                }
            }
        }).resume()
        
    }
}
