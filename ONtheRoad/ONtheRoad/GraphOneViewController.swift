//
//  GraphOneViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-27.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class GraphOneViewController: UIViewController {
    
    var currentCount: Double = 0.0
    
    @IBOutlet weak var circleAnimation: KDCircularProgress!
    @IBOutlet weak var circleBackground: KDCircularProgress!
    @IBOutlet weak var efficiencyNumberLabel: UILabel!
    @IBOutlet weak var litersLabel: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Starting the graph animations
        setBackground()
        setAnimation()
        //Controlling the update intervals
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GraphOneViewController.updateCircle), userInfo: nil, repeats: true)
    }
    
    //Func for finding the angle we need to print at to show on the chart
    func newAngle() -> Float {
        if (GlobalTripDataInstance.globalTrip?.vehicleActual != nil) {
            //Multiplying the vehicleActual by 5 for proper scaling, this is something that could be explored in further depth but is currently a ballpark from testing and reading.
            return Float(270 * (self.currentCount * (GlobalTripDataInstance.globalTrip?.vehicleActual)! / ((GlobalTripDataInstance.globalTrip?.vehicleActual)!*5)))
        }
        else {
            return Float (0.0)
        }
    }
    
    //Grabbing the new value for the chart to display
    func updateCircle() {
        //Making sure a trip is running
        if (GlobalTripDataInstance.globalTrip?.started != nil) {
            //Can't display anything until the first reading
            if (GlobalTripDataInstance.globalTrip?.tripLocationData.count)! > 0 {
            //Grabbing the current locations effRatio, calculated back in TripData
            currentCount = (GlobalTripDataInstance.globalTrip?.tripLocationData[(GlobalTripDataInstance.globalTrip?.tripLocationData.count)!-1].efficiencyRatio)!
            }
            
            //Creating a hard cap in case we get an error with readings that creates values we can't actually get.
            if (currentCount > (GlobalTripDataInstance.globalTrip?.vehicleActual)!) {
                currentCount = (GlobalTripDataInstance.globalTrip?.vehicleActual)!
            }
            //Catching dead reads and throwing a low value in, doesn't happen often.
            if currentCount == 0 {
                currentCount = 0.3
            }
        }
        
        let newAngleValue = newAngle()
        //Updating the circle charts angle and value
        circularProgress.animate(toAngle: Double(newAngleValue), duration: 0.5, completion: nil)
        efficiencyNumberLabel.text = String(format: "%.02f", (newAngleValue/10))
    }
    
    // MARK: Functions
    
    func setBackground() {
        let topColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 5/255.0, green: 54/255.0, blue: 106/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setAnimation() {
        circleAnimation.angle = 0
        circularProgress.angle = 0
        
        circleAnimation.trackColor = UIColor.clear
        efficiencyNumberLabel.textColor = UIColor.white
        litersLabel.textColor = UIColor.white
    }
}
