//
//  GeolocationTools.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

// Structure for zipcode data
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
// convert ZipCodeData class object to JSON value. this func we need to store userdefault value
func serializeZipcodeData(zipCodeData: ZipCodeData) -> [String: AnyObject] {
    
    let finalSerialize = ["zip_code":zipCodeData.zipCode as String,
                                "lat":zipCodeData.geo_latitude as Double,
                                "lng":zipCodeData.geo_longitude as Double,
                                "city":zipCodeData.cityName as String,
                                "state":zipCodeData.state as String] as [String: AnyObject]
    
    return finalSerialize
}
// convert zipCodeRadius class object to JSON value. this func we need to store userdefault value
func serializeRadiusData(zipCodeRadius: zipCodeRadius) -> [String:AnyObject] {
    
    let finalSerialize = ["zipCode":zipCodeRadius.zipCode as String,
                                "radius":zipCodeRadius.radius as Int,
                                "results":zipCodeRadius.results as [String:Double]] as [String: AnyObject]
    
    return finalSerialize
}

var zipCodeDic: [String: ZipCodeData] = [:]

var ZipCodeAPIKey: String?

/// Fetch ZipCodeAPIKey from Firebase. we can dynamically change this ID as per requirement
/// - Parameter completed: Callback with empty params
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

//Uses zip code API to get all zip codes in a certain radius. before API call we are checking userdefault values for same zipCoderadius value
func GetAllZipCodesInRadius(zipCode: String, radiusInMiles: Int, completed:((_ zipCodeDistances: [String: Double]?, _ zipCode: String, _ radiusInMiles: Int) -> () )?) {

	
	if zipCode.count < 3 {
		return
	}
    
    // check local cache values here
    if let radiusDataArray = UserDefaults.standard.object(forKey: "searchradius") as? NSData {
    
        do {
            let radiusDataArray1 = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSObject.self], from: radiusDataArray as Data)
            let storedData = radiusDataArray1 as! [[String:AnyObject]]
            zipCodeRadiusDic = []
            for data in storedData {
                zipCodeRadiusDic.append(zipCodeRadius.init(zipCode: data["zipCode"] as! String, radius: data["radius"] as! Int, results: data["results"] as! [String : Double]))
            }
        }catch {
            print("User creation failed with error: \(error)")
            
        }
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
                        
                        // check local cache values here
                        if let radiusDataArray = UserDefaults.standard.object(forKey: "searchradius") as? NSData {
                        do {
                            let radiusDataArray1 = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self], from : radiusDataArray as Data)
                            let storedData = radiusDataArray1 as! [[String:AnyObject]]
                            zipCodeRadiusDic = []
                            for data in storedData {
                                zipCodeRadiusDic.append(zipCodeRadius.init(zipCode: data["zipCode"] as! String, radius: data["radius"] as! Int, results: data["results"] as! [String : Double]))
                            }
                            zipCodeRadiusDic.append(zipCodeRadius(zipCode: zipCode, radius: radiusInMiles, results: distances))
                            
                            
                            var finalData:[[String:AnyObject]] = [[String:AnyObject]]()
                            for data in zipCodeRadiusDic {
                                finalData.append(serializeRadiusData(zipCodeRadius: data))
                            }

                            // store local cache values here
                            let placesData = try NSKeyedArchiver.archivedData(withRootObject: finalData as NSArray, requiringSecureCoding: false)
                            UserDefaults.standard.set(placesData, forKey: "searchradius")
                                
                            DispatchQueue.main.async {
                                completed?(distances, zipCode, radiusInMiles)
                            }

                        }catch {
                            print("Couldn't write file")
                        }
                        }else{
                            zipCodeRadiusDic.append(zipCodeRadius(zipCode: zipCode, radius: radiusInMiles, results: distances))

                            
                            var finalData:[[String:AnyObject]] = [[String:AnyObject]]()
                            for data in zipCodeRadiusDic {
                                finalData.append(serializeRadiusData(zipCodeRadius: data))
                            }

                            // store local cache values here
                            let placesData = try NSKeyedArchiver.archivedData(withRootObject: finalData, requiringSecureCoding: false)
                            UserDefaults.standard.set(placesData, forKey: "searchradius")
                                
                            DispatchQueue.main.async {
                                completed?(distances, zipCode, radiusInMiles)
                            }
                            
                        }

                        
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}.resume()
	}
	
	//
}

/// Get zipcode information if already saved in local cache or from third party API
/// - Parameters:
///   - zipCode: Sends zipcode
///   - completed: Callback with zipcode details and zipcode
/// - Returns: Empty
func GetTownName(zipCode: String, completed: @escaping (_ zipCodeInfo: ZipCodeData?, _ zipCode: String) -> () ) {
    
    // check local cache values here
    if let placesDataArray = UserDefaults.standard.object(forKey: "searchplaces") as? NSData {
    
    do {
        let placesArray1 = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self], from: placesDataArray as Data)
        let storedData = placesArray1 as! [String : [String:Any]]
        for zipcodeKey in storedData.keys {
            zipCodeDic[zipcodeKey] = ZipCodeData.init(dictionary: storedData[zipcodeKey]! as [String : AnyObject])
        }
    }catch {
        print("Couldn't write file")
    }
    }

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
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if zipCodeData["error_code"] == nil {
								cityState = ZipCodeData.init(dictionary: zipCodeData)
							}
						}
//						DispatchQueue.main.async {
							if let cityState = cityState {
                            zipCodeDic[zipCode] = cityState
                                // check local cache values here
                                if let placesDataArray = UserDefaults.standard.object(forKey: "searchplaces") as? NSData {
                                do {
                                    let placesArray1 = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self], from : placesDataArray as Data)
                                    var storedData = placesArray1 as! [String : [String:AnyObject]]
                                    storedData[zipCode] = serializeZipcodeData(zipCodeData: zipCodeDic[zipCode]!)
                                    // store local cache values here
                                    let placesData = try NSKeyedArchiver.archivedData(withRootObject: storedData, requiringSecureCoding: false)
                                    UserDefaults.standard.set(placesData, forKey: "searchplaces")
                                        
                                    DispatchQueue.main.async {
                                        completed(cityState, zipCode)
                                    }

                                }catch {
                                    print("Couldn't write file")
                                }
                                }else{
                                    // store local cache values here
                                    let storedData = [zipCode:serializeZipcodeData(zipCodeData: zipCodeDic[zipCode]!)] as [String:[String:AnyObject]]
                                    let placesData = try NSKeyedArchiver.archivedData(withRootObject: storedData, requiringSecureCoding: false)
                                    UserDefaults.standard.set(placesData, forKey: "searchplaces")
                                        
                                    DispatchQueue.main.async {
                                        completed(cityState, zipCode)
                                    }
                                    
                                }
                                
                               
                            }else{
                                completed(nil, zipCode)
                            }
                            
//						}
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
