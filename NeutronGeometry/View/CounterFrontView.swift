//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa

class CounterFrontView: CounterView {
    
    var onCenterChanged: ((Bool)->())?
    var manuallySetCenter: Bool = false {
        didSet {
            drawBorder()
        }
    }
    
    fileprivate func drawBorder() {
        layer?.borderColor = (manuallySetCenter ? NSColor.white : NSColor.clear).cgColor
        layer?.borderWidth = manuallySetCenter ? 2 : 0
    }
    
    fileprivate var lastDragLocation: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1 {
            if manuallySetCenter { // restore center
                manuallySetCenter = false
                onCenterChanged?(manuallySetCenter)
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
            self.frame = frame
            lastDragLocation = new
            manuallySetCenter = true
            onCenterChanged?(manuallySetCenter)
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
    
    /**
     In centimeters.
     */
    func updateCenter(_ point: CGPoint?) {
        if let point = point {
            let frontSize = superview!.frame.size
            let center = CGPoint(x: frontSize.width/2, y: frontSize.height/2)
            var frame = self.frame
            let size = frame.size
            let x = (point.x * 10 - size.height/2 + center.x)
            let y = (point.y * 10 - size.height/2 + center.y)
            frame.origin = CGPoint(x: x, y: y)
            self.frame = frame
        }
        manuallySetCenter = point != nil
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        drawBorder()
    }
    
}
