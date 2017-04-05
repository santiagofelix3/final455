//
//  GraphOneViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-27.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class GraphOneViewController: UIViewController {
    
    var currentCount: Float = 0.0
    var maxCount: Float = 10.0
    
    @IBOutlet weak var circleAnimation: KDCircularProgress!
    @IBOutlet weak var circleBackground: KDCircularProgress!
    @IBOutlet weak var efficiencyNumberLabel: UILabel!
    @IBOutlet weak var litersLabel: UILabel!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground()
        setAnimation()
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GraphOneViewController.updateCircle), userInfo: nil, repeats: true)
    }
    
    func newAngle() -> Float {
        return Float(360 * (currentCount / maxCount))
    }
    
    func updateCircle() {
        
        currentCount = generateRandomNumbers()
        
        if currentCount == 0 {
            currentCount = 0.5
        }
        
        if currentCount != maxCount {
            let newAngleValue = newAngle()
            
            //circleAnimation.animate(toAngle: Double(newAngleValue), duration: 0.5, completion: nil)
            circularProgress.animate(toAngle: Double(newAngleValue), duration: 0.5, completion: nil)
            
            efficiencyNumberLabel.text = "\((newAngleValue/10))"
        }
    }
    
    // MARK: Functions
    
    func generateRandomNumbers() -> Float {
        let rand = Float(arc4random_uniform(UInt32(7.5)))
        print(rand)
        return rand
    }
    
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
