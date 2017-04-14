//  TripData contains all methods and elements needed for storing and manipulating a trip
//
//

import UIKit
import CoreLocation
import MapKit
import CoreData
import os.log


class TripData: NSObject, NSCoding, CLLocationManagerDelegate{
    
    //Mandatory Variables
    var locationManager: CLLocationManager!
    var startTime: Date = Date.init()
    var vehiclePhoto: UIImage
    var started = 0
    
    //Optional Input Variables
    var name: String?
    var odometerStart: Int = 0
    var vehicleMaxAccel: Double = 0.0
    //Just giving this guy a initial value as a safety
    var vehicleActual = 6.8

    
    //End of Trip Variables
    var odometerEnd: Int = 0
    var endTime: Date = Date.distantFuture
    var tripLength: Double = 0.0
    var tripDistance: Double = 0.0
    
    //Array for storing each location point
    var tripLocationData = [Location]()
    
    lazy var locations = [CLLocation]()
    
    static var totalNumberOfTrips: Int = 0

    init?(vehiclePhoto: UIImage, name: String, odometerStart: Int, vehicleMaxAccel: Double, vehicleActual: Double){
        self.startTime = Date.init()
        self.vehiclePhoto = vehiclePhoto
        self.name = name
        self.odometerStart = odometerStart
        self.vehicleMaxAccel = vehicleMaxAccel
        self.vehicleActual = vehicleActual
    }
    
    override init() {
        self.vehiclePhoto = #imageLiteral(resourceName: "defaultPhoto")
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
        locationManager.startUpdatingLocation()
    }
    
    //Stops the trip
    func endTrip(){
        locationManager.stopUpdatingLocation()
        //Safety to make sure we only store user started trips
        if (started == 1) {
            saveNewTrip()
        }
        started = 0
        endTime = Date.init()
    }
    
    //locationManager() is called everytime the GPS updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //for each location the GPS returns, update tripLocationData with a new Location
        for location in locations{

            //If locations is not empty, get the distance and time since the last stamp
            if self.locations.count > 1 {
                let distanceSinceLast = location.distance(from: self.locations.last!)
                let timeSinceLast = Double(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                //Doing a check against the users distance traveled, if it is a huge number we assume there was a blip of GPS accuracy and we are not saving that reading
                if (distanceSinceLast < 45.0) {
                    addCLLocation(location: location, distanceSinceLast: distanceSinceLast, timeSinceLast: timeSinceLast)
                }
            }
            self.locations.append(location)
        }
    }
    
    //Pruning off our wanted data from the CLLocation object
    func addCLLocation(location: CLLocation, distanceSinceLast: Double, timeSinceLast: Double)
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
        //Getting the time
        self.tripLength += timeSinceLast
        //Getting the current speed
        tempLocation.instSpeed = (tempLocation.distance)
        //Getting the accel
        if tripLocationData.count > 1 {
            tempLocation.instAccel = (tempLocation.instSpeed - self.tripLocationData[tripLocationData.count-1].instSpeed) / timeSinceLast
        }
        //Getting the effRatio, this guy is just a rough metric we've come up with through a bit of reading.
        tempLocation.efficiencyRatio = abs(tempLocation.instAccel/(vehicleMaxAccel))+1
        if (tempLocation.efficiencyRatio > 1.9){
            tempLocation.efficiencyRatio = 1.9
        }
        
