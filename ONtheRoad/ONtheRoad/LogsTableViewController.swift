//
//  LogsTableViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-05.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class LogsTableViewController: UITableViewController {
    
    var tripLog = [TripData]()
    var trips = TripData()
    var activeFlag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Loads the trip log
        loadTripFromArray()
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripLog.count
    }

    //displays the contents of each table cell
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
    
    // MARK: Actions
    
    @IBAction func unwindToTripLogList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DetailedMapViewController, let trip = sourceViewController.trips {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing trip.
                tripLog[selectedIndexPath.row] = trip
                tableView.reloadData()
            }
            else {
                // Add new trip
                tripLog.append(trip)
                tableView.reloadData()
            }
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            let rowNum = indexPath.row
            
            tripLog.remove(at: indexPath.row)
            trips.deleteTrip(numberOfTrip: rowNum + 1)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowDetail":
            guard let tripDetailViewController = segue.destination as? DetailedMapViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedTripCell = sender as? LogsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedTripCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedTrip = tripLog[indexPath.row]
            tripDetailViewController.trips = selectedTrip
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: Functions

    func loadTripFromArray() {
        var count = 1
        TripData.totalNumberOfTrips = 0

        //ONTINEUSGH is a boolean to control loop
        //Variable name represents success after long periods of failure
        var ONTINEUSGH = true
        while(ONTINEUSGH) {
            // This goes inside the loop to get all trips
            if let trips = self.trips.loadTrip(numberOfTrip: count) {
                self.tripLog.append(trips)
                count += 1
                TripData.totalNumberOfTrips += 1
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
