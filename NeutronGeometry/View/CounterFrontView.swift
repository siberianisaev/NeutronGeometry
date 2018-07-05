//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa

class CounterFrontView: CounterView {
    
    var onPositionChanged: ((CGPoint?)->())?
    var originalPosition: CGPoint?
    var customPosition: CGPoint? {
        didSet {
            drawBorder()
        }
    }
    
    fileprivate func drawBorder() {
        var color: NSColor
        var width: CGFloat
        if let o = originalPosition, let c = customPosition, __CGPointEqualToPoint(o, c) == false {
            color = NSColor.white
            width = 2
        } else {
            color = NSColor.clear
            width = 0
        }
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
    }
    
    fileprivate var lastDragLocation: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1 {
            if let _ = customPosition { // restore position
                customPosition = nil
                onPositionChanged?(nil)
            }
            type = type.toggle()
            onTypeChanged?(type)
        } else {
            lastDragLocation = superview?.convert(event.locationInWindow, from: nil)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if let last = lastDragLocation, let new = superview?.convert(event.locationInWindow, from: nil) {
            var frame = self.frame
            frame.origin.x += -last.x + new.x
            frame.origin.y += -last.y + new.y
            let p = frame.origin
            customPosition = p
            lastDragLocation = new
            self.frame = frame
            onPositionChanged?(p)
        }
    }
    
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

        drawBorder()
    }
    
}
