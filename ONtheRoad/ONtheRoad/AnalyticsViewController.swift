//
//  AnalyticsViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-05.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController {
    
    @IBOutlet weak var badCircle: KDCircularProgress!
    @IBOutlet weak var averageCircle: KDCircularProgress!
    @IBOutlet weak var goodCircle: KDCircularProgress!
    @IBOutlet weak var lowCircle: KDCircularProgress!
    
    var badTime = 10.0
    var averageTime = 25.0
    var goodTime = 20.0
    var lowTime = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAnimation()
        updateCircle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //func newAngle() -> Float {
    //    return Float(360 * (currentCount / maxCount))
    // }
    
    func updateCircle() {
        let totalTime = badTime + averageTime + goodTime + lowTime
        
        var newAngle = Float(360 * (badTime / totalTime))
        badCircle.animate(toAngle: Double(newAngle), duration: 1, completion: nil)
        print(newAngle)
        
        var nextAngle = Double(newAngle)
        print(nextAngle)
        averageCircle.startAngle = nextAngle
        newAngle = Float(360 * (averageTime / totalTime))
        averageCircle.animate(toAngle: Double(newAngle), duration: 1, completion: nil)
        print(newAngle)
        
        nextAngle += Double(newAngle)
        print(nextAngle)
        goodCircle.startAngle = nextAngle
        newAngle = Float(360 * (goodTime / totalTime))
        goodCircle.animate(toAngle: Double(newAngle), duration: 1, completion: nil)
        print(newAngle)
        
        nextAngle += Double(newAngle)
        print(nextAngle)
        lowCircle.startAngle = nextAngle
        newAngle = Float(360 * (lowTime / totalTime))
        lowCircle.animate(toAngle: Double(newAngle), duration: 1, completion: nil)
        print(newAngle)
    }
    
    func setupAnimation() {
        badCircle.angle = 0
        averageCircle.angle = 0
        goodCircle.angle = 0
        lowCircle.angle = 0
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
