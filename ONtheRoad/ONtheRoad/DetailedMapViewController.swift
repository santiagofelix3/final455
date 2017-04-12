//
//  DetailedMapViewController.swift
//  ONtheRoad
//
//  Created by Michael Dickenson on 2017-04-04.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import MapKit
import HealthKit

class DetailedMapViewController: UIViewController, MKMapViewDelegate {

    var mapOverlay: MKTileOverlay!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tripTime: UILabel!
    
    var trips: TripData?
    var selectTrip = TripData()
    var sendTrip: TripData?
    var tripLog = [TripData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up views if editing an existing trip.
        if let trips = trips {
            navigationItem.title = trips.name
            
            let tripT = trips.tripLength
            
            let (h,m) = secondsToHoursMinutes(seconds: Int(tripT))
            
            if tripT >= 3600 {
                tripTime.text = String(format: "%2d", h) + " hr " + String(format: "%2d", m) + " min"
            } else if tripT < 60 {
                tripTime.text = "0" + " min"
            } else {
                tripTime.text = String(format: "%.0d", m) + " min"
            }
        }
        configureView()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.destination is AnalyticsViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        let selectedTrip = trips
        sendTrip = selectedTrip
    }
    
    @IBAction func unwindToDetailedMapView(sender: UIStoryboardSegue) {
    }
    
    // MARK: Functions
    
    @IBAction func cancel(_ sender: Any) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The AddVehicleNavigation is not inside a navigation controller.")
        }
    }
    
    func secondsToHoursMinutes (seconds : Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }
    
    func configureView() {
        loadMap()
    }
    
    //Focusing the map
    //Going to need to do some pinch zoom work on this as well, I think. Haven't been able to do it in the sim, haven't found code for it either, assuming it is missing.
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = trips?.tripLocationData[0]
        
        var minLat = initialLoc?.latitude
        var minLng = initialLoc?.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = trips?.tripLocationData
        
        for location in locations! {
            minLat = min(minLat!, location.latitude)
            minLng = min(minLng!, location.longitude)
            maxLat = max(maxLat!, location.latitude)
            maxLng = max(maxLng!, location.longitude)
        }
        
        //This should be showing the entire area driven over but it is not
        //Looks like its because of the differences in between the two deltas and trying to find a compromise.
        //If one is drastically different than the other it's not going to display the whole area we want.
        //I'm currently composating for this by changing the mult factor from 1.1 to 2, not a great fix.
        //Can lead to a really bad zoom level, will need to work on being able to zoom the map.
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat! + maxLat!)/2,
                                           longitude: (minLng! + maxLng!)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat! - minLat!)*2,
                                   longitudeDelta: (maxLng! - minLng!)*2))
    }
    
    //Displaying the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        //Tile overlay for loading
        if overlay is MKTileOverlay{
            guard let tileOverlay = overlay as? MKTileOverlay else {
                return MKOverlayRenderer()
            }
            
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        //Drawn lines overlay, maps route
        if overlay is MulticolorPolylineSegment {
            let polyline = overlay as! MulticolorPolylineSegment
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = polyline.color
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    //Drawing the lines on the map
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = trips?.tripLocationData
        for location in locations! {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude,
                                                 longitude: location.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: (trips?.tripLocationData.count)!)
    }
    
    //Loading in the map
    func loadMap() {
        if (trips?.tripLocationData.count)! > 0 {
            mapView.isHidden = false
            //Call to a map
            let template = "http://mt0.google.com/vt/x={x}&y={y}&z={z}" //"https://api.mapbox.com/styles/v1/spitfire4466/citl7jqwe00002hmwrvffpbzt/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoic3BpdGZpcmU0NDY2IiwiYSI6Im9jX0JHQUUifQ.2QarbK_LccnrvDg7FobGjA"
            
            mapOverlay = MKTileOverlay(urlTemplate: template)
            mapOverlay.canReplaceMapContent = true
            
            mapView.add(mapOverlay,level: .aboveLabels)
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: (trips?.tripLocationData)!)
            mapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapView.isHidden = true
            
            UIAlertView(title: "Error",
                        message: "Sorry, this drive has no locations saved",
                        delegate:nil,
                        cancelButtonTitle: "OK").show()
        }
    }
}

