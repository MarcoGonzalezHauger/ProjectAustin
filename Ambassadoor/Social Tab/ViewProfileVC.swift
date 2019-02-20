//
//  ViewProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/14/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class StatisticCell: UITableViewCell {
	@IBOutlet weak var Name: UILabel!
	@IBOutlet weak var Value: UILabel!
	
	func SetData(Statistic: Stat) {
		Name.text = Statistic.name
		var num: String = NumberToStringWithCommas(number: Statistic.value)
		if Statistic.value == 0 {
			Value.textColor = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1)
		} else if Statistic.value > 0 {
			Value.textColor = UIColor(red: 42/255, green: 160/255, blue: 88/255, alpha: 1)
			num = "+\(num)"
		} else {
			Value.textColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
		}
		Value.text = num
	}
}

struct Stat {
	let name: String
	let value: Double
}

class ViewProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var ThisUser: User! {
		didSet {
			stats = [Stat.init(name: "Follower Count", value: ThisUser.followerCount - Yourself!.followerCount), Stat.init(name: "Follower Count", value: (ThisUser.averageLikes ?? 0) - (Yourself?.averageLikes ?? 0))]
		}
	}
	var stats: [Stat]!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stats.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "StatisticCell")!
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}
	
	@IBOutlet weak var shelf: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
        // Do any additional setup after loading the view.
    }

}
