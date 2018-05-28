//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class CounterView: NSView {
    
    weak var label: NSTextField?
    
    func createLabel() {
        if nil == label {
            let labelHeight: CGFloat = 14
            let l = NSTextField(frame: NSRect(x: 0, y: frame.height/2 - labelHeight/2, width: frame.width, height: labelHeight))
            l.isBezeled = false
            l.drawsBackground = false
            l.isEditable = false
            l.isSelectable = false
            l.alignment = .center
            l.textColor = NSColor.white
            l.font = NSFont.boldSystemFont(ofSize: labelHeight - 4)
            addSubview(l)
            label = l
        }
    }
    
    var type: CounterType = .atm7Old {
        didSet {
            layer?.backgroundColor = type.color
        }
    }
    
    var onTap: (()->())?
    
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
