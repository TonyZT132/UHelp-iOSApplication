//
//  RegisterTool.swift
//  icome
//
//  Created by Tuo Zhang on 2015-12-16.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation
import UIKit


func register_notification () {
    let settings = UIUserNotificationSettings(types: UIUserNotificationType([.alert, .badge, .sound]), categories: nil)
    UIApplication.shared.registerUserNotificationSettings(settings)
    UIApplication.shared.registerForRemoteNotifications()
    
    /*
    /*Check Authorization*/
    if(authorization == CLAuthorizationStatus.NotDetermined) {
        /*This shouldn't be run*/
        CLLocationManager().requestWhenInUseAuthorization()
    }
    */
}
