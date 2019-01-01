//
//  global.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/23/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation

@objc protocol GlobalListener {
	@objc optional func AvaliableOffersChanged() -> ()
	@objc optional func RejectedOffersChanged() -> ()
	@objc optional func AcceptedOffersChanged() -> ()
	@objc optional func CompletedOffersChanged() -> ()
}

class CentralVariables {
	
	//The offers that are currently in the users inbox.
	var AvaliableOffers: [Offer] = [] {
		didSet {
			EachListener(){
				if let targetfunction = $0.AvaliableOffersChanged {
					targetfunction()
				}
			}
		}
	}
	
	//The offers that the user has rejected.
	var RejectedOffers: [Offer] = [] {
		didSet {
			EachListener(){
				if let targetfunction = $0.RejectedOffersChanged {
					targetfunction()
				}
			}
		}
	}
	
	//The offers that the user has accepted.
	var AcceptedOffers: [Offer] = [] {
		didSet {
			EachListener(){
				if let targetfunction = $0.AcceptedOffersChanged {
					targetfunction()
				}
			}
		}
	}
	
	//The offers the user has completed.
	var CompletedOffers: [Offer] = [] {
		didSet {
			EachListener(){
				if let targetfunction = $0.CompletedOffersChanged {
					targetfunction()
				}
			}
		}
	}
	
	//Every VC that is connected to this global variable.
	func EachListener(updatefor: (_ Listener: GlobalListener) -> ()) {
		for x : GlobalListener in delegates {
			updatefor(x)
		}
	}	
	var delegates: [GlobalListener] = []
}

let global = CentralVariables()
