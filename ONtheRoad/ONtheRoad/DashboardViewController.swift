//
//  DashboardViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-27.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import HealthKit

class DashboardViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var graphsView: UIView!
    @IBOutlet weak var selectVehicleView: UIView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var selectVehicleImage: UIImageView!

    lazy var stopWatch = Timer()
    var startTime = TimeInterval()
    var seconds = 0
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        //newTrip?.tripLocationData.append(Location.init(timeStamp: Date.init(), latitude: 0, longitude: 0, distance: 0)!)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    
    @IBAction func startStopButton(_ sender: UIButton) {
        
        if startStopButton.currentTitle == "Start" {
            startStopButton.setTitle("Stop", for: .normal)
            
            transitionAnimationShow()
            
            GlobalTripDataInstance.init()
            GlobalTripDataInstance.globalTrip?.startTrip()
            
            //newTrip = TripData.init(vehicleID: 1, name: "", odometerStart: 0, vehicleMaxAccel: 4.8)
            //newTrip?.startTrip()
            
            stopWatch = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DashboardViewController.updateTime(_stopWatch:)), userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
            
        } else {
            startStopButton.setTitle("Start", for: .normal)
            GlobalTripDataInstance.globalTrip?.endTrip()
            stopWatch.invalidate()
            transitionAnimationHide()
        }
    }
    
    // MARK: Functions
    
    func setupView() {
        // Round corners for profile image
        self.selectVehicleImage.layer.cornerRadius = self.selectVehicleImage.frame.size.height / 2
        self.selectVehicleImage.clipsToBounds = true
        
        // Border for image
        self.selectVehicleImage.layer.borderWidth = 2.0
        self.selectVehicleImage.layer.borderColor = UIColor.white.cgColor
    }
    
    func updateTime(_stopWatch: Timer) {
        
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))

        if seconds >= 3600 {
            timeLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":"+String(format: "%02d", s)
        } else {
            timeLabel.text = String(format: "%02d", m) + ":"+String(format: "%02d", s)
        }
        
        distanceLabel.text = String(format: "%.02f", (GlobalTripDataInstance.globalTrip?.tripDistance)!/1000)
        //distanceLabel.text = String(Int((GlobalTripDataInstance.globalTrip?.tripDistance)!)/1000)
        velocityLabel.text = String(Int(3.6*(GlobalTripDataInstance.globalTrip?.tripLocationData[(GlobalTripDataInstance.globalTrip?.tripLocationData.count)! - 1].instSpeed)!))

        
        // print(newTrip?.tripLocationData[(newTrip?.tripLocationData.count)!-1].instAcceleration)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func transitionAnimationShow() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: graphsView, duration: 1.0, options: transitionOptions, animations: {
            self.selectVehicleView.isHidden = true
            self.testView.isHidden = true

        })
        //selectVehicleView.backgroundColor = UIColor.clear
    }
    
    func transitionAnimationHide() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: graphsView, duration: 1.0, options: transitionOptions, animations: {
            self.selectVehicleView.isHidden = false
            self.testView.isHidden = false
        })
        //selectVehicleView.backgroundColor = UIColor.clear
    }
}






