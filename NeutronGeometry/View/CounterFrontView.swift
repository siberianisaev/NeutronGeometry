//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa

class CounterFrontView: CounterView {
    
    var index: Int = 0 {
        didSet {
            createLabel()
            label?.integerValue = index + 1
        }
    }
    
    var layerIndex: Int = 0
    var mcnpCellId: Int = 0
    
    /**
     In centimeters.
     */
    func center() -> CGPoint {
        let frontSize = superview!.frame.size
        let center = CGPoint(x: frontSize.width/2, y: frontSize.height/2)
        let size = frame.size
        let origin = frame.origin
        let x = (origin.x + size.height/2 - center.x)/10
        let y = (origin.y + size.height/2 - center.y)/10
        return CGPoint(x: x, y: y)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
