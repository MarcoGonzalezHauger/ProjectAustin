//
//  GeolocationTools.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

struct ZipCodeData {
	let zipCode: String
	let geo_latitude: Double
	let geo_longitude: Double
	let cityName: String
	let state: String
	var CityAndStateName: String {
		get {
			return cityName + ", " + state
		}
	}
	init(dictionary: [String: AnyObject]) {
		zipCode = dictionary["zip_code"] as! String
		geo_latitude = dictionary["lat"] as! Double
		geo_longitude = dictionary["lng"] as! Double
		cityName = dictionary["city"] as! String
		state = dictionary["state"] as! String
	}
}

var zipCodeDic: [String: ZipCodeData] = [:]

var ZipCodeAPIKey: String?

func InitializeZipCodeAPI(completed: (() -> Void)?) {
	let ref = Database.database().reference().child("Admin").child("ZipCodeAPIKey")
	ref.observeSingleEvent(of: .value) { (Snapshot) in
		if let apikey: String = Snapshot.value as? String {
			ZipCodeAPIKey = apikey
			if let comp = completed {
				comp()
			}
		}
	}
}

//This struct is used for easy caching of Zip Code Radiuses.
struct zipCodeRadius {
	let zipCode: String
	let radius: Int
	let results: [String: Double]
}

//used throughout Ambassadoor to locate social page influencers in a certain radius
//ex. if it's 0, it will only display innfluencers on the social page in your own zip code.
let socialPageMileRadius: Int = 10

var zipCodeRadiusDic: [zipCodeRadius] = []

//Used in Classic Sort algorithms for the social page.
func GetSocialZipDistances() -> [String: Double] {
	for zcr in zipCodeRadiusDic {
		if zcr.zipCode == (Yourself.zipCode ?? "0") && zcr.radius == socialPageMileRadius {
			return zcr.results
		}
	}
	return [Yourself.zipCode ?? "0": 0]
}

//Uses zip code API to get all zip codes in a certain radius.
func GetAllZipCodesInRadius(zipCode: String, radiusInMiles: Int, completed:((_ zipCodeDistances: [String: Double]?, _ zipCode: String, _ radiusInMiles: Int) -> () )?) {
	
	if zipCode.count < 3 {
		return
	}
	
	//zcr stands for Zip Code Radius (struct)
	for zcr in zipCodeRadiusDic {
		if zcr.zipCode == zipCode && zcr.radius == radiusInMiles {
			completed?(zcr.results, zipCode, radiusInMiles)
			return
		}
	}
	
	if radiusInMiles == 0 {
		completed?([zipCode: 0], zipCode, radiusInMiles)
		return
	}

	if let APIKey: String = ZipCodeAPIKey {
		guard let url = URL(string: "https://www.zipcodeapi.com/rest/\(APIKey)/radius.json/\(zipCode)/\(radiusInMiles)/mile") else {
			completed?(nil, zipCode, radiusInMiles)
			return
		}
		
		var distances: [String: Double] = [:]
		
		URLSession.shared.dataTask(with: url) { (data, response, err) in
			if err == nil {
				guard let jsondata = data else { return }
				do {
					do {
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if zipCodeData["error_code"] == nil {
								if let data = zipCodeData["zip_codes"] as? [AnyObject] {
									for zipInfo in data {
										if let zipdata = zipInfo as? [String: AnyObject] {
											distances[zipdata["zip_code"] as! String] = zipdata["distance"] as? Double
										}
									}
								}
							}
						}
						completed?(distances, zipCode, radiusInMiles)
						zipCodeRadiusDic.append(zipCodeRadius(zipCode: zipCode, radius: radiusInMiles, results: distances))
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}.resume()
	}
	
	//
}

func GetTownName(zipCode: String, completed: @escaping (_ zipCodeInfo: ZipCodeData?, _ zipCode: String) -> () ) {

	if let zcd = zipCodeDic[zipCode] {
		completed(zcd, zipCode)
		return
	}
	
	if zipCode.count < 3 {
		return
	}
	
	if let APIKey: String = ZipCodeAPIKey {
		guard let url = URL(string: "https://www.zipcodeapi.com/rest/\(APIKey)/info.json/\(zipCode)/degrees") else {
			completed(nil, zipCode)
			return
		}
		var cityState: ZipCodeData?
		URLSession.shared.dataTask(with: url){ (data, response, err) in
			if err == nil {
				// check if JSON data is downloaded yet
				guard let jsondata = data else { return }
				do {
					do {
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if zipCodeData["error_code"] == nil {
								cityState = ZipCodeData.init(dictionary: zipCodeData)
							}
						}
						DispatchQueue.main.async {
							if let cityState = cityState {
								zipCodeDic[zipCode] = cityState
								completed(cityState, zipCode)
							}
						}
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}.resume()
	} else {
		InitializeZipCodeAPI {
			GetTownName(zipCode: zipCode, completed: completed)
		}
	}
}
