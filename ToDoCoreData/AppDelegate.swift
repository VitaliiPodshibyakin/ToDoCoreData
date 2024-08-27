//
//  AppDelegate.swift
//  ToDoCoreData
//
//  Created by Виталий Подшибякин on 27.08.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: TaskListViewController())
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        StorageManager.shared.saveContext()
    }
}


