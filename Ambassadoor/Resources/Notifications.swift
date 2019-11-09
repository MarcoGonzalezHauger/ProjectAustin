//
//  Notifications.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/10/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UNNotificationAttachment {
	
	static func make(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
		let fileManager = FileManager.default
		let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
		let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
		do {
			try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
			let imageFileIdentifier = identifier+".png"
			let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
			guard let imageData = image.pngData() else {
				return nil
			}
			try imageData.write(to: fileURL)
			let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
			return imageAttachment
		} catch {
			print("error " + error.localizedDescription)
		}
		return nil
	}
}
