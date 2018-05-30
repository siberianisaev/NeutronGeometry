//
//  SourceView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 30/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class SourceView: NSView {
    
    fileprivate var onTap: (()->())?
    
    init(type: SourceType, shift: CGFloat = 0, containerFrame: CGRect, projection: Projection?, onTap: @escaping (()->())) {
        self.onTap = onTap
        
        let height: CGFloat = type == .disk ? (type.radius * 2 * 10) : 28
        let width = (projection == .side && type == .disk) ? 5 : height
        let frame = NSRect(x: containerFrame.width/2 - width/2 + shift, y: containerFrame.height/2 - height/2, width: width, height: height)
        super.init(frame: frame)
        
        if type == .point {
            let imageView = NSImageView(frame: bounds)
            imageView.image = #imageLiteral(resourceName: "source")
            addSubview(imageView)
        } else {
            wantsLayer = true
            layer?.backgroundColor = NSColor.red.cgColor
            layer?.cornerRadius = projection == .front ? height/2 : 0
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        onTap?()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
