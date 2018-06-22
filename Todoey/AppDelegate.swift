//
//  AppDelegate.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/3/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    
        do {
            let _ = try Realm() //we did the underscore because we are not using this variable "realm"
           // try realm.write {}          // commit the current state persistent storage to/from database
        } catch {
            print("Error initialising new realm, \(error)")
        }
        
        return true
    }
}

