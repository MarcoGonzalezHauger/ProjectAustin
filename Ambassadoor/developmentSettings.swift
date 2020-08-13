//
//  developmentSettings.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 8/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

enum APImode: String {
	case dontUseInstagramBasicDisplay //This mode will not use the Instagram Basic Display API at any time.
	case doUseInstagramBasicDisplay //This mode will not use any business integration.
	case normal //Won't change anything.
}

//var InstagramAPI: APImode = .dontUseInstagramBasicDisplay
