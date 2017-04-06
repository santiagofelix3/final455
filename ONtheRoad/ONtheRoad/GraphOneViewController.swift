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
        
        setBackground()
        setAnimation()
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GraphOneViewController.updateCircle), userInfo: nil, repeats: true)
    }
    
    func newAngle() -> Float {
        if (GlobalTripDataInstance.globalTrip?.vehicleIdeal != nil) {
            return Float(270 * (self.currentCount * 6.2 / (GlobalTripDataInstance.globalTrip?.vehicleIdeal)!))
        }
        else {
            return Float (0.0)
        }
    }
    
    func updateCircle() {
        if (GlobalTripDataInstance.globalTrip?.started != nil) {
            if (GlobalTripDataInstance.globalTrip?.tripLocationData.count)! > 0 {
            currentCount = (GlobalTripDataInstance.globalTrip?.tripLocationData[(GlobalTripDataInstance.globalTrip?.tripLocationData.count)!-1].efficiencyRatio)!
            }
            if (currentCount > (GlobalTripDataInstance.globalTrip?.vehicleIdeal)!) {
                currentCount = (GlobalTripDataInstance.globalTrip?.vehicleIdeal)!
            }
            if currentCount == 0 {
                currentCount = 0.5
            }
        }
        
        let newAngleValue = newAngle()
        
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
