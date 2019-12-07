//
//  LocationsViewController.swift
//  WeatherViewNabd
//
//  Created by Midhet Sulemani on 12/7/19.
//  Copyright © 2019 Waveline Media. All rights reserved.
//

import UIKit
import SDWebImage

protocol LocationUpdateProtocol: class {
    func addLocation(location: LocationModel)
}

class LocationsViewController: UIViewController {
    
    @IBOutlet weak var weatherTable: UITableView!
    
    var allLocations: [LocationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weatherTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchVC = segue.destination as? SearchNewCountryViewController {
            searchVC.refreshDelegate = self
        }
    }
}

extension LocationsViewController: LocationUpdateProtocol {
    func addLocation(location: LocationModel) {
        allLocations.append(location)
        weatherTable.reloadData()
    }
}

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? LocationTableCell {
            cell.configure(locationDetails: allLocations[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

class LocationModel {
    var city: String!
    var country: String!
    var dateDetails: String!
    var mainTemp: Double!
    var minTemp: Double!
    var maxTemp: Double!
    var weather: String!
    var weatherIconUrlStr: String!
    
    convenience init(details: [String: Any]) {
        self.init()
        
        city = details["name"] as? String
        
        if let systemDetails = details["sys"] as? [String: Any] {
            country = systemDetails["country"] as? String
        }
        
        if let mainDetails = details["main"] as? [String: Any] {
            mainTemp = mainDetails["temp"] as? Double
            minTemp = mainDetails["temp_min"] as? Double
            maxTemp = mainDetails["temp_max"] as? Double
        }
        
        if let weatherDetailsList = details["weather"] as? [[String: Any]], let weatherDetails = weatherDetailsList.first {
            weather = weatherDetails["main"] as? String
            weatherIconUrlStr = "http://openweathermap.org/img/w/\(weatherDetails["icon"] as? String ?? "").png"
        }
        
        dateDetails = DateHelper().getFormattedDateString(dateValue: Date(), format: "E, d MMM yyyy", isDay: false)
    }
}

class LocationTableCell: UITableViewCell {
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var dateDeets: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureRange: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var isDay = false
    
    func configure(locationDetails: LocationModel) {
        locationName.text = "\(locationDetails.city ?? ""), \(locationDetails.country ?? "")"
        dateDeets.text = locationDetails.dateDetails
        temperature.text = "\(Int(locationDetails.mainTemp))F"
        weatherDesc.text = locationDetails.weather
        if let weatherIconUrl = URL(string: locationDetails.weatherIconUrlStr) {
            weatherIcon.sd_setImage(with: weatherIconUrl, completed: nil)
        }
        
        if locationDetails.weather.lowercased().contains("thunder") {
            let imageToSet = isDay ? "thunderDay" : "thunderNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else if locationDetails.weather.lowercased().contains("rain") {
            let imageToSet = isDay ? "rainyDay" : "rainyNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else if locationDetails.weather.lowercased().contains("cloud") {
            let imageToSet = isDay ? "cloudy" : "cloudyNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else if locationDetails.weather.lowercased().contains("snow") {
            let imageToSet = isDay ? "snowDay" : "snowNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else {
            let imageToSet = isDay ? "sunny" : "clearNight"
            backgroundImage.image = UIImage(named: imageToSet)
        }
        
        let currentTheme = ThemeManager().getCurrentTheme(isDay)
        dateDeets.textColor = currentTheme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        
        let lightColor = currentTheme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        let attrString = NSMutableAttributedString(string: "\(Int(locationDetails.minTemp ?? 0.0))° | ", attributes: [NSAttributedStringKey.foregroundColor: lightColor ?? UIColor.black])
        
        let darkColor = currentTheme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        let remString = NSAttributedString(string: "\(Int(locationDetails.maxTemp ?? 0.0))°", attributes: [NSAttributedStringKey.foregroundColor: darkColor ?? UIColor.black])
        attrString.append(remString)
        
        temperatureRange.attributedText = attrString
        
        
        let primaryColor = currentTheme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        
        locationName.font = UIFont.boldHelvetica(size: 17.0)
        locationName.textColor = primaryColor
        
        
        temperature.textColor = primaryColor
        temperature.font = UIFont.regularHelvetica(size: 15.0)
        
        weatherDesc.textColor = primaryColor
        weatherDesc.font = UIFont.regularHelvetica(size: 15.0)
                
        let backgroundColor = currentTheme.rawValue == 0 ? DayTheme().weatherHighlightBackgroundColor() : NightTheme().weatherHighlightBackgroundColor()
                
        backgroundView?.backgroundColor = backgroundColor
    }
}
