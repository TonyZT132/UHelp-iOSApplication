//
//  agacalc.swift
//  icome
//
//  Created by Tuo Zhang on 2015-11-28.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation

func age_calc(_ birthday:Date) -> NSInteger{
    let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
    let now = Date()
    let components = (gregorian as NSCalendar?)?.components(NSCalendar.Unit.year, from:birthday, to: now, options: NSCalendar.Options(rawValue: 0))
    let age = components?.year
    print(age)
    return age!
}
