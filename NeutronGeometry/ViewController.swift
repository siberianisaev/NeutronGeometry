//
//  ViewController.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var layer1CountField: NSTextField!
    @IBOutlet weak var layer2CountField: NSTextField!
    @IBOutlet weak var layer3CountField: NSTextField!
    @IBOutlet weak var layer1RadiusField: NSTextField!
    @IBOutlet weak var layer2RadiusField: NSTextField!
    @IBOutlet weak var layer3RadiusField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    
    @IBAction func updateButton(_ sender: Any) {
        showChamber() // TODO: временно добавлено, есть небольшой сдвиг по Y при первом обновлении
        showCounters()
    }
    
    fileprivate var counters = [NSView]()
    fileprivate weak var chamberView: NSView?
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        showChamber()
        showCounters()
    }
    
    fileprivate func showChamber() {
        chamberView?.removeFromSuperview()
        let bounds = self.view.bounds
        let chamberDimention: CGFloat = 200 // 20 cm
        let chamberCenter = CGPoint(x: bounds.width/2 - chamberDimention/2, y: bounds.height/2 - chamberDimention/2)
        let view = NSView(frame: NSRect(x: chamberCenter.x, y: chamberCenter.y, width: chamberDimention, height: chamberDimention))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.view.addSubview(view)
        chamberView = view
    }
    
    fileprivate let counterRadius: CGFloat = 30 // 30 mm
    
    fileprivate func showCounters() {
        for view in counters {
            view.removeFromSuperview()
        }
        counters.removeAll()
        
        let minLayerRadius: CGFloat = 100
        let countersLayerCenterRadius1 = max(CGFloat(layer1RadiusField.floatValue), minLayerRadius) - counterRadius/2 // 20 cm - половина счетчика
        let countersLayerCenterRadius2 = max(CGFloat(layer2RadiusField.floatValue), minLayerRadius) - counterRadius/2 // 30 cm - половина счетчика
        let countersLayerCenterRadius3 = max(CGFloat(layer3RadiusField.floatValue), minLayerRadius) - counterRadius/2 // 40 cm - половина счетчика
        
        let minCountersPerLayer = 2
        let total1 = max(layer1CountField.integerValue, minCountersPerLayer)
        let total2 = max(layer2CountField.integerValue, minCountersPerLayer)
        let total3 = max(layer3CountField.integerValue, minCountersPerLayer)
        
        // Layer 1
        var paddingAngle: CGFloat = 0 // смещение угла относительно предыдущего ряда счетчиков (нужно по-максимуму закрыть промежутки между счетчиками чтобы увеличить эффективность)
        addCountersLayer(tag: 1, total: total1, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius1, color: NSColor.green)
        // Layer 2
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total1)) / 2
        addCountersLayer(tag: 2, total: total2, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius2, color: NSColor.red)
        // Layer 3
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total2)) / 2
        addCountersLayer(tag: 3, total: total3, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius3, color: NSColor.blue)
    }
    
    fileprivate func addCountersLayer(tag: Int, total: Int, paddingAngle: CGFloat, countersLayerCenterRadius: CGFloat, color: NSColor) {
        let bounds = self.view.bounds
        let center = CGPoint(x: bounds.width/2 - counterRadius/2, y: bounds.height/2 - counterRadius/2)
        for i in 0...total-1 {
            let angle = (CGFloat.pi * 2 * CGFloat(i)/CGFloat(total)) + paddingAngle // угл центра счетчика относительно оси OX
            let x = center.x + countersLayerCenterRadius * cos(angle)
            let y = center.y + countersLayerCenterRadius * sin(angle)
            let counterView = NSView(frame: NSRect(x: x, y: y, width: counterRadius, height: counterRadius))
            counterView.wantsLayer = true
            counterView.layer?.cornerRadius = counterRadius/2
            counterView.layer?.masksToBounds = true
            counterView.layer?.backgroundColor = color.cgColor
            self.view.addSubview(counterView)
            counters.append(counterView)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

