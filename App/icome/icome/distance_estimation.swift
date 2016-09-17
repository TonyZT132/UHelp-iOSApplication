//
//  distance_estimation.swift
//  icome
//
//  Created by Tuo Zhang on 2015-11-24.
//  Copyright © 2015 iCome. All rights reserved.
//

import Foundation


func distance_calc (distance:Double) -> String {
    
    let distance_in_km = distance / 1000
    if(distance_in_km < 0.05){
        return "0.05 km 以内"
    }
    return (String(format: "%.2f", distance_in_km) + " km 以内")
    
}