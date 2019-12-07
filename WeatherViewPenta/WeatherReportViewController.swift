//
//  WeatherReportViewController.swift
//  WeatherViewNabd
//
//  Created by Waveline Media on 9/3/18.
//  Copyright © 2018 Waveline Media. All rights reserved.
//

import UIKit
import SDWebImage

class WeatherReportViewController: UIViewController {
    
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var otherWeatherDetails: UILabel!
    @IBOutlet weak var temperatureRange: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureDescription: UILabel!
    @IBOutlet weak var arabiaLink: UIButton!
    @IBOutlet weak var arabiaLinkIcon: UIButton!
    @IBOutlet weak var weatherProviderLogo: UIImageView!
    @IBOutlet weak var weatherProviderText: UILabel!
    
    @IBOutlet weak var mainWeatherViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainWeatherViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var weatherCollection: UICollectionView!
    @IBOutlet weak var weatherTable: UITableView!
    
    @IBOutlet var lineViews: [UIView]!
    
    let tableRowHeight: CGFloat = 55.0
    
    var weatherDetails: Weather!
    var dailyReport: [dailyWeatherReport] = []
    var hourlyReport: [Weather.hourlyWeatherReport] = []
    
    var isEnglish = true
    var theme: Theme!
    
    @IBAction func goToArabiaWeather(_ sender: UIButton) {
        
        guard let weatherProviderUrl = URL(string: "http://en.arabiaweather.com") else { return }
        
        if #available(iOS 10, *) { // For ios 10 and greater
            UIApplication.shared.open(weatherProviderUrl, options: [:], completionHandler: nil)
        } else { // for below ios 10.
            let _ = UIApplication.shared.openURL(weatherProviderUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Config on loading view
        mainWeatherViewWidth.constant = self.view.frame.width
        mainWeatherViewHeight.constant -= weatherTable.frame.height
        arabiaLinkIcon.imageView?.contentMode = .scaleAspectFit
        
        dailyReport = weatherDetails.daily
        let thursdayDetails: [String: Any] = ["date": "2019-12-13",
                                "tempMin": 15.53,
                                "tempMax": 24.98,
                                "maxStatusIdIcon": [
                                    "w": "http://weather-statuses.devops.arabiaweather.com/nabd/white/18p.png",
                                    "c": "http://weather-statuses.devops.arabiaweather.com/nabd/colored/18p.png"
                                ],
                                "maxStatusEn": "Chance for Thunderstorms",
                                "maxStatusAr": "احتمال زخات رعدية من المطر"
                            ]
        let thursday = dailyWeatherReport(details: thursdayDetails)
        let fridayDetails: [String: Any] = ["date": "2019-12-14",
                                "tempMin": 15.53,
                                "tempMax": 24.98,
                                "maxStatusIdIcon": [
                                    "w": "http://weather-statuses.devops.arabiaweather.com/nabd/white/18p.png",
                                    "c": "http://weather-statuses.devops.arabiaweather.com/nabd/colored/18p.png"
                                ],
                                "maxStatusEn": "Chance for Thunderstorms",
                                "maxStatusAr": "احتمال زخات رعدية من المطر"
                            ]
        let friday = dailyWeatherReport(details: fridayDetails)
        dailyReport.append(thursday)
        dailyReport.append(friday)
        hourlyReport = weatherDetails.hourly
        setupView()
    }
    
    /* Display Config */
    func setupView() {
        
        let providerUrl = URL(string: "http://54.83.19.243/arabia_weather_logo.png")
        weatherProviderLogo.sd_setImage(with: providerUrl, completed: nil)
        
        guard let currentValues = weatherDetails.current else { return }
        
        guard let currentDayObj = weatherDetails.daily.first else { return }
        
        theme = ThemeManager().getCurrentTheme(currentValues.isDay)
        
        self.view.backgroundColor = theme.rawValue == 0 ? DayTheme().mainBackgroundColor() : NightTheme().mainBackgroundColor()
        
        let locationColor = theme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        cityName.text = weatherDetails.geoLocation?.city
        cityName.textColor = locationColor
        locationIcon.tintColor = locationColor
        
        let linkColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        arabiaLink.titleLabel?.textColor = linkColor
        arabiaLinkIcon.tintColor = linkColor
        
        weatherProviderText.textColor = theme.rawValue == 0 ? DayTheme().weatherProviderLogoColor() : NightTheme().weatherProviderLogoColor()
        
        temperature.text = "\(Int(currentValues.temperature ?? 0.0))°"
        temperature.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        let primaryColor = theme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        let secondaryColor = theme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        
        let attrString = NSMutableAttributedString(string: "Humidity: ", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        let stringTwo = NSAttributedString(string: " \(currentValues.humidity ?? 0) | ", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        attrString.append(stringTwo)
        let stringThree = NSAttributedString(string: "Wind speed: ", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        attrString.append(stringThree)
        let stringFour = NSAttributedString(string: " \(currentValues.windSpeed ?? 0) km/h", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        attrString.append(stringFour)
        
        otherWeatherDetails.attributedText = attrString
        
        temperatureRange.text = "\(Int(currentDayObj.minTemp ?? 0.0))° | \(Int(currentDayObj.maxTemp ?? 0.0))°"
        temperatureRange.textColor = secondaryColor
        
        temperatureDescription.text = isEnglish ? currentValues.currentStatus.eng : currentValues.currentStatus.ar
        temperatureDescription.textColor = primaryColor
        
        let imageUrl: URL = theme.rawValue == 0 ? currentValues.icons.color : currentValues.icons.white
        weatherIcon.sd_setImage(with: imageUrl, completed: nil)
        
        dateTime.text = DateHelper().getFormattedDateString(dateValue: Date(), format: "E, d MMM yyyy HH:mm:ss", isDay: weatherDetails.current?.isDay ?? true)
        dateTime.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        weatherCollection.reloadData()
        weatherTable.reloadData()
        mainWeatherViewHeight.constant += tableRowHeight * CGFloat(dailyReport.count)
        tableHeight.constant = tableRowHeight * CGFloat(dailyReport.count)
        
        if mainWeatherViewHeight.constant < self.view.frame.height - 60.0 {
            mainWeatherViewHeight.constant = self.view.frame.height - 60.0
        }
    }
    
    //Helper functions
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        var safeArea: CGFloat = 0
        
        if #available(iOS 11.0, *), UIDevice.current.orientation.isLandscape {
            let insets = UIApplication.shared.keyWindow?.safeAreaInsets
            safeArea = (insets?.top ?? 0) + (insets?.bottom ?? 0)
            safeArea += safeArea > 0 ? 10.0 : 0.0
        }
        mainWeatherViewWidth.constant = size.width - safeArea
    }
}

/* Collection view Config */
extension WeatherReportViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyReport.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourCell", for: indexPath) as! WeatherCollectionViewCell
        
        cell.isCurrent = indexPath.item == 0
        cell.configureCell(hourlyDetails: hourlyReport[indexPath.item])
        
        return cell
    }
}

extension WeatherReportViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 140)
    }
}

