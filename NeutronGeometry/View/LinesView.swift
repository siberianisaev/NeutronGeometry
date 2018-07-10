//
//  LinesView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 10/07/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa

class LinesView: NSView {
    
    var points = [NSPoint]() {
        didSet {
            setNeedsDisplay(frame)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath()
        let count = points.count
        if count > 1 {
            let array = NSPointArray.allocate(capacity: count)
            for i in 0...count-1 {
                array[i] = points[i]
            }
            path.appendPoints(array, count: count)
        }
        NSColor.red.setStroke()
        path.lineWidth = 3
        path.close()
        path.stroke()
    }
    
}
