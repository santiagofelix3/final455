import UIKit
import CoreLocation
import MapKit
import CoreData
import os.log

class TripData: NSObject, NSCoding, CLLocationManagerDelegate{
    
    //Mandatory Variables
    var locationManager: CLLocationManager!
    var startTime: Date?
    var vehicleID: Int
    var started = 0
    
    //Optional Input Variables
    var name: String?
    var odometerStart: Int?
    var vehicleMaxAccel: Double?
    
    //End of Trip Variables
    var odometerEnd: Int?
    var endTime: Date?
    var tripLength: Double?
    var tripDistance: Double = 0

    var tripLocationData = [Location]()
    
    lazy var locations = [CLLocation]()
    
    init?(vehicleID: Int, name: String?, odometerStart: Int?, vehicleMaxAccel: Double?){
        self.startTime = Date.init()
        self.vehicleID = vehicleID
        self.name = name
        self.odometerStart = odometerStart
        self.vehicleMaxAccel = vehicleMaxAccel
    }
        
    // MARK: GPS
    
    //Starts the trip
    func startTrip(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
        
        startTime = Date.init()
        print("Trip Started")
        locationManager.startUpdatingLocation()
    }
    
    //Stops the trip
    func endTrip(){
        locationManager.stopUpdatingLocation()
        saveNewTrip()
        endTime = Date.init()
    }
    