/* Table view Config */
extension WeatherReportViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyReport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell") as! WeatherTableViewCell
        
        cell.configureCell(dailyDetails: dailyReport[indexPath.row], index: indexPath.row)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

extension WeatherReportViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowHeight
    }
}

/* CollectionView Cell */
class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hour: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    var isCurrent = false
    var isDay = false
    var lowestTemp: Int!
    
    func configureCell(hourlyDetails: Weather.hourlyWeatherReport) {
        
        let currentTheme = ThemeManager().getCurrentTheme(isDay)
        let primaryColor = currentTheme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        
        hour.text = isCurrent ? "Now" : DateHelper().getFormattedDateString(dateValue: hourlyDetails.localDate, format: "ha", isDay: false).lowercased()
        hour.font = isCurrent ? UIFont.boldHelvetica(size: 17.0) : UIFont.regularHelvetica(size: 17.0)
        hour.textColor = primaryColor
        
        temperature.text = "\(Int(hourlyDetails.temperature ?? 0.0))°"
//        |\(lowestTemp ?? 0)°
        temperature.textColor = primaryColor
        temperature.font = isCurrent ? UIFont.boldHelvetica(size: 15.0) : UIFont.regularHelvetica(size: 15.0)
        
        let backgroundColor = currentTheme.rawValue == 0 ? DayTheme().weatherHighlightBackgroundColor() : NightTheme().weatherHighlightBackgroundColor()
        
        bgView.backgroundColor = isCurrent ?
            backgroundColor : UIColor.clear
        
        let imageUrl: URL = currentTheme.rawValue == 0 ? hourlyDetails.icons.color : hourlyDetails.icons.white
        weatherIcon.sd_setImage(with: imageUrl, completed: nil)
    }
}

/* TableView Cell */
class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var temperatureRange: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    let isDay = false
    
    func configureCell(dailyDetails:
        dailyWeatherReport, index: Int) {
        
        let currentTheme = ThemeManager().getCurrentTheme(isDay)
        let dayInWeek = DateHelper().getFormattedDateString(dateValue: dailyDetails.date, format: "EEEE", isDay: true)
        day.text = dayInWeek
        day.textColor = currentTheme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        
        let lightColor = currentTheme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextLightColor()
        let attrString = NSMutableAttributedString(string: "\(Int(dailyDetails.minTemp ?? 0.0))° | ", attributes: [NSAttributedStringKey.foregroundColor: lightColor ?? UIColor.black])
        
        let darkColor = currentTheme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        let remString = NSAttributedString(string: "\(Int(dailyDetails.maxTemp ?? 0.0))°", attributes: [NSAttributedStringKey.foregroundColor: darkColor ?? UIColor.black])
        attrString.append(remString)
        
        temperatureRange.attributedText = attrString
        
        let imageUrl: URL = currentTheme.rawValue == 0 ? dailyDetails.icons.color : dailyDetails.icons.white
        weatherIcon.sd_setImage(with: imageUrl, completed: nil)
    }
    
    func getDayNameArabic(date: Date) -> String {
        
        let dayInWeek = DateHelper().getFormattedDateString(dateValue: date, format: "EEEE", isDay: true)
        
        switch dayInWeek.lowercased() {
        case "saturday":
            return "السبت"
        case "sunday":
            return "الأحد"
        case "monday":
            return "الأثنين"
        case "tuesday":
            return "الثلاثاء"
        case "wednesday":
            return "الأربعاء"
        case "thursday":
            return "الخميس"
        case "friday":
            return "الجمعة"
        default:
            return ""
        }
    }
}

/* Font Helper */
extension UIFont {
    open class func regularHelvetica(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeueLTArabic-Roman2", size: size)!
    }
    open class func boldHelvetica(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeueLTArabic-Boldd", size: size)!
    }
}
