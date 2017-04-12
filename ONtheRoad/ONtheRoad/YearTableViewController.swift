//
//  YearTableViewController.swift
//  VehiclesAPI
//
//  Created by Santiago Félix Cárdenas on 2017-03-16.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class YearTableViewController: UITableViewController {

    var yearString = [Int]()
    var selectedIndex = 0
    var selectedYear = ""
    var receivedMake = ""
    var receivedModel = ""
    var returnThis: String? = ""
    
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
        return self.yearString.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "yearTableViewCell", for: indexPath) as? YearTableViewCell
        
        if(indexPath.row == selectedIndex) {
            cell?.accessoryType = .checkmark;
            selectedYear = (cell?.yearLabel.text)!
        } else {
            cell?.accessoryType = .none;
        }
                
        cell?.yearLabel.text = "\(self.yearString[indexPath.row])"
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
        if selectedYear == "Label" {
            selectedYear = "\(yearString[0])"
        }
        returnThis = "HOLA"//selectedYear
    }
    
    // MARK: Functions
    
    func downloadData() {
        
        //let url = URL(string: "https://api.edmunds.com/api/vehicle/v2/honda/accord/years?&fmt=json&api_key=b3aa4xkn4mc964zcpnzm3pmv")
        
        let urlBase = "https://api.edmunds.com/api/vehicle/v2/"
        let urlExtra = "/years?&fmt=json&api_key=gjppwybke2wgy6ndafz23cyr"
        let fullURL = URL(string: "\(urlBase)\(receivedMake)\("/")\(receivedModel)\(urlExtra)")
        
        do {
            
            let allYearStrings = try Data(contentsOf: fullURL!)
            let allYears = try JSONSerialization.jsonObject(with: allYearStrings, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            
            if let aryJSON = allYears["years"] as? NSArray {
                for index in 0...aryJSON.count-1 {
                    let years = aryJSON[index] as! [String : AnyObject]
                    yearString.append((years["year"]! as? Int)!)
                }
            }
        }
        catch {
            
        }
    }
}
