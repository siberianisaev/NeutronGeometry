//
//  ChamberView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 11/02/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ChamberView: NSView {
    
    fileprivate weak var internalView: NSView?
    
    init(frame frameRect: NSRect, thickness: CGFloat) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.green.withAlphaComponent(0.7).cgColor
        addInternalView(thickness)
    }
    
    fileprivate func addInternalView(_ thickness: CGFloat) {
        let rect = NSRect(x: thickness, y: thickness, width: frame.width - 2*thickness, height: frame.height - 2*thickness)
        let view = NSView(frame: rect)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        addSubview(view)
        internalView = view
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        addInternalView(1.0)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
