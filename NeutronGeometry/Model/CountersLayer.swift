//
//  CountersLayer.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 03/07/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

class CountersLayer {
    
    var tag: Int = -1
    var count: Int = 0
    var radius: Float = 0
    var shiftAngle: Float = 0
    var evenAngle: Float = 0
    
    var gap: Float = 0
    
    init(tag: Int, count: Int? = nil, radius: Float? = nil, shiftAngle: Float? = nil, evenAngle: Float? = nil) {
        self.tag = tag
        self.count = count ?? tag * 5
        self.radius = radius ?? Float(tag * 30) + 100
        self.shiftAngle = shiftAngle ?? 0
        self.evenAngle = evenAngle ?? 0
    }
    
}
