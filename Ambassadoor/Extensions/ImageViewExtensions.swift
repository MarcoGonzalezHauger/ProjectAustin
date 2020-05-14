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
import CoreData

var imageCache = NSCache<NSString, AnyObject>()

//This extension allows UIImageViews to download images from the web and have them saved in cache.

func GetUIActivityIndicator() -> UIActivityIndicatorView {
	if #available(iOS 13.0, *) {
		return UIActivityIndicatorView(style: .medium)
	} else {
		return UIActivityIndicatorView()
	}
}

public extension UIImageView {
    
    struct Holder {
        static var activityIndicatorProperty: UIActivityIndicatorView = GetUIActivityIndicator()
    }
    
	func UseDefaultImage() {
		self.layer.cornerRadius = [self.bounds.width, self.bounds.height].min()! / 2
		self.image = defaultImage
	}
	
    var activityIndicator: UIActivityIndicatorView {
        get {
			return GetUIActivityIndicator()
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
	
	//we decided against havaing borders.
	
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
					DispatchQueue.main.async {
						self.layer.cornerRadius = [self.bounds.width, self.bounds.height].min()! / 2
						image = makeImageCircular(image: image!)
					}
				}
            DispatchQueue.main.async() {
                self.image = image
                self.activityIndicator.stopAnimating()
                self.removeBorder()
            }
            }.resume()
    }
    
    func downloadAndSetImage(_ urlLink: String, isCircle: Bool = true){
        self.showActivityIndicator()
        self.image = nil
		downloadImage(urlLink) { (returnImage) in
			guard let returnImage = returnImage else { return }
			if isCircle {
				self.layer.cornerRadius = [self.bounds.width, self.bounds.height].min()! / 2
				self.image = makeImageCircular(image: returnImage)
			} else {
				self.image = returnImage
			}
		}
    }
}

func saveCoreData(link: String, data: Data) {
	
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	let context = appDelegate.persistentContainer.viewContext
	
	let imageDataEntity = NSEntityDescription.entity(forEntityName: "AppImageData", in: context)
	let imageData = NSManagedObject(entity: imageDataEntity!, insertInto: context)
	imageData.setValue(data, forKey: "imagedata")
	imageData.setValue(link, forKey: "url")
    imageData.setValue(Date.getcurrentESTdate(), forKey: "updatedDate")
    let cacheData = CachedImages.init(object: imageData)
    global.cachedImageList.append(cacheData)
    saveCoreDataUpdate(object: imageData)
	
	
	
}

func downloadProfileImage(_ urlLink: String, completed: @escaping (_ image: UIImage?) -> ()) {
    if urlLink.isEmpty {
         completed(nil)
         return
     }

    let url = URL(string: urlLink)
     URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
         print("DOWNLOAD : \(urlLink)")
         if let err = error {
             print("abc=",err)
             completed(nil)
             return
         }
         DispatchQueue.main.async {
             if let newImage = UIImage(data: data!) {
                 //imageCache.setObject(newImage, forKey: urlLink as NSString)
                 completed(newImage)
                 return
             }
         }
     }).resume()
     
}

func downloadImage(_ urlLink: String, completed: @escaping (_ image: UIImage?) -> ()){
	if urlLink.isEmpty {
		completed(nil)
		return
	}
	// check cache first
	/*
	if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
	print("CHACHED  : \(urlLink)")
	completed(cachedImage)
	return
	}
	*/
	
	let cachedImage = global.cachedImageList.filter { (cache) -> Bool in
		return cache.link! == urlLink
	}
	
	if cachedImage.count != 0{
		
		if let image = UIImage(data: cachedImage.first!.imagedata!){
			
			//print("CHACHED  : \(urlLink)")
            
            if let imageData = cachedImage.first!.object {
                imageData.setValue(Date.getcurrentESTdate(), forKey: "updatedDate")
                saveCoreDataUpdate(object: imageData)
            }
			completed(image)
			return
			
		}
	}
    
	
	// otherwise, download
	let url = URL(string: urlLink)
	URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
		//print("DOWNLOAD : \(urlLink)")
		if let err = error {
			print("abc=",err)
			completed(nil)
			return
		}
		DispatchQueue.main.async {
            
            saveCoreData(link: urlLink, data: data!)
            
			if let newImage = UIImage(data: data!) {
				//imageCache.setObject(newImage, forKey: urlLink as NSString)
				completed(newImage)
				return
			}
		}
	}).resume()
	
}
