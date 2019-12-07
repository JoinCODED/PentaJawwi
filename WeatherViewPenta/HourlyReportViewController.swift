//
//  HourlyReportViewController.swift
//  WeatherViewNabd
//
//  Created by Midhet Sulemani on 12/6/19.
//  Copyright © 2019 Waveline Media. All rights reserved.
//

import UIKit

class HourlyReportViewController: UIViewController {
    
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureRange: UILabel!
    @IBOutlet weak var humidDetail: UILabel!
    @IBOutlet weak var windDetail: UILabel!
    @IBOutlet weak var otherWeatherDetails: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherProviderLogo: UIImageView!
    @IBOutlet weak var weatherProviderText: UILabel!
    
    @IBOutlet weak var weatherCollection: UICollectionView!
    
    @IBOutlet var lineViews: [UIView]!
    
    var weatherDetails: Weather!
    var hourlyReport: [Weather.hourlyWeatherReport] = []
    
    var isEnglish = false
    var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyReport = stripElements(in: weatherDetails.hourly)
        setupView()
    }
    
    func stripElements<T>(in array:[T]) -> [T] {
        return array.enumerated().filter { (arg0) -> Bool in
            let (offset, _) = arg0
            return offset % 2 != 0
        }.map { $0.element }
    }
    
    /* Display Config */
    func setupView() {
        
        let providerUrl = URL(string: "http://54.83.19.243/arabia_weather_logo.png")
        weatherProviderLogo.sd_setImage(with: providerUrl, completed: nil)
        
        guard let currentValues = weatherDetails.current else { return }
        
        guard let currentDayObj = weatherDetails.daily.first else { return }
        
        theme = ThemeManager().getCurrentTheme(currentValues.isDay)
        
        let backgroundColor = theme.rawValue == 0 ? DayTheme().weatherHighlightBackgroundColor() : NightTheme().weatherHighlightBackgroundColor()
        
        self.view.backgroundColor = backgroundColor
        
        let locationColor = theme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        cityName.text = weatherDetails.geoLocation?.city
        cityName.textColor = locationColor
        locationIcon.tintColor = locationColor
        
        let linkColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        for line in lineViews {
            line.backgroundColor = linkColor
        }
        
        weatherProviderText.textColor = theme.rawValue == 0 ? DayTheme().weatherProviderLogoColor() : NightTheme().weatherProviderLogoColor()
        
        temperature.text = "\(Int(currentValues.temperature ?? 0.0))°"
        temperature.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        let primaryColor = theme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        let secondaryColor = theme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        
        let attrString = NSMutableAttributedString(string: "Humidity:", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        let stringTwo = NSAttributedString(string: " \(currentValues.humidity ?? 0)", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        attrString.append(stringTwo)
        let stringThree = NSMutableAttributedString(string: "Wind speed:", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        let stringFour = NSAttributedString(string: " \(currentValues.windSpeed ?? 0) km/h", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        stringThree.append(stringFour)
        
        humidDetail.attributedText = attrString
        windDetail.attributedText = stringThree
        
        otherWeatherDetails.text = currentValues.currentStatus.eng
        otherWeatherDetails.textColor = primaryColor
        
        temperatureRange.text = "\(Int(currentDayObj.maxTemp ?? 0.0))° | \(Int(currentDayObj.minTemp ?? 0.0))°"
        temperatureRange.textColor = secondaryColor
        
        dateAndTime.text = DateHelper().getFormattedDateString(dateValue: Date(), format: "E, d MMM yyyy HH:mm:ss", isDay: weatherDetails.current?.isDay ?? true)
        dateAndTime.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        let imageUrl: URL = theme.rawValue == 0 ? currentValues.icons.color : currentValues.icons.white
        weatherIcon.sd_setImage(with: imageUrl, completed: nil)
        
        weatherCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let hourVC = segue.destination as? WeatherReportViewController {
            hourVC.weatherDetails = self.weatherDetails
        }
    }

}

/* Collection view Config */
extension HourlyReportViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyReport.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as? WeatherCollectionViewCell {
            cell.isCurrent = indexPath.item == 0
            cell.isDay = weatherDetails.current?.isDay ?? true
            if let currentDayObj = weatherDetails.daily.first {
                cell.lowestTemp = Int(currentDayObj.minTemp)
            }
            cell.configureCell(hourlyDetails: hourlyReport[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
}

extension HourlyReportViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 140)
    }
}
