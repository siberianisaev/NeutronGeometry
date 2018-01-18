//
//  ViewController.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var counterRadius4AtmField: NSTextField!
    @IBOutlet weak var counterRadius7AtmField: NSTextField!
    @IBOutlet weak var layer1CountField: NSTextField!
    @IBOutlet weak var layer2CountField: NSTextField!
    @IBOutlet weak var layer3CountField: NSTextField!
    @IBOutlet weak var layer4CountField: NSTextField!
    @IBOutlet weak var layer1RadiusField: NSTextField!
    @IBOutlet weak var layer2RadiusField: NSTextField!
    @IBOutlet weak var layer3RadiusField: NSTextField!
    @IBOutlet weak var layer4RadiusField: NSTextField!
    @IBOutlet weak var chamberSizeField: NSTextField!
    @IBOutlet weak var barrelSizeField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var calculateButton: NSButton!
    @IBOutlet weak var layer4Control: NSButton!
    
    fileprivate var counters = [CounterView]()
    fileprivate weak var chamberView: NSView?
    fileprivate weak var barrelView: NSView?
    
    fileprivate var presures = [Int: HeliumPressure]()
    
    fileprivate func presureForCounterIndex(_ index: Int, tag: Int) -> HeliumPressure {
        return presures[index] ?? (tag == 4 ? .low : .high)
    }
    
    @IBAction func layer4Control(_ sender: Any) {
        let isOn = layer4Control.state == .on
        layer4RadiusField.isEnabled = isOn
        layer4CountField.isEnabled = isOn
        updateButton(nil)
    }
    
    @IBAction func updateButton(_ sender: Any?) {
        showBarrel() // TODO: временно добавлено, есть небольшой сдвиг по Y при первом обновлении
        showChamber() // TODO: временно добавлено, есть небольшой сдвиг по Y при первом обновлении
        showCounters()
    }
    
    @IBAction func calculateButton(_ sender: Any) {
        print("\nConfiguration results:")
        let bounds = self.view.bounds
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        for counter in counters {
            let origin = counter.frame.origin
            print("Counter: \(counter.index), center: (\(origin.x - center.x), \(origin.y - center.y)), presure: \(counter.presure.rawValue) atm.")
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        showBarrel()
        showChamber()
        showCounters()
    }
    
    fileprivate func showBarrel() {
        barrelView?.removeFromSuperview()
        let bounds = self.view.bounds
        let size = CGFloat(max(barrelSizeField.floatValue, 400))
        let center = CGPoint(x: bounds.width/2 - size/2, y: bounds.height/2 - size/2)
        let barrel = NSView(frame: NSRect(x: center.x, y: center.y, width: size, height: size))
        barrel.wantsLayer = true
        barrel.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.view.addSubview(barrel, positioned: .below, relativeTo: nil)
        barrelView = barrel
    }
    
    fileprivate func showChamber() {
        chamberView?.removeFromSuperview()
        let bounds = self.view.bounds
        let size = CGFloat(max(chamberSizeField.floatValue, 100))
        let center = CGPoint(x: bounds.width/2 - size/2, y: bounds.height/2 - size/2)
        let chamber = NSView(frame: NSRect(x: center.x, y: center.y, width: size, height: size))
        chamber.wantsLayer = true
        chamber.layer?.backgroundColor = NSColor.darkGray.cgColor
        self.view.addSubview(chamber)
        chamberView = chamber
    }
    
    fileprivate func counterRadiusForPresure(_ presure: HeliumPressure) -> CGFloat {
        let field = (presure == .high) ? counterRadius7AtmField : counterRadius4AtmField
        return CGFloat(max(field!.floatValue, 1))
    }
    
    fileprivate func layerRadiusFrom(_ textField: NSTextField) -> CGFloat {
        return max(CGFloat(textField.floatValue), 100)
    }
    
    fileprivate func layerCountFrom(_ textField: NSTextField) -> Int {
        return max(textField.integerValue, 2)
    }
    
    fileprivate func showCounters() {
        for view in counters {
            view.removeFromSuperview()
        }
        counters.removeAll()
        
        // Layer 1
        let countersLayerCenterRadius1 = layerRadiusFrom(layer1RadiusField)
        let total1 = layerCountFrom(layer1CountField)
        var paddingAngle: CGFloat = 0 // Смещение угла относительно предыдущего ряда счетчиков (нужно по-максимуму закрыть промежутки между счетчиками чтобы увеличить эффективность)
        addCountersLayer(tag: 1, total: total1, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius1)
        // Layer 2
        let countersLayerCenterRadius2 = layerRadiusFrom(layer2RadiusField)
        let total2 = layerCountFrom(layer2CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total1)) / 2
        addCountersLayer(tag: 2, total: total2, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius2)
        // Layer 3
        let countersLayerCenterRadius3 = layerRadiusFrom(layer3RadiusField)
        let total3 = layerCountFrom(layer3CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total2)) / 2
        addCountersLayer(tag: 3, total: total3, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius3)
        // Layer 4
        if layer4Control.state == .on {
            let countersLayerCenterRadius4 = layerRadiusFrom(layer4RadiusField)
            let total4 = layerCountFrom(layer4CountField)
            paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total3)) / 2
            addCountersLayer(tag: 4, total: total4, paddingAngle: paddingAngle, countersLayerCenterRadius: countersLayerCenterRadius4)
        }
    }
    
    fileprivate func addCountersLayer(tag: Int, total: Int, paddingAngle: CGFloat, countersLayerCenterRadius: CGFloat) {
        let bounds = self.view.bounds
        for i in 0...total-1 {
            let counterIndex = counters.count
            let presure = presureForCounterIndex(counterIndex, tag: tag)
            let counterRadius = counterRadiusForPresure(presure)
            let center = CGPoint(x: bounds.width/2 - counterRadius/2, y: bounds.height/2 - counterRadius/2)
            let angle = (CGFloat.pi * 2 * CGFloat(i)/CGFloat(total)) + paddingAngle // Угл центра счетчика относительно оси OX
            let layerCenter = countersLayerCenterRadius - counterRadius/2 // Вычитаем половину счетчика из заданного радиуса
            let x = center.x + layerCenter * cos(angle)
            let y = center.y + layerCenter * sin(angle)
            let frame = NSRect(x: x, y: y, width: counterRadius, height: counterRadius)
            
            let counter = CounterView(frame: frame)
            counter.index = counterIndex
            counter.presure = presure
            counter.onChangePresure = { [weak self] in
                self?.presures[counterIndex] = presure == .high ? .low : .high
                self?.showCounters() // TODO: optimisation, refresh single counter
            }
            counter.wantsLayer = true
            counter.layer?.cornerRadius = counterRadius/2
            counter.layer?.masksToBounds = true
            let color = presure == .high ? NSColor.blue : NSColor.red
            counter.layer?.backgroundColor = color.cgColor
            
            let label = NSTextField(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
            label.isBezeled = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.alignment = .center
            label.textColor = NSColor.white
            label.font = NSFont.boldSystemFont(ofSize: 12)
            label.integerValue = counterIndex
            counter.addSubview(label)
            counter.label = label
            
            self.view.addSubview(counter)
            counters.append(counter)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

