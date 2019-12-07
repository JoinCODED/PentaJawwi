//
//  Dates.swift
//  WeatherViewNabd
//
//  Created by Waveline Media on 9/4/18.
//  Copyright © 2018 Waveline Media. All rights reserved.
//

import Foundation
import UIKit

class DateHelper {
    
    private let formatter = DateFormatter()
    
    func getFormattedDateString(dateValue: Date, format: String, isDay: Bool) -> String {
        formatter.dateFormat = format
        if isDay {
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return formatter.string(from: dateValue)
    }
    
    func getDateFromString(dateString: String, format: String, isDay: Bool) -> Date? {
        if isDay {
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
        }
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
}
