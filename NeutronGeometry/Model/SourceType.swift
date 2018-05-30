//
//  SourceType.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 30/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

enum SourceType: Int, CaseCountable {
    case point = 0, disk = 1
    
    static let count = SourceType.countCases()
    
    func toggle() -> SourceType {
        return SourceType(rawValue: rawValue + 1) ?? .point
    }
    
    var name: String {
        switch self {
        case .point:
            return "Point"
        case .disk:
            return "Disk"
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .point:
            return 0
        case .disk:
            return 5
        }
    }
    
    /**
     Watt spectrum for 252Cf.
     */
    func card(_ positionZ: Float) -> String {
        var sdef = ["erg=d1", "pos=0 0 \(positionZ.stringWith(precision: 1))", "wgt=1.0"]
        if self == .disk {
            sdef.append(contentsOf: ["axs=0 0 1", "ext=0.0001", "rad=\(radius)"]) // cylinder with 10 cm base and degenerate 1 μm height, placed parallel on z-axis
        }
        let sdefString = sdef.joined(separator: " ")
        return """
        \nc ---------------- SOURCE ------------
        SDEF \(sdefString)
        SP1 -3 1.025 2.926
        """
    }
    
}
