//
//  CounterSideView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 28/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class CounterSideView: CounterView {
    
    fileprivate weak var capTop: NSView?
    fileprivate weak var capBottom: NSView?
    
    fileprivate func addCap(_ x: CGFloat, width: CGFloat) -> NSView {
        let rect = CGRect(x: x, y: 0, width: width, height: frame.height)
        let view = NSView(frame: rect)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.33).cgColor
        addSubview(view)
        return view
    }
    
    func showCaps() {
        capTop?.removeFromSuperview()
        capBottom?.removeFromSuperview()
        let counter = Counter(type: type)
        capTop = addCap(0, width: CGFloat(counter.capTop * 10))
        let bottomWidth = CGFloat(counter.capBottom * 10)
        capBottom = addCap(frame.width-bottomWidth, width: bottomWidth)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
