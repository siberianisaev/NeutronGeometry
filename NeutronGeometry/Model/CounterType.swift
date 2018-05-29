//
//  CounterType.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation
import Cocoa

enum CounterType: Int, CaseCountable {
    case atm4 = 0, atm7Old = 1, atm7New = 2
    
    static let count = CounterType.countCases()
    
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
        case .atm4:
            prefix = "Aspekt"
        case .atm7Old:
            prefix = "Flerov Lab"
        case .atm7New:
            prefix = "Zaprudnya"
        }
        return "\(prefix), \(Int(presure())) atm."
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
