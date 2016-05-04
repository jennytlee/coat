//
//  ViewController.swift
//  Coat
//
//  Created by Jenny Lee on 5/4/16.
//  Copyright © 2016 Jenny Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBAction func getData(sender: AnyObject) {
        let escapedUrl = cityTextField.text!.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=" + escapedUrl! + "&APPID=363498100d054184c56e33e4ced6f7a4")
    }
    
    var manager: OneShotLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            if let loc = location {
                let lat = String(format: "%.3f", loc.coordinate.latitude)
                let long = String(format: "%.3f", loc.coordinate.longitude)
                
                print(lat)
                print(long)
                
                self.getWeatherData("http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + long + "&appid=363498100d054184c56e33e4ced6f7a4")
            } else if let err = error {
                print(err.localizedDescription)
                self.getWeatherData("http://api.openweathermap.org/data/2.5/weather?lat=38&lon=140&appid=363498100d054184c56e33e4ced6f7a4")
            }
            
            self.manager = nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeatherData(urlString: String) {
        let url = NSURL(string: urlString)
        print(url)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            self.setWeatherLabel(data!)
        })
        task.resume()
    }
    
    func setWeatherLabel(weatherData: NSData) {
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            print(json)
            
            if let name = json[("name")] as? String {
                dispatch_async(dispatch_get_main_queue(), {
                    self.cityNameLabel.text = name
                })
            }
            
            if let main = json[("main")] as? NSDictionary {
                if let temp = main[("temp")] as? Double {
                    let ft = (temp * 9/5) - 459.67
                    
                    let desc = String(format: "%.1f", ft)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tempLabel.text = desc + "\u{00B0} F"
                    })
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

