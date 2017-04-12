//
//  MulticolorPolylineSegment.swift
//  ONtheRoad
//
//  Created by Michael Dickenson on 2017-04-04.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MulticolorPolylineSegment: MKPolyline {
    var color: UIColor?
    
    //Class for storing all the speed measurements
    class func colorSegments(forLocations locations: [Location]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()
        
        // RGB for Red (slowest)
        let red   = (r: 1.0, g: 20.0 / 255.0, b: 44.0 / 255.0)
        
        // RGB for Yellow (middle)
        let yellow = (r: 1.0, g: 215.0 / 255.0, b: 0.0)
        
        // RGB for Green (fastest)
        let green  = (r: 0.0, g: 146.0 / 255.0, b: 78.0 / 255.0)
        
        var speeds = [Double]()
        var accels = [Double]() //Variable for accel, (delta V)/(delta time). (distance/time)/time.
        
        for i in 1..<locations.count-1 {
            //Grabbing a slice of travel
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            var coords = [CLLocationCoordinate2D]()
            coords.append(CLLocationCoordinate2D(latitude: l1.latitude, longitude: l1.longitude))
            coords.append(CLLocationCoordinate2D(latitude: l2.latitude, longitude: l2.longitude))
            
            print ("*********")
            //test printing the variables
            let distance = l1.distance
            print ("d:", distance)
            let time = l1.timeStamp
            print ("t: ", time)
            //Creating an array of speeds
            let speed = l1.instSpeed
            print ("s: ", speed)
            speeds.append(speed)
            //Creating an array of accel
            let accel = l1.instAccel
            print ("a: ", accel)
            accels.append(accel)
            print ("*********")
            
            let ratio = l1.efficiencyRatio
            var color = UIColor.black
            
            if (abs(accel) > ratio) { // Between Red & Yellow
                let r = CGFloat(red.r + ratio * (yellow.r - red.r))
                let g = CGFloat(red.g + ratio * (yellow.g - red.g))
                let b = CGFloat(red.b + ratio * (yellow.b - red.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            else { // Between Yellow & Green
                let r = CGFloat(yellow.r + ratio * (green.r - yellow.r))
                let g = CGFloat(yellow.g + ratio * (green.g - yellow.g))
                let b = CGFloat(yellow.b + ratio * (green.b - yellow.b))
                color = UIColor(red: r, green: g, blue: b, alpha: 1)
            }
            
            //Defining each segment of coloured line
            //We will need to make sure our measurement of segment stays consistent throughout the app
            let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
            segment.color = color
            colorSegments.append(segment)
        }
        return colorSegments
    }
}

