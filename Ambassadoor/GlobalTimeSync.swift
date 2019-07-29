//
//  GlobalTimeSync.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/30/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation

//the purpose of this class is the ensure that all checks for data and regular updates to the program work in unison.

protocol SyncTimerDelegate {
	func Tick() -> ()
}

class SyncronizedTimer {
	
	init() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: tick)
	}
	
	var timer : Timer!
	
	//Timer has been 'ticked'
	func tick(timer: Timer) -> Void {
		for x : SyncTimerDelegate in delegates {
			x.Tick()
		}
	}
	
	var delegates: [SyncTimerDelegate] = [] {
		didSet {
			tick(timer: timer)
		}
	}
	
}

let globalTimer = SyncronizedTimer()
