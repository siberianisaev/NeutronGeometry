//
//  Counter.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 18/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

enum HeliumPressure: Int {
    case low = 4, high = 7
    
    func realValue() -> Float {
        switch self {
        case .low:
            return 4.0
        default:
            return 7.0
        }
    }
    
}

class Counter {
    
    var lenght: Float {
        return 48.5
    }
    
    var radius: Float {
        switch presure {
        case .high:
            return 1.6
        default:
            return 1.5
        }
    }
    
    var presure: HeliumPressure = .high
    
    fileprivate var wallThikness: Float {
        return 0.05
    }
    
    var density: Float {
        return 0.000125 * Float(heliumPresure)
    }
    
    fileprivate var capTop: Float {
        return 3 - wallThikness
    }
    
    fileprivate var capBottom: Float {
        return 1 - wallThikness
    }
    
    fileprivate var _pzOutside: Float = 0
    
    var pzOutside: Float {
        return _pzOutside
    }
    
    var pzInside: Float {
        return pzOutside - wallThikness
    }
    
    var pzActiveAreaTop: Float {
        return pzInside - capTop
    }
    
    var pzActiveAreaBottom: Float {
        return pzInside - capBottom
    }
    
    var czOutside: Float {
        return radius
    }
    
    var czInside: Float {
        return czOutside - wallThikness
    }
    
    var czOutsideSpace: Float {
        return czOutside + 0.02
    }
    
    var heliumPresure: Int {
        return presure.rawValue
    }
    
    init(presure: HeliumPressure) {
        self.presure = presure
        self._pzOutside = lenght/2
    }
    
    /**
     He-3 area volume in cm^3.
     */
    func activeAreaVolume() -> Float {
        let base = Float.pi * pow(czInside, 2)
        let height = pzActiveAreaTop + pzActiveAreaBottom
        return base * height
    }
    
    /**
     Atoms count get from Mendeleev-Clapeyron equation converted to MCNP format.
     */
    func tallyCoefficient() -> Float {
        let presure = self.presure.realValue() * 101325 // Pa
        let volume = activeAreaVolume() / 1e6 // m^3
        let temperature: Float = 20 + 273.15 // °K
        let avogadro: Float = 0.602214085775 // * 1e-24
        let R: Float = 8.31445984849
        let coefficient = (presure * volume * avogadro) / (temperature * R) // atoms count * 1e-24
        return coefficient
    }
    
    func mcnpCells(startId id: Int, index: Int, TRCL: String) -> String {
        let start = startSurfaceId
        let density = self.density
        return """
        \nc ---------- Counter \(index) ---------------------------
        \(id) 3 -\(density) \(start+2) -\(start+3) -\(start+6) imp:n=1 u=\(index) $ Couter's SV
        \(id+1) 3 -\(density) \(start+1) -\(start+2) -\(start+6) imp:n=1 u=\(index) $ Lower Complementation to SV
        \(id+2) 3 -\(density) \(start+3) -\(start+4) -\(start+6) imp:n=1 u=\(index) $ Upper Complementation to SV
        \(id+3) 2 -7.91 \(start) -\(start+5) -\(start+7) (-\(start+1):\(start+4):\(start+6)) imp:n=1 u=\(index) $ Wall of Counter
        \(id+4) 0 (-\(start):\(start+5):\(start+7)) imp:n=1 u=\(index) $ Space around Counter
        \(id+5) 0 -\(start+8) -5 imp:n=1 fill=\(index) TRCL=(\(TRCL))
        """
    }
    
    fileprivate func convertSurfaceId(id: Int) -> Int {
        return presure == .high ? id : (id + 9)
    }
    
    fileprivate var startSurfaceId: Int {
        return convertSurfaceId(id: 51)
    }
    
    func mcnpSurfaces() -> String {
        let start = startSurfaceId
        return """
        c ***** Counter \(presure.rawValue) atm. *************************
        \(start) pz -\(pzOutside)
        \(start+1) pz -\(pzInside)
        \(start+2) pz -\(pzActiveAreaBottom)
        \(start+3) pz \(pzActiveAreaTop)
        \(start+4) pz \(pzInside)
        \(start+5) pz \(pzOutside)
        \(start+6) cz \(czInside)
        \(start+7) cz \(czOutside)
        \(start+8) cz \(czOutsideSpace)
        """
    }
    
}
