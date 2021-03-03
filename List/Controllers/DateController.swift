//
//  DateController.swift
//  Giftd
//
//  Created by Miles Broomfield on 19/02/2021.
//

import Foundation
import UIKit

class DateHandler{
    static let shared = DateHandler()
    
    let formatter = DateFormatter()
    
    func shortForDate(date:Date) -> String{
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    func longForDate(date:Date) -> String{
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "MM/dd/yy @ HH:mm"
        return formatter.string(from: date)
    }
    
    func timeForDate(date:Date) -> String{
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
