//
//  agacalc.swift
//  icome
//
//  Created by Tuo Zhang on 2015-11-28.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation

func age_calc(birthday:NSDate) -> NSInteger{
    let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    let now = NSDate()
    let components = gregorian?.components(NSCalendarUnit.Year, fromDate:birthday, toDate: now, options: NSCalendarOptions(rawValue: 0))
    let age = components?.year
    print(age)
    return age!
}
