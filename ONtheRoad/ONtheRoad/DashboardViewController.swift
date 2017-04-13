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
    @IBOutlet weak var selectVehicleName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var vehicles: VehicleProfile?
    lazy var stopWatch = Timer()
    var startTime = TimeInterval()
    var seconds = 0
    var index = 0
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //Creating the UI
        setupView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Loading in the active vehicle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectVehicleSegue" {
            flag = 1
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! GarageTableViewController
            controller.activeFlag = flag
        }
    }
    
    // MARK: Navigation
    
    @IBAction func unwindToDashboard(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? GarageTableViewController, let vehicle = sourceViewController.selectVehicle {
            vehicles = vehicle
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        setupVehicle()
    }
    
    // MARK: Actions
    
    @IBAction func startStopButton(_ sender: UIButton) {
     //Start/Stop Button controls
        //Start Case
        if startStopButton.currentTitle == "Start" {
            //Making sure user has an active vehicle, if they do not they get a prompt to select one and the trip does not start
            if vehicles == nil {
                let alertController = UIAlertController(title: "No Vehicle Selected", message:
                    "Please select a vehicle for your trip", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                //If user has an active vehicle the trip can start
                startStopButton.setTitle("Stop", for: .normal)
                
                transitionAnimationShow()
                //Loading in the users vehicle specs for the trip
                GlobalTripDataInstance.globalTrip = TripData.init(vehiclePhoto: (vehicles?.photo)!, name: (vehicles?.name)!, odometerStart: 0, vehicleMaxAccel: (vehicles?.maxAcceleration)!, vehicleActual: (vehicles?.efficiency)!)
                GlobalTripDataInstance.globalTrip?.started = 1
                //Start recording the users trip
                GlobalTripDataInstance.globalTrip?.startTrip()
                
                stopWatch = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DashboardViewController.updateTime(_stopWatch:)), userInfo: nil, repeats: true)
                startTime = Date.timeIntervalSinceReferenceDate
            }

        //Stop case
        } else {
            startStopButton.setTitle("Start", for: .normal)
            GlobalTripDataInstance.globalTrip?.endTrip()
            seconds = 0
            timeLabel.text = "00 :00"
            distanceLabel.text = "--"
            velocityLabel.text = "--"
            stopWatch.invalidate()
            transitionAnimationHide()
        }
    }
    
    @IBAction func selectVehicleAction(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "selectVehicleSegue", sender: nil)
        
    }
    
    
    // MARK: Functions
    
    func setupView() {
        let topColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 51/255.0, green: 123/255.0, blue: 177/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        gradientLayer.frame = self.selectVehicleView.bounds
        self.selectVehicleView.layer.insertSublayer(gradientLayer, at: 0)
        
        
        // Round corners for profile image
        self.selectVehicleImage.layer.cornerRadius = self.selectVehicleImage.frame.size.height / 2
        self.selectVehicleImage.clipsToBounds = true
        
        // Border for image
        self.selectVehicleImage.layer.borderWidth = 2.0
        self.selectVehicleImage.layer.borderColor = UIColor.white.cgColor
        activityIndicator.isHidden = true
    }
    
    //Dashboard display/update function
    func updateTime(_stopWatch: Timer) {
        seconds += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        
        //Case for hours, minutes, seconds
        if seconds >= 3600 {
            timeLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":"+String(format: "%02d", s)
        } else {
            //case for minutes, seconds
            timeLabel.text = String(format: "%02d", m) + ":"+String(format: "%02d", s)
        }
        //If the trip has at least one item display current specs.
        if (GlobalTripDataInstance.globalTrip?.tripLocationData.count)! > 0 {
            //Converting from meters to kms
            distanceLabel.text = String(format: "%.02f", (GlobalTripDataInstance.globalTrip?.tripDistance)!/1000)
            //Converting from m/s to km/h
            velocityLabel.text = String(Int(3.6*(GlobalTripDataInstance.globalTrip?.tripLocationData[(GlobalTripDataInstance.globalTrip?.tripLocationData.count)! - 1].instSpeed)!))
        }
    }
    
    //Converting from seconds to Hours, Minutes, Seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //Flipping from dashboard view to trip running view
    func transitionAnimationShow() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView.transition(with: graphsView, duration: 1.0, options: transitionOptions, animations: {
            self.selectVehicleView.isHidden = true
            self.testView.isHidden = true
        })
    }
    
    //Flipping back
    func transitionAnimationHide() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: graphsView, duration: 1.0, options: transitionOptions, animations: {
            self.selectVehicleView.isHidden = false
            self.testView.isHidden = false
        })
    }
    
    //Storing the active vehicle's stats
    func setupVehicle() {
        selectVehicleImage.image = vehicles?.photo
        selectVehicleName.text = vehicles?.name
        if selectVehicleImage.image == vehicles?.photo {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
}






