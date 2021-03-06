//
//  Chamber.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20.02.2021.
//  Copyright © 2021 Flerov Laboratory. All rights reserved.
//

import Foundation

class Chamber {
    
    var sizeOrRadius: Float
    var thickness: Float
    var isCylindrical: Bool
    
    init(sizeOrRadius: Float, thickness: Float, isCylindrical: Bool) {
        self.sizeOrRadius = sizeOrRadius
        self.thickness = thickness
        self.isCylindrical = isCylindrical
    }
    
    func surfaces(_ indexes: [Int], shieldX: Float) -> String {
        let max = sizeOrRadius
        let min = sizeOrRadius - thickness
        if isCylindrical {
            return """
                \(indexes[0]) CZ \(min)  $ Internal Surface of Vacuum Chamber
                \(indexes[1]) CZ \(max) $ External Surface of Vacuum Chamber
                """
        } else {
            return """
                \(indexes[0]) RPP \(-min/2) \(min/2) \(-min/2) \(min/2) \(-shieldX) \(shieldX) $ Internal Surface of Vacuum Chamber
                \(indexes[1]) RPP \(-max/2) \(max/2) \(-max/2) \(max/2) \(-shieldX) \(shieldX) $ External Surface of Vacuum Chamber
                """
        }
    }
    
}
