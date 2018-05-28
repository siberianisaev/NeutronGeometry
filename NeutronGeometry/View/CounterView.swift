//
//  CounterView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class CounterView: NSView {
    
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
