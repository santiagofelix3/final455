//
//  GarageTableViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-04-01.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class GarageTableViewController: UITableViewController {
    
    var vehicles = VehicleProfile.init()
    var garage = [VehicleProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        loadVehicleFromArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return garage.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vehicleTableCell", for: indexPath) as? GarageTableViewCell
        
        let garages = garage[indexPath.row]
        let description = garages.make + " " + garages.model + " " + garages.trim + " " + garages.year
        
        cell?.vehicleImage.image = garages.photo
        cell?.vehicleName.text = garages.name
        cell?.vehicleDescription.text = description
        
        cell?.vehicleImage.layer.cornerRadius = (cell?.vehicleImage.frame.size.height)! / 2
        cell?.vehicleImage.clipsToBounds = true
        
        cell?.vehicleImage.layer.borderWidth = 2.0
        cell?.vehicleImage.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
        
        return cell!
    }
    
    // MARK: Actions
    
    @IBAction func unwindToGarageList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddVehicleViewController, let vehicle = sourceViewController.vehicles {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing vehicle.
                garage[selectedIndexPath.row] = vehicle
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add new vehicle
                let newIndexPath = IndexPath(row: garage.count, section: 0)
                garage.append(vehicle)
                VehicleProfile.totalNumberOfVehicles = garage.count
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            print(garage)
        }
    }
    
    // MARK: Private Methods
    
    private func loadSampleData() {
        
        let photo1 = UIImage(named: "photo1")
        let photo2 = UIImage(named: "photo2")
        
        guard let vehicle1 = VehicleProfile(photo: photo1!, name: "Mom's Van", make: "Dodge", model: "Caravan", year: "2012", trim: "SXT", type: "Personal", id: "123456", maxAcceleration: 5.0, efficiency: 17.6, cylinder: "8", size: "3.5", horsepower: "355", torque: "400", gas: "Gas") else {
            fatalError("Unable to instantiate vehicle1")
        }
        
        guard let vehicle2 = VehicleProfile(photo: photo2!, name: "Truck", make: "Gmc", model: "Sierra", year: "2014", trim: "SLE", type: "Work", id: "123456", maxAcceleration: 4.0, efficiency: 14.2, cylinder: "6", size: "2.6", horsepower: "250", torque: "300", gas: "Gas") else {
            fatalError("Unable to instantiate vehicle2")
        }
        
        garage += [vehicle1, vehicle2]
        
        loadVehicleFromArray()
    }
    
    func loadVehicleFromArray() {
        var count = 1
        
        //ONTINEUSGH is a boolean to control loop
        //Variable name represents success after long periods of failure
        var ONTINEUSGH = true
        while(ONTINEUSGH) {
            if let savedVehicles = self.vehicles.loadVehicle(numberOfVehicle: count) {
                self.garage.append(savedVehicles)
                count += 1
                VehicleProfile.totalNumberOfVehicles += 1
            }
            else{
                ONTINEUSGH = false
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
            garage.remove(at: indexPath.row)
            vehicles.deleteVehicle(numberOfVehicle: rowNum + 1, totalNumberOfVehicles: VehicleProfile.totalNumberOfVehicles)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new vehicle.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let vehicleDetailViewController = segue.destination as? AddVehicleViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedVehicleCell = sender as? GarageTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedVehicleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedVehicle = garage[indexPath.row]
            vehicleDetailViewController.vehicles = selectedVehicle
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
}
