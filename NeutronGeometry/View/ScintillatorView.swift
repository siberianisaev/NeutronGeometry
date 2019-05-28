//
//  ScintillatorView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2019.
//  Copyright © 2019 Flerov Laboratory. All rights reserved.
//

import Cocoa

class ScintillatorView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.7).cgColor
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
}