        //Adding all the wanted variables onto the end of our tracking array
        self.tripLocationData.append(tempLocation)
    }
    
    // MARK: Permanent Storage
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    struct PropertyKey {
        static var startTime = "startTime"
        static var vehiclePhoto = "vehiclePhoto"
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
        aCoder.encode(vehiclePhoto, forKey: PropertyKey.vehiclePhoto)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(odometerStart, forKey: PropertyKey.odometerStart)
        aCoder.encode(vehicleMaxAccel, forKey: PropertyKey.vehicleMaxAccel)
        aCoder.encode(odometerEnd,  forKey: PropertyKey.odometerEnd)
        aCoder.encode(endTime, forKey: PropertyKey.endTime)
        aCoder.encode(tripLength, forKey: PropertyKey.tripLength)
        aCoder.encode(tripDistance, forKey: PropertyKey.tripDistance)
        aCoder.encode(tripLocationData, forKey: PropertyKey.tripLocationData)
    }
    
    init(startTime: Date, vehiclePhoto: UIImage, name: String, odometerStart: Int, vehicleMaxAccel: Double, odometerEnd: Int, endTime: Date, tripLength: Double, tripDistance: Double, tripLocationData: [Location]) {
        self.startTime = startTime
        self.vehiclePhoto = vehiclePhoto
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
        let startTime = aDecoder.decodeObject(forKey: PropertyKey.startTime) as! Date
        let vehiclePhoto = aDecoder.decodeObject(forKey: PropertyKey.vehiclePhoto) as! UIImage
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
        let odometerStart = aDecoder.decodeInteger(forKey: PropertyKey.odometerStart) as Int
        let vehicleMaxAccel = aDecoder.decodeDouble(forKey: PropertyKey.vehicleMaxAccel)
        let odometerEnd = aDecoder.decodeInteger(forKey: PropertyKey.odometerEnd) as Int
        let endTime = aDecoder.decodeObject(forKey: PropertyKey.endTime) as! Date
        let tripLength = aDecoder.decodeDouble(forKey: PropertyKey.tripLength) as Double
        let tripDistance = aDecoder.decodeDouble(forKey: PropertyKey.tripDistance) as Double
        let tripLocationData = aDecoder.decodeObject(forKey: PropertyKey.tripLocationData) as! [Location]
    
        self.init(startTime: startTime, vehiclePhoto: vehiclePhoto, name: name, odometerStart: odometerStart, vehicleMaxAccel: vehicleMaxAccel, odometerEnd: odometerEnd, endTime: endTime, tripLength: tripLength, tripDistance: tripDistance, tripLocationData: tripLocationData)
    }
    
    // MARK: Permanent Storage Operations
    //////////////// 

    
    //saveTrip saves the trip to desired location
    private func saveTrip(numberOfTrip: Int) {
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip" + String(numberOfTrip))
        if NSKeyedArchiver.archiveRootObject(self, toFile: currentArchiveURL.path){
            os_log("New Trip successfully saved.", log: OSLog.default, type: .error)
        } else {
            os_log("FAILED to save Trip", log: OSLog.default, type: .error)
        }
    }
    
    //saveNewTrip() finds the first empty location to save the trip
    private func saveNewTrip() {
        var count = 1
        while FileManager.default.fileExists(atPath: VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip"+String(count)).path) {
            count += 1
        }
        saveTrip(numberOfTrip: count)
    }
    
    //loadTrip loads the trip from the specified location and returns it as an object
    func loadTrip(numberOfTrip: Int) -> TripData? {
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip" + String(numberOfTrip))
        let temp = NSKeyedUnarchiver.unarchiveObject(withFile: currentArchiveURL.path) as? TripData

        return temp
    }
    
    //shiftTripUp moves a trip up one storage location
    private func shiftTripUp(numberOfTrip: Int) {
        let tripCount = numberOfTrip
        let currentArchiveURL = VehicleProfile.DocumentsDirectory.appendingPathComponent("Trip" + String(tripCount))
        if NSKeyedArchiver.archiveRootObject(self, toFile: currentArchiveURL.path){
            os_log("Shifted Trip successfully saved.", log: OSLog.default, type: .error)
        } else {
            os_log("FAILED to save Trip", log: OSLog.default, type: .error)
        }
    }
    
    //deleteTrip removes the trip and shifts trips up into the newly empty spot
    func deleteTrip(numberOfTrip: Int) {
        var tripCount = numberOfTrip
        while let tempTrip = loadTrip(numberOfTrip: tripCount + 1) {
            tempTrip.shiftTripUp(numberOfTrip: tripCount)
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

//Location calculates and stores all the knowledge needed about an individual location
class Location: NSObject, NSCoding {
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
    
    override init(){}
    
    private init(timeStamp: Date, latitude: Double, longitude: Double, distance: Double, instSpeed: Double, instAccel: Double, efficiencyRatio: Double) {
        self.timeStamp = timeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.distance = distance
        self.instSpeed = instSpeed
        self.instAccel = instAccel
        self.efficiencyRatio = efficiencyRatio
    }
    
    struct PropertyKey {
        static var timeStamp = "timeStamp"
        static var latitude = "latitude"
        static var longitude = "longitude"
        static var distance = "distance"
        static var instSpeed = "instSpeed"
        static var instAccel = "instAccel"
        static var efficiencyRatio = "efficiencyRatio"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timeStamp, forKey: PropertyKey.timeStamp)
        aCoder.encode(latitude, forKey: PropertyKey.latitude)
        aCoder.encode(longitude, forKey: PropertyKey.longitude)
        aCoder.encode(distance, forKey: PropertyKey.distance)
        aCoder.encode(instSpeed, forKey: PropertyKey.instSpeed)
        aCoder.encode(instAccel, forKey: PropertyKey.instAccel)
        aCoder.encode(efficiencyRatio, forKey: PropertyKey.efficiencyRatio)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let timeStamp = aDecoder.decodeObject(forKey: PropertyKey.timeStamp) as? Date else {
            os_log("Unable to decode the timeStamp for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude) as Double? else {
            os_log("Unable to decode the latitude for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude) as Double? else {
            os_log("Unable to decode the longitude for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let distance = aDecoder.decodeDouble(forKey: PropertyKey.distance) as Double? else {
            os_log("Unable to decode the distance for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let instSpeed = aDecoder.decodeDouble(forKey: PropertyKey.instSpeed) as Double? else {
            os_log("Unable to decode the instSpeed for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let instAccel = aDecoder.decodeDouble(forKey: PropertyKey.instAccel) as Double? else {
            os_log("Unable to decode the instAccel for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let efficiencyRatio = aDecoder.decodeDouble(forKey: PropertyKey.efficiencyRatio) as Double? else {
            os_log("Unable to decode the efficiencyRatio for a Vehicle object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(timeStamp: timeStamp, latitude: latitude, longitude: longitude, distance: distance, instSpeed: instSpeed, instAccel: instAccel, efficiencyRatio: efficiencyRatio)
        
    }
}

//Creating a global default item for priming gps and filling in some blanks
struct GlobalTripDataInstance {
    static var globalTrip: TripData?
    static var shortcutFlag = 0 //Global variable for allowing a trip to start from icon
    init (){
        GlobalTripDataInstance.globalTrip = TripData.init(vehiclePhoto: #imageLiteral(resourceName: "defaultPhoto"), name: "", odometerStart: 0, vehicleMaxAccel: 4.8, vehicleActual: 6.8)
    }
}
