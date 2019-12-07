//
//  WebService.swift
//  
//
//  Created by Midhet Sulemani on 12/7/19.
//

import Foundation

class Webservice {
    
    private var session: URLSession!
    
    init() {
        self.session = URLSession(configuration: .default)
    }
    
    func fetchWeather(completionHandler: @escaping ([String: Any]?, ServiceError?) -> Void) {
        
        let endPoint = ""
        
        guard let url = URL(string: endPoint) else {
            print("Error in creating url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        session.dataTask(with: urlRequest) {(data, responseURL, error) in
            
            var serviceError: ServiceError?
            
            if let responseData = data {
                var parsedData: [String: Any]?
                do {
                    parsedData = try JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves) as? [String:Any]
                } catch {
                    print("error trying to convert data to JSON")
                    serviceError = ServiceError(details: error)
                }
                completionHandler(parsedData, serviceError)
            } else {
                serviceError = ServiceError(details: error!)
                completionHandler(nil, serviceError)
            }
        }.resume()
    }
    
    func searchCountryWeather(searchStr: String, completionHandler: @escaping ([String: Any]?, ServiceError?) -> Void) {
        
        let endPoint = "https://community-open-weather-map.p.rapidapi.com/find?q=\(searchStr)"
        
        let headers = [
            "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
            "x-rapidapi-key": "ce3a2dcffdmsh4bec54f42db20c3p1228d0jsn69caa6958465"
        ]
        
        guard let url = URL(string: endPoint) else {
            print("Error in creating url")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        session.dataTask(with: urlRequest) {(data, responseURL, error) in
            
            var serviceError: ServiceError?
            
            if let responseData = data {
                var parsedData: [String: Any]?
                do {
                    parsedData = try JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves) as? [String:Any]
                } catch {
                    print("error trying to convert data to JSON")
                    serviceError = ServiceError(details: error)
                }
                completionHandler(parsedData, serviceError)
            } else {
                serviceError = ServiceError(details: error!)
                completionHandler(nil, serviceError)
            }
        }.resume()
    }
}

class ServiceError {
    
    var code: Int?
    var message: String = "There was an error in the API call"
    
    init(details: Error) {
        message = details.localizedDescription
    }
}

