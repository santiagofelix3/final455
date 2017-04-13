//
//  ModelTableViewController.swift
//  VehiclesAPI
//
//  Created by Santiago Félix Cárdenas on 2017-03-10.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class ModelTableViewController: UITableViewController {

    var modelNames = [String]()
    var modelNumber: Int = 0
    var selectedIndex = 0
    var selectedModel = ""
    var receivedMake = ""
    var returnThis: String? = ""
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadData()
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
        return self.modelNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelTableViewCell", for: indexPath) as? ModelTableViewCell
        
        if(indexPath.row == selectedIndex) {
            cell?.accessoryType = .checkmark;
            selectedModel = (cell?.modelLabel.text)!
        } else {
            cell?.accessoryType = .none;
        }
        
        cell?.modelLabel.text = self.modelNames[indexPath.row]
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
        if selectedModel == "Label" {
            selectedModel = modelNames[0]
        }
        returnThis = selectedModel
    }
    
    // MARK: Functions
    
    func downloadData() {
        
        //let url = URL(string: "https://api.edmunds.com/api/vehicle/v2/acura/models?fmt=json&state=new&api_key=b3aa4xkn4mc964zcpnzm3pmv")
        
        let urlBase = "https://api.edmunds.com/api/vehicle/v2/"
        let urlExtra = "/models?fmt=json&state=new&api_key=b3aa4xkn4mc964zcpnzm3pmv"
        let fullURL = URL(string: "\(urlBase)\(receivedMake)\(urlExtra)")
        
        do {
            let allModelsNames = try Data(contentsOf: fullURL!)
            let allModels = try JSONSerialization.jsonObject(with: allModelsNames, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]

            if let aryJSON = allModels["models"] as? NSArray {
                for index in 0...aryJSON.count-1 {
                    let models = aryJSON[index] as! [String : AnyObject]
                    modelNames.append(models["name"]!.capitalized as String)
                }
            }
        }
        catch {
            
        }
    }
}
