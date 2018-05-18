//
//  Counter.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 18/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

class Counter {
    
    var lenght: Float = 0
    var radius: Float = 0
    var presure: HeliumPressure = .high
    
    fileprivate let wallThikness: Float = 0.08
    fileprivate let cap: Float = 1.42
    
    fileprivate var _pzOutside: Float = 0
    
    var pzOutside: Float {
        return _pzOutside
    }
    
    var pzInside: Float {
        return pzOutside - wallThikness
    }
    
    var pzActiveArea: Float {
        return pzInside - cap
    }
    
    var czOutside: Float {
        return radius/10
    }
    
    var czInside: Float {
        return czOutside - wallThikness
    }
    
    var czOutsideSpace: Float {
        return czOutside + 0.02
    }
    
    init(lenght: Float, radius: Float, presure: HeliumPressure) {
        self.lenght = lenght
        self.radius = radius
        self.presure = presure
        self._pzOutside = lenght/2
    }
    
    /**
     He-3 area volume in cm^3.
     */
    func activeAreaVolume() -> Float {
        let base = Float.pi * pow(czInside, 2)
        let height = pzActiveArea * 2
        return base * height
    }
    
    func tallyCoefficient() -> Float {
        let presure = Float(self.presure.rawValue) // atmospheres
        let volume = activeAreaVolume() / 1000.0 // liters
        let temperature: Float = 293 // K
        let moleCount = (presure * volume) / (temperature * 0.0821)
        let coefficient = moleCount * 0.60221413 // atoms count (mole * Avogadro) * 10^24
        return coefficient
//        return presure * coefficient / 10
    }
    
}
