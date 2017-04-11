//
//  AddVehicleViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-29.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import os.log

class AddVehicleViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var vehicles: VehicleProfile?
    var tempMake = ""
    var tempModel = ""
    var tempYear = ""
    var valueKM: Double = 0.0
    var maxAccelerationTime: Double = 0.0
    var loopFlag = 0
    
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var vehicleName: UITextField!
    @IBOutlet weak var vehicleMake: UITextField!
    @IBOutlet weak var vehicleModel: UITextField!
    @IBOutlet weak var vehicleYear: UITextField!
    @IBOutlet weak var vehicleTrim: UITextField!
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var efficiencyLabel: UILabel!
    @IBOutlet weak var horsepowerLabel: UILabel!
    @IBOutlet weak var cylinderLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var torqueLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var addVehicleScroll: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleName.delegate = self
        
        // Set up views if editing an existing vehicle.
        if let vehicles = vehicles {
            navigationItem.title = vehicles.name
            vehicleImage.image = vehicles.photo
            vehicleName.text = vehicles.name
            vehicleMake.text = vehicles.make
            vehicleModel.text = vehicles.model
            vehicleYear.text = vehicles.year
            vehicleTrim.text = vehicles.trim
            
            let formattedEfficiency = String(format: "%.2f", vehicles.efficiency)
            efficiencyLabel.text = formattedEfficiency
            
            cylinderLabel.text = vehicles.cylinder
            sizeLabel.text = vehicles.size
            horsepowerLabel.text = vehicles.horsepower
            torqueLabel.text = vehicles.torque
            gasLabel.text = vehicles.gas
        }
        
        setupView()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        if vehicleName.text != "" && vehicleMake.text != "" && vehicleModel.text != "" && vehicleYear.text != "" && vehicleTrim.text != "" {
            saveButton.isEnabled = true
        }
    }
    
    // MARK: Segue for passing values for API calls and save button for adding vehicle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "modelSegue" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! ModelTableViewController
            controller.receivedMake = tempMake
        }
        
        if segue.identifier == "yearSegue" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! YearTableViewController
            
            controller.receivedMake = tempMake
            controller.receivedModel = tempModel
        }
        
        if segue.identifier == "trimSegue" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! TrimTableViewController
            
            controller.receivedMake = tempMake
            controller.receivedModel = tempModel
            controller.receivedYear = tempYear
        }
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let photo = vehicleImage.image
        let name = vehicleName.text
        let make = vehicleMake.text
        let model = vehicleModel.text
        let year = vehicleYear.text
        let trim = vehicleTrim.text
        var type = ""
        
        if typeSegmentControl.selectedSegmentIndex == 0 {
            type = "Personal"
        } else {
            type = "Work"
        }
        
        let maxAccel = maxAccelerationTime
        let efficiency = valueKM
        
        let cylinder = cylinderLabel.text
        let size = sizeLabel.text
        let horsepower = horsepowerLabel.text
        let torque = torqueLabel.text
        let gas = gasLabel.text
        
        // Values to be passed ****************************************************************************
        vehicles = VehicleProfile(photo: photo!, name: name!, make: make!, model: model!, year: year!, trim: trim!, type: type, id: "", maxAcceleration: maxAccel, efficiency: efficiency, cylinder: cylinder!, size: size!, horsepower: horsepower!, torque: torque!, gas: gas!)
        
        
        VehicleProfile.totalNumberOfVehicles += 1
        vehicles?.saveVehicle(numberOfVehicle: VehicleProfile.totalNumberOfVehicles)
        print("It saves and comes back to add vehicle")
        
    }
    
    // MARK: Actions
    
    @IBAction func imageGestureRecognizer(_ sender: UITapGestureRecognizer) {
        
        openActionSheet()
    }
    
    @IBAction func vehicleNameAction(_ sender: UITextField) {
        if vehicleName.text! == "" {
            vehicleMake.isUserInteractionEnabled = false
            vehicleModel.isUserInteractionEnabled = false
            vehicleYear.isUserInteractionEnabled = false
            vehicleTrim.isUserInteractionEnabled = false
        } else {
            vehicleMake.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
            vehicleMake.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleMake.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleMake.layer.borderWidth = 1.0
            vehicleMake.layer.cornerRadius = 5.0
            
            vehicleMake.isUserInteractionEnabled = true
            vehicleModel.isUserInteractionEnabled = false
            vehicleYear.isUserInteractionEnabled = false
            vehicleTrim.isUserInteractionEnabled = false
        }
        
        if vehicleMake.text != "" && vehicleModel.text != "" && vehicleYear.text != "" && vehicleTrim.text != "" {
            vehicleMake.isUserInteractionEnabled = false
            vehicleModel.isUserInteractionEnabled = false
            vehicleYear.isUserInteractionEnabled = false
            vehicleTrim.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func makeSegueAction(_ sender: UITextField) {
        vehicleMake.resignFirstResponder()
        vehicleMake.allowsEditingTextAttributes = false
        performSegue(withIdentifier: "makeSegue", sender: nil)
    }
    
    @IBAction func modelSegueAction(_ sender: UITextField) {
        self.vehicleModel.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "modelSegue", sender: nil)
    }
    
    @IBAction func yearSegue(_ sender: UITextField) {
        self.vehicleYear.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "yearSegue", sender: nil)
    }
    
    @IBAction func trimSegue(_ sender: UITextField) {
        self.vehicleTrim.isUserInteractionEnabled = false
        self.performSegue(withIdentifier: "trimSegue", sender: nil)
    }
    
    @IBAction func unwindToAddVehicle(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MakeTableViewController, let returnedMake = sourceViewController.returnThis {
            vehicleMake.text = returnedMake
            tempMake = returnedMake.replacingOccurrences(of: " ", with: "")
            
            if vehicleMake.text! != "Label" && vehicleMake.text! != "" {
                vehicleModel.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
                vehicleModel.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleModel.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleModel.layer.borderWidth = 1.0
                vehicleModel.layer.cornerRadius = 5.0
                
                vehicleMake.isUserInteractionEnabled = true
                vehicleModel.isUserInteractionEnabled = true
                vehicleYear.isUserInteractionEnabled = false
                vehicleTrim.isUserInteractionEnabled = false
            } else {
                vehicleMake.text = ""
            }
        }
        
        if let sourceViewController = sender.source as? ModelTableViewController, let returnedModel = sourceViewController.returnThis {
            vehicleModel.text = returnedModel
            tempModel = returnedModel.replacingOccurrences(of: " ", with: "")
            
            
            if vehicleModel.text! != "Label" {
                vehicleYear.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
                vehicleYear.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleYear.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleYear.layer.borderWidth = 1.0
                vehicleYear.layer.cornerRadius = 5.0
                
                vehicleMake.isUserInteractionEnabled = false
                vehicleModel.isUserInteractionEnabled = true
                vehicleYear.isUserInteractionEnabled = true
                vehicleTrim.isUserInteractionEnabled = false
            } else {
                vehicleModel.text = ""
            }
        }
        
        if let sourceViewController = sender.source as? YearTableViewController, let returnedYear = sourceViewController.returnThis {
            vehicleYear.text = returnedYear
            tempYear = returnedYear
            
            if vehicleModel.text! != "Label" {
                vehicleTrim.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
                vehicleTrim.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleTrim.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
                vehicleTrim.layer.borderWidth = 1.0
                vehicleTrim.layer.cornerRadius = 5.0
                
                vehicleMake.isUserInteractionEnabled = false
                vehicleModel.isUserInteractionEnabled = false
                vehicleYear.isUserInteractionEnabled = true
                vehicleTrim.isUserInteractionEnabled = true
            } else {
                vehicleYear.text = ""
            }
        }
        
        if let sourceViewController = sender.source as? TrimTableViewController, let returnedTrim = sourceViewController.returnThis {
            vehicleTrim.text = returnedTrim
            
            if vehicleTrim.text! == "Label" || vehicleTrim.text! == "" {
                vehicleTrim.text = ""
            } else {
                vehicleMake.isUserInteractionEnabled = false
                vehicleModel.isUserInteractionEnabled = false
                vehicleYear.isUserInteractionEnabled = false
            }
        }
        
        if let sourceViewController = sender.source as? TrimTableViewController, let returnedID = sourceViewController.returnThisID {
            
            if returnedID == "" {
                vehicleMake.text = ""
                vehicleModel.text = ""
                vehicleYear.text = ""
                vehicleTrim.text = ""
            } else {
                getVehicleSpecifications(styleID: returnedID)
            }
        }
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddVehicleMode = presentingViewController is UITabBarController
        if isPresentingInAddVehicleMode {
            
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The AddVehicleNavigation is not inside a navigation controller.")
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Use edited representation of image.
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        vehicleImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Functions
    
    func setupView() {
        saveButton.isEnabled = false
        
        // Disable scroll view delay of touch
        addVehicleScroll.delaysContentTouches = false
        
        // Round corners for profile image
        self.vehicleImage.layer.cornerRadius = self.vehicleImage.frame.size.height / 2
        self.vehicleImage.clipsToBounds = true
        
        // Border for image
        self.vehicleImage.layer.borderWidth = 2.0
        self.vehicleImage.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
        
        // Vehicle Name TextField
        vehicleName.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
        vehicleName.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
        vehicleName.layer.borderWidth = 1.0
        vehicleName.layer.cornerRadius = 5.0
        
        if vehicleMake.text != "" {
            vehicleMake.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
            vehicleMake.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleMake.layer.borderWidth = 1.0
            vehicleMake.layer.cornerRadius = 5.0
            
            vehicleMake.isUserInteractionEnabled = false
        }
        
        if vehicleModel.text != "" {
            vehicleModel.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
            vehicleModel.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleModel.layer.borderWidth = 1.0
            vehicleModel.layer.cornerRadius = 5.0
            
            vehicleModel.isUserInteractionEnabled = false
        }
        
        if vehicleYear.text != "" {
            vehicleYear.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
            vehicleYear.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleYear.layer.borderWidth = 1.0
            vehicleYear.layer.cornerRadius = 5.0
            
            vehicleYear.isUserInteractionEnabled = false
        }
        
        if vehicleTrim.text != "" {
            vehicleTrim.textColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
            vehicleTrim.layer.borderColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0).cgColor
            vehicleTrim.layer.borderWidth = 1.0
            vehicleTrim.layer.cornerRadius = 5.0
            
            vehicleTrim.isUserInteractionEnabled = false
        }
        
        // Do not allow to enter info without previous field completed
        vehicleMake.isUserInteractionEnabled = false
        vehicleModel.isUserInteractionEnabled = false
        vehicleYear.isUserInteractionEnabled = false
        vehicleTrim.isUserInteractionEnabled = false
        vehicleTrim.allowsEditingTextAttributes = false
    }
    
    func updateSaveButtonState() {
        saveButton.isEnabled = true
    }
    
    func openActionSheet() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let openCamera = UIAlertAction(title: "Camera", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openCamera()})
        
        let openLibrary = UIAlertAction(title: "Camera Roll", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openPhotoLibrary()})
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(openCamera)
        optionMenu.addAction(openLibrary)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    func openCamera() {
        
        let alertController = UIAlertController(title: "Camera", message:
            "The camera is not available", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        let src = UIImagePickerControllerSourceType.camera
        
        // Check if camera is available
        guard UIImagePickerController.isSourceTypeAvailable(src)
            else {
                self.present(alertController, animated: true, completion: nil)
                return
        }
        
        guard let arr = UIImagePickerController.availableMediaTypes(for: src)
            else {
                return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = src
        imagePicker.mediaTypes = arr
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func openPhotoLibrary() {
        
        //Let user pick media
        let imagePickerController = UIImagePickerController()
        
        //Do not allow photos to be taken, only picked from media library
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        //Notify view controller that an image is picked
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func getVehicleSpecifications(styleID: String) {
        
        let selectedStyleID = "101353967"//"101172638"//"101353967"//styleID
        
        let urlBase = "https://api.edmunds.com/api/vehicle/v2/styles/"
        let urlExtra = "/equipment?fmt=json&api_key=8zc8djuwwteevqe9nea3cejq" //b3aa4xkn4mc964zcpnzm3pmv, 8zc8djuwwteevqe9nea3cejq, gjppwybke2wgy6ndafz23cyr
        let fullURL = URL(string: "\(urlBase)\(selectedStyleID)\(urlExtra)")
        
        do {
            let specs = try Data(contentsOf: fullURL!)
            let allSpecs = try JSONSerialization.jsonObject(with: specs, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            
            if let aryJSON = allSpecs["equipment"] as? NSArray {
                for index in 0...aryJSON.count-1 {
                    
                    let equipment = aryJSON[index] as! [String : AnyObject]
                    let sectionName = equipment["name"] as! String
                    
                    if sectionName == "Specifications" {
                        
                        let attr = equipment["attributes"] as! NSArray
                        var aryValues = attr[6] as! [String : AnyObject]
                        var name = aryValues["name"] as! String
                        
                        if name == "Ege Combined Mpg" {
                            let value = aryValues["value"] as! String
                            
                            // Convert String to Int and convert mpg to km/L
                            if let valueNumber = Double(value) {
                                valueKM = 235 / valueNumber
                                print(valueNumber)
                                print(value)
                                print("This L/100km")
                                print(valueKM)
                            }
                        } else {
                            
                            // If the information in the API is missing these values for the car we give them average values
                            valueKM = 235 / 26.4
                            print("This L/100km for the average value 26.4")
                            print(valueKM)
                            
                        }
                        
                        let kmLabel = "L/100km"
                        let finalEfficiency = valueKM
                        let formattedEfficiency = String(format: "%.2f", finalEfficiency)
                        
                        print("This is the final efficiency")
                        print(formattedEfficiency)
                        
                        efficiencyLabel.text = formattedEfficiency + kmLabel
                        
                        aryValues = attr[7] as! [String : AnyObject]
                        name = aryValues["name"] as! String
                        
                        if name == "Manufacturer 0 60mph Acceleration Time (seconds)" {
                            let value = aryValues["value"] as! String
                            
                            print("This is time from 0-60 mph")
                            print("value")
                            
                            // Convert String to Int and convert mpg to km/L
                            if let accelerationTime = Double(value) {
                                maxAccelerationTime = ((96.56 * 0.278) / accelerationTime)
                                print("This is the max acceleration time")
                                print(maxAccelerationTime)
                            }
                        } else {
                            print("This is maxacceleration for the average car")
                            maxAccelerationTime = 3.36
                        }
                        updateSaveButtonState()
                    }
                    
                    if sectionName == "Engine" && loopFlag == 0 {
                        
                        var cylinder = 0
                        cylinder = equipment["cylinder"] as! Int
                        var size = 0.0
                        size = equipment["size"] as! Double
                        var horsepower = 0
                        horsepower = equipment["horsepower"] as! Int
                        var torque = 0
                        torque = equipment["torque"] as! Int
                        var type = ""
                        type = (equipment["type"] as! String).capitalized
                        
                        if cylinder != 0 && size != 0.0 && horsepower != 0 && torque != 0 && type != "" {
                            cylinderLabel.text = "\(cylinder)"
                            sizeLabel.text = "\(size)"
                            horsepowerLabel.text = "\(horsepower)"
                            torqueLabel.text = "\(torque)"
                            gasLabel.text = type
                            
                            loopFlag = 1
                            
                            print(cylinder)
                            print(size)
                            print(horsepower)
                            print(torque)
                            print(type)
                        }
                    }
                }
            }
        }
            
        catch {
            
        }
    }
}