    //locationManager() is called everytime the GPS updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //for each location the GPS returns, update tripLocationData with a new Location
        for location in locations{
            
            //Bananas are delicious
            print ("BANANAS")
            print (self.locations.count)
            //          print(location.coordinate.latitude)
            //          print(location.coordinate.longitude)
            //If locations is not empty, calculate all
            if self.locations.count > 0 {
                let distanceSinceLast = location.distance(from: self.locations.last!)
                addCLLocation(location: location, distanceSinceLast: distanceSinceLast)
                print ("d: ", distanceSinceLast)
                //              print(location.coordinate.latitude)
                //              print(location.coordinate.longitude)
            }
            self.locations.append(location)
        }
    }
    
    func addCLLocation(location: CLLocation, distanceSinceLast: Double)
    {
        let tempLocation = Location()
        
        //Getting the timestamp
        tempLocation.timeStamp = location.timestamp
        //Getting the lat
        tempLocation.latitude = location.coordinate.latitude
        //Getting the long
        tempLocation.longitude = location.coordinate.longitude
        //Getting the distance
        tempLocation.distance = distanceSinceLast
        self.tripDistance += distanceSinceLast
        //Getting the instSpeed
        tempLocation.instSpeed = (tempLocation.distance)
        //Getting the instAccel
        if tripLocationData.count > 1 {
            tempLocation.instAccel = tempLocation.instSpeed - self.tripLocationData[tripLocationData.count-1].instSpeed
        }
        //Getting the effRatio
        tempLocation.efficiencyRatio = abs(tempLocation.instAccel/(vehicleMaxAccel!/2))+1
        
        self.tripLocationData.append(tempLocation)
    }
    
    // MARK: Permanent Storage
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    struct PropertyKey {
        static var startTime = "startTime"
        static var vehicleID = "vehicleID"
        static var name = "name"
        static var odometerStart = "odometerStart"
        static var vehicleMaxAccel = "vehicleMaxAccel"
        static var odometerEnd = "odometerEnd"
        static var endTime = "endTime"
        static var tripLength = "tripLength"
        static var tripDistance = "tripDistance"
        static var tripLocationData = "tripLocationData"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: PropertyKey.startTime)
        aCoder.encode(vehicleID, forKey: PropertyKey.vehicleID)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(odometerStart, forKey: PropertyKey.odometerStart)
        aCoder.encode(vehicleMaxAccel, forKey: PropertyKey.vehicleMaxAccel)
        aCoder.encode(odometerEnd, forKey: PropertyKey.odometerEnd)
        aCoder.encode(endTime, forKey: PropertyKey.endTime)
        aCoder.encode(tripLength, forKey: PropertyKey.tripLength)
        aCoder.encode(tripDistance, forKey: PropertyKey.tripDistance)
        aCoder.encode(tripLocationData, forKey: PropertyKey.tripLocationData)
    }
    
    init(startTime: Date, vehicleID: Int, name: String, odometerStart: Int, vehicleMaxAccel: Double, odometerEnd: Int, endTime: Date, tripLength: Double, tripDistance: Double, tripLocationData: [Location]) {
        self.startTime = startTime
        self.vehicleID = vehicleID
        self.name = name
        self.odometerStart = odometerStart
        self.vehicleMaxAccel = vehicleMaxAccel
        self.odometerEnd = odometerEnd
        self.endTime = endTime
        self.tripLength = tripLength
        self.tripDistance = tripDistance
        self.tripLocationData = tripLocationData
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let startTime = aDecoder.decodeObject(forKey: PropertyKey.startTime) as? Date else {
            os_log("Unable to decode the startTime for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let vehicleID = aDecoder.decodeObject(forKey: PropertyKey.vehicleID) as? Int else {
            os_log("Unable to decode the vehicleID for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let odometerStart = aDecoder.decodeInteger(forKey: PropertyKey.odometerStart) as Int? else {
            os_log("Unable to decode the odometerStart for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let vehicleMaxAccel = aDecoder.decodeDouble(forKey: PropertyKey.vehicleMaxAccel) as Double? else {
            os_log("Unable to decode the vehicleMaxAccel for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let odometerEnd = aDecoder.decodeInteger(forKey: PropertyKey.odometerEnd) as Int? else {
            os_log("Unable to decode the odometerEnd for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let endTime = aDecoder.decodeObject(forKey: PropertyKey.endTime) as? Date else {
            os_log("Unable to decode the endTime for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tripLength = aDecoder.decodeDouble(forKey: PropertyKey.tripLength) as Double? else {
            os_log("Unable to decode the tripLength for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tripDistance = aDecoder.decodeDouble(forKey: PropertyKey.tripDistance) as Double? else {
            os_log("Unable to decode the tripDistance for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let tripLocationData = aDecoder.decodeObject(forKey: PropertyKey.tripLocationData) as? [Location] else {
            os_log("Unable to decode the tripLocationData for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(startTime: startTime, vehicleID: vehicleID, name: name, odometerStart: odometerStart, vehicleMaxAccel: vehicleMaxAccel, odometerEnd: odometerEnd, endTime: endTime, tripLength: tripLength, tripDistance: tripDistance, tripLocationData: tripLocationData)
    }
    
    //saveTrip saves the trip to desired location
    private func saveTrip(numberOfTrip: Int){
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip"+String(numberOfTrip))
        if NSKeyedArchiver.archiveRootObject(self, toFile: currentArchiveURL.path){
            os_log("Trip successfully saved.", log: OSLog.default, type: .error)
        } else {
            os_log("FAILED to save Trip", log: OSLog.default, type: .error)
        }
    }
    
    //saveNewTrip() finds the location to save the trip
    private func saveNewTrip(){
        var count = 1
        while FileManager.default.fileExists(atPath: VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip"+String(count)).path) {
            count += 1
        }
        saveTrip(numberOfTrip: count)
    }
    
    func loadTrip(numberOfTrip: Int) -> TripData? {
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip"+String(numberOfTrip))
        return NSKeyedUnarchiver.unarchiveObject(withFile: currentArchiveURL.path) as? TripData
    }
    
    func deleteTrip(numberOfTrip: Int) {
        var tripCount = numberOfTrip
        while let tempTrip = loadTrip(numberOfTrip: tripCount + 1) {
            tempTrip.saveTrip(numberOfTrip: tripCount)
            tripCount += 1
        }
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip"+String(tripCount))
        do {
            try FileManager.default.removeItem(at: currentArchiveURL)
        } catch {
            os_log("Failed to delete trip", log: OSLog.default, type: .error)
        }
    }
}

class Location {
    //Mandatory Variables
    var timeStamp: Date = Date.init()
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    
    //Derived Variables
    var instSpeed: Double = 0
    var instAccel: Double = 0
    var efficiencyRatio: Double = 0
    
    init?(timeStamp: Date, latitude: Double, longitude: Double, distance: Double){
        self.timeStamp = timeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
    }
    
    init(){}
    
}

struct GlobalTripDataInstance {
    static var globalTrip: TripData?
    init (){
        GlobalTripDataInstance.globalTrip = TripData.init(vehicleID: 1, name: "", odometerStart: 0, vehicleMaxAccel: 4.8)
    }
}
