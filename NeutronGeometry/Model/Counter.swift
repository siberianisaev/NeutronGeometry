//
//  Counter.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 18/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation
import Cocoa

enum CounterType: Int {
    case atm4 = 0, atm7Old = 1, atm7New = 2
    
    func presure() -> Float {
        switch self {
        case .atm4:
            return 4.0
        default:
            return 7.0
        }
    }
    
    var name: String {
        let prefix: String
        switch self {
        case .atm4, .atm7Old:
            prefix = "Old"
        case .atm7New:
            prefix = "New"
        }
        return "\(prefix) - \(presure())"
    }
    
    var color: CGColor {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        switch self {
        case .atm4:
            red = 217
            green = 110
            blue = 121
        case .atm7Old:
            red = 69
            green = 136
            blue = 237
        case .atm7New:
            red = 62
            green = 193
            blue = 133
        }
        return NSColor(calibratedRed: red/255, green: green/255, blue: blue/255, alpha: 1.0).cgColor
    }
    
    func toggle() -> CounterType {
        return CounterType(rawValue: rawValue + 1) ?? .atm4
    }
    
}

class Counter {
    
    var lenght: Float {
        switch type {
        case .atm4:
            return 49.0
        case .atm7Old:
            return 48.5
        case .atm7New:
            return 50
        }
    }
    
    var radius: Float {
        switch type {
        case .atm4:
            return 1.5
        default:
            return 1.6
        }
    }
    
    var type: CounterType = .atm7Old
    
    fileprivate var wallThikness: Float {
        return 0.05
    }
    
    var density: Float {
        return 0.000125 * type.presure()
    }
    
    var capTop: Float {
        var value: Float
        switch type {
        case .atm4:
            value = 1.5
        case .atm7Old:
            value = 3
        case .atm7New:
            value = 1.5
        }
        return value - wallThikness
    }
    
    var capBottom: Float {
        var value: Float
        switch type {
        case .atm4:
            value = 1.5
        case .atm7Old:
            value = 1
        case .atm7New:
            value = 1.5
        }
        return value - wallThikness
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
    
    init(type: CounterType) {
        self.type = type
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
        let presure = type.presure() * 101325 // Pa
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
        return id + (type.rawValue * 9)
    }
    
    fileprivate var startSurfaceId: Int {
        return convertSurfaceId(id: 51)
    }
    
    func mcnpSurfaces() -> String {
        let start = startSurfaceId
        return """
        c ***** Counter \(type.name) *************************
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
