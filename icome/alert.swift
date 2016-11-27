//
//  alert.swift
//  icome
//
//  Created by Tuo Zhang on 2015-12-14.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation
import UIKit

func show_alert_one_button(_ title:String, message: String?, actionButton:String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction(title: actionButton, style: UIAlertActionStyle.default ,handler: nil )
    alert.addAction(action)
    return alert
}

