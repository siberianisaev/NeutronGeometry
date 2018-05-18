//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

enum HeliumPressure: Int {
    case low = 4, high = 7
}

class CounterView: NSView {
    
    weak var label: NSTextField?
    var index: Int = 0
    var layerIndex: Int = 0
    var mcnpCellId: Int = 0
    var presure: HeliumPressure = .high
    var onChangePresure: (()->())?
    
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
    
    override func mouseDown(with event: NSEvent) {
        //TODO: 4 atm counters support
        //onChangePresure?()
    }
    
}
