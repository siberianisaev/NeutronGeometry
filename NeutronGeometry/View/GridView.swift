//
//  GridView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 11/02/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class GridView: NSView {
    
    var step: Int = 10
    
    init(frame frameRect: NSRect, step: Int) {
        super.init(frame: frameRect)
        
        self.step = step
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSBezierPath.defaultLineWidth = 1
        NSColor.cyan.withAlphaComponent(0.25).set()
        let count = Int(dirtyRect.width / CGFloat(step))
        for x in 0...count {
            for y in 0...count {
                let p1 = NSPoint(x: x * step, y: y * step)
                let p2 = NSPoint(x: (x+1) * step, y: y * step)
                let p3 = NSPoint(x: x * step, y: (y+1) * step)
                NSBezierPath.strokeLine(from: p1, to: p2)
                NSBezierPath.strokeLine(from: p1, to: p3)
            }
        }
    }
    
}
