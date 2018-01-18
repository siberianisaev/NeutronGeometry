//
//  ProjectionView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 18/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ProjectionView: NSView {
    
    var step: Int = 25

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        wantsLayer = true
        layer?.borderColor = NSColor.black.cgColor
        layer?.borderWidth = 1
        layer?.backgroundColor = NSColor.white.cgColor
        
        NSBezierPath.defaultLineWidth = 1
        NSColor.cyan.withAlphaComponent(0.25).set()
        let count = Int(dirtyRect.width / CGFloat(step))
        for x in 0..<count {
            for y in 0..<count {
                let p1 = NSPoint(x: x * step, y: y * step)
                let p2 = NSPoint(x: (x+1) * step, y: y * step)
                let p3 = NSPoint(x: x * step, y: (y+1) * step)
                NSBezierPath.strokeLine(from: p1, to: p2)
                NSBezierPath.strokeLine(from: p1, to: p3)
            }
        }
        
    }
    
}
