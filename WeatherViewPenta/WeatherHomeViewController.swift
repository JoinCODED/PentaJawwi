//
//  WeatherHomeViewController.swift
//  WeatherViewNabd
//
//  Created by Midhet Sulemani on 12/6/19.
//  Copyright © 2019 Waveline Media. All rights reserved.
//

import UIKit

class WeatherHomeViewController: UIViewController {
    
    @IBOutlet weak var mainTemp: UILabel!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var tempImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var rainDetails: UILabel!
    @IBOutlet weak var humidityDetails: UILabel!
    @IBOutlet weak var windDetails: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var temperatureRange: UILabel!
    @IBOutlet weak var weatherProviderLogo: UIImageView!
    @IBOutlet weak var weatherProviderText: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var weatherDetails: Weather!
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
        
        callService()
    }
    
    func callService() {
//        loader.startAnimating()
//        loader.isHidden = false
        Webservice().fetchWeather {[weak self] (details, error) in
            
            guard let _ = self else { return }
            DispatchQueue.main.async {
//                self?.loader.stopAnimating()
//                self?.loader.isHidden = true
                
                if let details = details {
                    self?.weatherDetails = Weather(data: details)
                    self?.setupView()
                }
                else {
                    let alert = UIAlertController(title: "Error", message: error?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
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
        location.text = weatherDetails.geoLocation?.city
        location.textColor = locationColor
        locationIcon.tintColor = locationColor
        
        weatherProviderText.textColor = theme.rawValue == 0 ? DayTheme().weatherProviderLogoColor() : NightTheme().weatherProviderLogoColor()
        
        mainTemp.text = "\(Int(currentValues.temperature ?? 0.0))°"
        mainTemp.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        dateAndTime.text = DateHelper().getFormattedDateString(dateValue: Date(), format: "E, d MMM yyyy HH:mm:ss", isDay: weatherDetails.current?.isDay ?? true)
        dateAndTime.textColor = theme.rawValue == 0 ? DayTheme().weatherTextDarkColor() : NightTheme().weatherTextDarkColor()
        
        let primaryColor = theme.rawValue == 0 ? DayTheme().weatherPrimaryTextColor() : NightTheme().weatherPrimaryTextColor()
        let secondaryColor = theme.rawValue == 0 ? DayTheme().weatherTextLightColor() : NightTheme().weatherTextDarkColor()
        
        let attrString = NSMutableAttributedString(string: "Humidity: ", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        let humidityStr = NSAttributedString(string: "\(currentValues.humidity ?? 0)", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        attrString.append(humidityStr)
        let stringThree = NSMutableAttributedString(string: "Wind speed: ", attributes: [NSAttributedStringKey.foregroundColor: primaryColor ?? UIColor.black])
        let stringFour = NSAttributedString(string: "\(currentValues.windSpeed ?? 0) km/h", attributes: [NSAttributedStringKey.foregroundColor: secondaryColor ?? UIColor.black])
        stringThree.append(stringFour)
        
        humidityDetails.attributedText = attrString
        windDetails.attributedText = stringThree
        
        temperatureRange.text = "\(Int(currentDayObj.minTemp ?? 0.0))° | \(Int(currentDayObj.maxTemp ?? 0.0))°"
        temperatureRange.textColor = secondaryColor
        
        rainDetails.text = isEnglish ? currentValues.currentStatus.eng : currentValues.currentStatus.ar
        rainDetails.textColor = primaryColor
        
        if currentValues.currentStatus.eng.lowercased().contains("thunder") {
            let imageToSet = currentValues.isDay ? "thunderDay" : "thunderNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else if currentValues.currentStatus.eng.lowercased().contains("rain") {
            let imageToSet = currentValues.isDay ? "rainyDay" : "rainyNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else if currentValues.currentStatus.eng.lowercased().contains("cloud") {
            let imageToSet = currentValues.isDay ? "cloudy" : "cloudyNight"
            backgroundImage.image = UIImage(named: imageToSet)
        } else {
            let imageToSet = currentValues.isDay ? "sunny" : "clearNight"
            backgroundImage.image = UIImage(named: imageToSet)
        }
        backgroundImage.alpha = 0.3

        let imageUrl: URL = theme.rawValue == 0 ? currentValues.icons.color : currentValues.icons.white
        tempImage.sd_setImage(with: imageUrl, completed: nil)
    }
    
    //Helper functions
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        var safeArea: CGFloat = 0
        
        if #available(iOS 11.0, *), UIDevice.current.orientation.isLandscape {
            let insets = UIApplication.shared.keyWindow?.safeAreaInsets
            safeArea = (insets?.top ?? 0) + (insets?.bottom ?? 0)
            safeArea += safeArea > 0 ? 10.0 : 0.0
        }
//        mainWeatherViewWidth.constant = size.width - safeArea
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let hourVC = segue.destination as? HourlyReportViewController {
            hourVC.weatherDetails = self.weatherDetails
        }
    }
}
