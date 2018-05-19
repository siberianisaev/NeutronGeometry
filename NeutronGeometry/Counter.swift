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
    
    let argonPresure: Int = 2
    
    var heliumPresure: Int {
        return presure.rawValue
    }
    
    fileprivate var totalPresure: Float {
        return Float(argonPresure + heliumPresure)
    }
    
    var heliumFraction: Float {
        let precision = 100000
        let fraction = round(Float(heliumPresure)/totalPresure * Float(precision))
        return fraction/Float(precision)
    }
    
    var argonFraction: Float {
        return 1 - heliumFraction
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
    
    /**
     Atoms count get from Mendeleev-Clapeyron equation converted to MCNP format.
     */
    func tallyCoefficient() -> Float {
        let presure = Float(heliumPresure) * 101325 // Pa
        let volume = activeAreaVolume() / 1e6 // m^3
        let temperature: Float = 20 + 273.15 // °K
        let avogadro: Float = 0.602214085775 // * 1e-24
        let R: Float = 8.31445984849
        let coefficient = (presure * volume * avogadro) / (temperature * R) // atoms count * 1e-24
        return coefficient
    }
    
}
