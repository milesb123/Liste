//
//  CostController.swift
//  Liste
//
//  Created by Miles Broomfield on 28/02/2021.
//

import Foundation

class CostController{
    
    static func getPricePoundsForPostCount(count:Int) -> Double{
        return round2DP(4.9+0.1*pow(M_E,1.3*pow(10,-5)*Double(count)))
    }
    
    static func round2DP(_ double:Double) -> Double{
        return Double(round(1000*double)/1000)
    }
    
}
