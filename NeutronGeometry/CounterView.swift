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
    var presure: HeliumPressure = .high
    var onChangePresure: (()->())?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {
        onChangePresure?()
    }
    
}
