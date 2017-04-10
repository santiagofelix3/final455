//
//  MakeTableViewController.swift
//  VehiclesAPI
//
//  Created by Santiago Félix Cárdenas on 2017-02-16.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class MakeTableViewController: UITableViewController {

    var makeNames = [String]()
    var makesNumber: Int = 0
    var selectedIndex = 0
    var selectedMake = ""
    var returnThis: String?

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        downloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.makeNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "makeTableViewCell", for: indexPath) as? MakeTableViewCell
        
        if(indexPath.row == selectedIndex) {
            cell?.accessoryType = .checkmark;
            selectedMake = (cell?.makeLabel.text)!
        } else {
            cell?.accessoryType = .none;
        }
        
        cell?.makeLabel.text = self.makeNames[indexPath.row]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row;
        self.tableView.reloadData()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            os_log("The done button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        if selectedMake == "Label" {
            selectedMake = makeNames[0]
        }
        returnThis = selectedMake
    }
    
    // MARK: Functions
    
    func downloadData() {

        let url = URL(string:"https://api.edmunds.com/api/vehicle/v2/makes?state=new&year=2017&view=basic&fmt=json&api_key=gjppwybke2wgy6ndafz23cyr")
        
        do {
            let allMakesNames = try Data(contentsOf: url!)
            let allMakes = try JSONSerialization.jsonObject(with: allMakesNames, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            
            if let aryJSON = allMakes["makes"] {
                for index in 0...aryJSON.count-1 {
                    
                    let makes = aryJSON[index] as! [String : AnyObject]
                    makeNames.append(makes["name"]!.capitalized as String)
                }
            }
        }
            
        catch {
            
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
