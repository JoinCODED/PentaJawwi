//
//  WeatherModel.swift
//  WeatherViewNabd
//
//  Created by Waveline Media on 9/2/18.
//  Copyright © 2018 Waveline Media. All rights reserved.
//

import Foundation

class Weather {
    
    //Structures for Components
    struct hourlyWeatherReport {
        var temperature: Double!
        var icons: statusIcons!
        var wind: Double!
        var localDate: Date!
        
        init(details: [String: Any]) {
            temperature = details["temp"] as? Double
            icons = statusIcons(details: details["icon"] as? [String: Any] ?? [:])
            wind = details["windDir"] as? Double
            localDate = DateHelper().getDateFromString(dateString: details["localTime"] as? String ?? "", format: "yyyy-MM-dd'T'HH:mm:ssZ", isDay: false)
        }
    }
    
    struct currentWeatherReport {
        var currentStatus: status = status()
        var temperature: Double!
        var icons: statusIcons!
        var windSpeed: Double!
        var humidity: Double!
        var isDay: Bool!
        
        init(details: [String: Any]) {
            temperature = details["temp"] as? Double
            currentStatus.ar = details["statusAr"] as? String
            currentStatus.eng = details["statusEn"] as? String
            icons = statusIcons(details: details["icon"] as? [String: Any] ?? [:])
            if let speed = details["windSpeed"] as? Double {
                windSpeed = speed * 3.6
                windSpeed = Double(round(100*windSpeed)/100)
            }
            humidity = details["relHumid"] as? Double
            isDay = details["isDay"] as? Bool ?? true
        }
    }
    
    struct location {
        var city: String!
        
        init(details: [String: Any]) {
            
            let obj = details["location"] as? [String: Any] ?? [:]
            city = obj["nameEn"] as? String
        }
    }
    
    //Variables
    var daily: [dailyWeatherReport] = []
    var hourly: [hourlyWeatherReport] = []
    var current: currentWeatherReport?
    var geoLocation: location?
    
    //Initialisation from dictionary to data model
    init(data: [String: Any]) {
        
        let dailyReport = data["daily"] as? [[String: Any]] ?? []
        daily = dailyReport.map({
            return dailyWeatherReport(details: $0)
        }).filter({
            return (Calendar.current.dateComponents([.day], from: Date(), to: $0.date).day ?? 0) >= 0 && getDayInWeek(date: Date()).lowercased() != getDayInWeek(date: $0.date).lowercased()
        })
        
        let hourlyReport = data["hourly"] as? [[String: Any]] ?? []
        hourly = hourlyReport.map({ hourlyWeatherReport(details: $0) }).filter({
            let diff = Calendar.current.dateComponents([.hour], from: Date(), to: $0.localDate).hour ?? 0
            return diff < 24 && diff >= 0
        })
        current = currentWeatherReport(details: data["now"] as? [String: Any] ?? [:])
        
        geoLocation = location(details: data["geoLocation"] as? [String: Any] ?? [:])
    }
    
    //Helper functions
    func getDayInWeek(date: Date) -> String {
        return DateHelper().getFormattedDateString(dateValue: date, format: "EEEE", isDay: true)
    }
}

struct status {
    var eng: String!
    var ar: String!
}

struct statusIcons {
    var white: URL!
    var color: URL!
    
    init(details: [String: Any]) {
        white = URL(string: details["w"] as? String ?? "")
        color = URL(string: details["c"] as? String ?? "")
    }
}

struct dailyWeatherReport {
    var date: Date!
    var minTemp: Double!
    var maxTemp: Double!
    var maxStatus: status = status()
    var icons: statusIcons!
    
    init(details: [String: Any]) {
        date = DateHelper().getDateFromString(dateString: details["date"] as? String ?? "", format: "yyyy-MM-dd", isDay: true) ?? Date()
        minTemp = details["tempMin"] as? Double ?? 0.0
        maxTemp = details["tempMax"] as? Double ?? 0.0
        maxStatus.ar = details["maxStatusAr"] as? String ?? ""
        maxStatus.eng = details["maxStatusEn"] as? String ?? ""
        icons = statusIcons(details: details["maxStatusIdIcon"] as? [String: Any] ?? [:])
    }
}
