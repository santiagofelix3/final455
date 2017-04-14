//
//  AppDelegate.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-27.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Creating a global instance that starts the GPS running on launch, this allows us to start getting accurate on the user before they start the trip.
        //Ideally, we would delay starting the trip until we get an accurate location, but that was out of scope
        GlobalTripDataInstance.globalTrip?.startTrip()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK: Shortcut Handler Methods
    //This function is for the long-press app launching
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        //This launches the app straight into adding a new vehicle
        if shortcutItem.type == "com.example.ONtheRoad.Add" {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let addVehicleVC = sb.instantiateViewController(withIdentifier: "AddVehicleNavigationVC") as! UINavigationController
            let root = UIApplication.shared.keyWindow?.rootViewController
            
            root?.present(addVehicleVC, animated: false, completion: { () -> Void in
                completionHandler(true)
            })
        }
        
        //This launches the app straight into your trip logs
        if shortcutItem.type == "com.example.ONtheRoad.Log" {
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let tripLogVC = sb.instantiateViewController(withIdentifier: "TripLogNavigationVC") as! UINavigationController
            let root = UIApplication.shared.keyWindow?.rootViewController
             
            root?.present(tripLogVC, animated: false, completion: { () -> Void in
            completionHandler(true)
            })
        }
        
        //This launches the app straight into the dashboard view controller and starts a new trip immediately
        if shortcutItem.type == "com.example.ONtheRoad.Start" {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let startTripVC = sb.instantiateViewController(withIdentifier: "MainVC")
            let root = UIApplication.shared.keyWindow?.rootViewController
            
            root?.present(startTripVC, animated: false, completion: { () -> Void in
                completionHandler(true)
            })

            print("Inside appDelegate about to call startStopEverything")
            GlobalTripDataInstance.shortcutFlag = 1
        }
    }
}
