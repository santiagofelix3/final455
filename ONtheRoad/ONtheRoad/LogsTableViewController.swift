//
//  LogsTableViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-05.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

class LogsTableViewController: UITableViewController {

    var trips = TripData()
    var tripLog = [TripData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTripFromArray()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripLog.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logTableCell", for: indexPath) as? LogsTableViewCell
        
        let trips = tripLog[indexPath.row]
        
        cell?.vehicleImage.image = trips.vehiclePhoto
        cell?.vehicleName.text = trips.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy, h:mm a"//"dd.MM.yyyy HH:mm"
        cell?.tripStartTime.text = formatter.string(from: trips.startTime)
        
        let tripDistance = trips.tripDistance / 1000
        cell?.tripDistance.text = String(format: "%.2f", tripDistance) + " km"

        let tripTime = trips.tripLength
        
        let (h,m) = secondsToHoursMinutes(seconds: Int(tripTime))
        
        if tripTime >= 3600 {
            cell?.tripTotalTime.text = String(format: "%2d", h) + " hr " + String(format: "%2d", m) + " min"
        } else if tripTime < 60 {
            cell?.tripTotalTime.text = "0" + " min"
        } else {
            cell?.tripTotalTime.text = String(format: "%.0d", m) + " min"
        }
        
        cell?.vehicleImage.layer.cornerRadius = (cell?.vehicleImage.frame.size.height)! / 2
        cell?.vehicleImage.clipsToBounds = true
        
        cell?.vehicleImage.layer.borderWidth = 2.0
        cell?.vehicleImage.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
        
        return cell!
    }
    
    func loadTripFromArray() {
        var count = 1
        
        //ONTINEUSGH is a boolean to control loop
        //Variable name represents success after long periods of failure
        var ONTINEUSGH = true
        while(ONTINEUSGH) {
            // This goes inside the loop to get all trips
            if let trips = self.trips.loadTrip(numberOfTrip: count) {
                self.tripLog.append(trips)
                print("it did load and append trip" + String(count))
                print("This is supposeed to be the array of trips")

                print(tripLog)
                count += 1
            }
            else{
                ONTINEUSGH = false
            }
        }
    }
    
    func secondsToHoursMinutes (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }
}
