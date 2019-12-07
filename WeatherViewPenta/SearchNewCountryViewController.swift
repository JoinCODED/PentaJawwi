//
//  SearchNewCountryViewController.swift
//  WeatherViewNabd
//
//  Created by Midhet Sulemani on 12/7/19.
//  Copyright © 2019 Waveline Media. All rights reserved.
//

import UIKit

class SearchNewCountryViewController: UIViewController {
    
    @IBOutlet weak var searchTable: UITableView!
    
    var locationData: [LocationModel] = []
    weak var refreshDelegate: LocationUpdateProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func search(locationName: String) {
        Webservice().searchCountryWeather(searchStr: locationName) {[weak self] (details, error) in
            guard let _ = self else { return }
            DispatchQueue.main.async {
                if let details = details {
                    print("service successful")
                    if let statusCode = details["cod"] as? String, statusCode == "200" {
                        if let resultList = details["list"] as? [[String: Any]] {
                            self?.locationData = resultList.map {LocationModel(details: $0)}
                            self?.searchTable.reloadData()
                        }
                    }
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

extension SearchNewCountryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") {
            cell.textLabel?.text = "\(locationData[indexPath.row].city ?? ""), \(locationData[indexPath.row].country ?? "")"
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchNewCountryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.refreshDelegate?.addLocation(location: locationData[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchNewCountryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("here 3")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(locationName: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        print("here 5")
    }
}
