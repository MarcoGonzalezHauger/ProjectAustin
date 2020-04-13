//
//  DateExtension.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    
    //add days
    func afterDays(day:Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: noon)!
    }
    
    //add 60 minutes
    func addMinutes(minute:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minute, to: self)!
    }
    //deduct three months
    func deductMonths(month:Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self)!
    }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    static func getCurrentDate() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
        
        return dateFormatter.string(from: Date())
        
    }
    
    static func getDateFromString(date:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
        
        return dateFormatter.date(from: date) // replace Date String
    }
    
    static func getStringFromDate(date:Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
        //        dateFormatter.timeZone = TimeZone.current
        //        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date) // replace Date String
    }
    //"yyyy/MMM/dd HH:mm:ss"
    static func getStringFromSecondDate(date:Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        //        dateFormatter.timeZone = TimeZone.current
        //        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date) // replace Date String
    }
    
    static func getDateFromISO8601DateString(ISO8601String: String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:ISO8601String)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let finalDate = calendar.date(from:components)
        return finalDate!
        
    }
    
//    static func getDateISO8601Format() -> Date{
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        let date = dateFormatter.da
//    }
    
    static func getmonthsBetweenDate(startDate:Date,endDate:Date) -> Int{
        let calendar = Calendar.current

        let components = calendar.dateComponents([.month], from: startDate, to: endDate)

        return components.month!
    }
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
