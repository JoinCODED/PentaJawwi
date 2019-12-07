//
//  StarterViewController.swift
//  WeatherViewNabd
//
//  Created by Waveline Media on 9/5/18.
//  Copyright © 2018 Waveline Media. All rights reserved.
//

import UIKit

class StarterViewController: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var details: Weather!
    
    @IBAction func showView(_ sender: UIButton) {
        callService()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func callService() {
        loader.startAnimating()
        loader.isHidden = false
        Webservice().fetchWeather {[weak self] (details, error) in
            
            guard let _ = self else { return }
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
                self?.loader.isHidden = true
                
                if let details = details {
                    let nextVC = self?.storyboard?.instantiateViewController(withIdentifier: "WeatherReportViewController") as! WeatherReportViewController
                    nextVC.weatherDetails = Weather(data: details)
                    self?.navigationController?.pushViewController(nextVC, animated: true)
                }
                else {
                    let alert = UIAlertController(title: "Error", message: error?.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
