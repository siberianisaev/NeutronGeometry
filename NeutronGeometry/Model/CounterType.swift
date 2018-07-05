//
//  CounterType.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation
import Cocoa

enum CounterType: Int, CaseCountable {
    case aspekt = 0, flerov = 1, zaprudnya = 2, mayak = 3
    
    static let count = CounterType.countCases()
    
    func presure() -> Float {
        switch self {
        case .aspekt:
            return 4.0
        default:
            return 7.0
        }
    }
    
    var name: String {
        let prefix: String
        switch self {
        case .aspekt:
            prefix = "Aspekt"
        case .flerov:
            prefix = "Flerov Lab"
        case .zaprudnya:
            prefix = "Zaprudnya"
        case .mayak:
            prefix = "Mayak"
        }
        return "\(prefix), \(Int(presure())) atm."
    }
    
    var color: CGColor {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        switch self {
        case .aspekt:
            red = 217
            green = 110
            blue = 121
        case .flerov:
            red = 69
            green = 136
            blue = 237
        case .zaprudnya:
            red = 62
            green = 193
            blue = 133
        case .mayak:
            red = 228
            green = 153
            blue = 35
        }
        return NSColor(calibratedRed: red/255, green: green/255, blue: blue/255, alpha: 1.0).cgColor
    }
    
    func toggle() -> CounterType {
        return CounterType(rawValue: rawValue + 1) ?? .aspekt
    }
    
}
