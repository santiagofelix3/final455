//
//  TrimTableViewController.swift
//  VehiclesAPI
//
//  Created by Santiago Félix Cárdenas on 2017-03-16.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class TrimTableViewController: UITableViewController {

    var trimNames = [String]()
    var styleID = [Int]()
    //var trimNumber: Int = 0
    var selectedIndex = 0
    var selectedTrim = ""
    var selectedID = ""
    var receivedMake = ""
    var receivedModel = ""
    var receivedYear = ""
    var returnThis: String? = ""
    var returnThisID: String? = ""
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //downloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trimNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trimTableViewCell", for: indexPath) as? TrimTableViewCell
        
        if(indexPath.row == selectedIndex) {
            cell?.accessoryType = .checkmark;
            selectedTrim = (cell?.trimLabel.text)!
            selectedID = "\(styleID[indexPath.row])"
        } else {
            cell?.accessoryType = .none;
        }

        cell?.trimLabel.text = "\(self.trimNames[indexPath.row])"
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
        if selectedTrim == "Label" {
            selectedTrim = trimNames[0]
        }
        returnThis = "HOLA"//selectedTrim
        returnThisID = "HOLA"//selectedID
    }
    
    // MARK: Functions
    
    func downloadData() {
        
        //let url = URL(string: "https://api.edmunds.com/api/vehicle/v2/honda/pilot/2010/styles?fmt=json&api_key=b3aa4xkn4mc964zcpnzm3pmv")
        
        let urlBase = "https://api.edmunds.com/api/vehicle/v2/"
        let urlExtra = "/styles?fmt=json&api_key=8zc8djuwwteevqe9nea3cejq"
        let fullURL = URL(string: "\(urlBase)\(receivedMake)\("/")\(receivedModel)\("/")\(receivedYear)\(urlExtra)")
        
        do {
            let allTrimNames = try Data(contentsOf: fullURL!)
            let allTrims = try JSONSerialization.jsonObject(with: allTrimNames, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            
            if let aryJSON = allTrims["styles"] as? NSArray {
                for index in 0...aryJSON.count-1 {
                    let trims = aryJSON[index] as! [String : AnyObject]
                    
                    trimNames.append((trims["trim"]! as? String)!)
                    styleID.append((trims["id"]! as? Int)!)
                    
                }
            }
        }
        catch {
            
        }
    }
}
