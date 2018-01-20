//
//  ViewController.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    enum Projection {
        case front, side
    }

    @IBOutlet weak var frontView: ProjectionView!
    @IBOutlet weak var sideView: ProjectionView!
    @IBOutlet weak var counterRadius4AtmField: NSTextField!
    @IBOutlet weak var counterRadius7AtmField: NSTextField!
    @IBOutlet weak var counterLenghtField: NSTextField!
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
    @IBOutlet weak var barrelLenghtField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var calculateButton: NSButton!
    @IBOutlet weak var layer4Control: NSButton!
    @IBOutlet weak var gridStepField: NSTextField!
    
    fileprivate var countersFront = [CounterView]()
    fileprivate weak var chamberFrontView: NSView?
    fileprivate weak var barrelFrontView: NSView?
    fileprivate var countersSide = [NSView]()
    fileprivate weak var chamberSideView: NSView?
    fileprivate weak var barrelSideView: NSView?
    
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
        setupProjections()
        showBarrelFront()
        showChamberFront()
        showCountersFront()
        showBarrelSide()
        showChamberSide()
        showCountersSide()
    }
    
    @IBAction func calculateButton(_ sender: Any) {
        print("\nConfiguration results:")
        let frontSize = frontView.frame.size
        let center = CGPoint(x: frontSize.width/2, y: frontSize.height/2)
        for counter in countersFront {
            let frame = counter.frame
            let size = frame.size
            let origin = frame.origin
            print("Counter: \(counter.index), center: (\(origin.x + size.height/2 - center.x), \(origin.y + size.height/2 - center.y)), presure: \(counter.presure.rawValue) atm.")
        }
        print("Barrel size: \(barrelSizeField.floatValue)")
        print("Barrel lenght: \(barrelLenghtField.floatValue)")
        print("Counter lenght: \(counterLenghtField.floatValue)")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        updateButton(nil)
    }
    
    fileprivate func setupProjections() {
        let newStep = max(gridStepField.integerValue, 1)
        for view in [frontView, sideView] as [ProjectionView] {
            if view.step != newStep {
                view.step = newStep
                view.setNeedsDisplay(view.visibleRect)
            }
        }
    }
    
    fileprivate func containerFor(_ projection: Projection) -> NSView {
        return projection == .front ? frontView : sideView
    }
    
    fileprivate func showBarrel(_ projection: Projection) {
        let isFront = projection == .front
        (isFront ? barrelFrontView : barrelSideView)?.removeFromSuperview()
        let width = CGFloat((isFront ? barrelSizeField : barrelLenghtField)!.floatValue)
        let height = CGFloat(barrelSizeField.floatValue)
        let container = containerFor(projection)
        let containerSize = container.frame.size
        let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 - height/2)
        let barrel = NSView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
        barrel.wantsLayer = true
        barrel.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        container.addSubview(barrel)
        isFront ? (barrelFrontView = barrel) : (barrelSideView = barrel)
    }
    
    fileprivate func showBarrelSide() {
        showBarrel(.side)
    }
    
    fileprivate func showBarrelFront() {
        showBarrel(.front)
    }
    
    fileprivate func showChamber(_ projection: Projection) {
        let isFront = projection == .front
        (isFront ? chamberFrontView : chamberSideView)?.removeFromSuperview()
        let width = isFront ? CGFloat(chamberSizeField.floatValue) : CGFloat(barrelLenghtField.floatValue)
        let height = CGFloat(chamberSizeField.floatValue)
        let container = containerFor(projection)
        let containerSize = container.frame.size
        let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 - height/2)
        let chamber = NSView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
        chamber.wantsLayer = true
        chamber.layer?.backgroundColor = NSColor.brown.withAlphaComponent(0.7).cgColor
        container.addSubview(chamber)
        isFront ? (chamberFrontView = chamber) : (chamberSideView = chamber)
    }
    
    fileprivate func showChamberSide() {
        showChamber(.side)
    }
    
    fileprivate func showChamberFront() {
        showChamber(.front)
    }
    
    fileprivate func showCountersSide(_ raduisField: NSTextField, tag: Int) {
        let layerCenter = layerRadiusFrom(raduisField)
        let width = CGFloat(counterLenghtField.floatValue)
        let presure: HeliumPressure = tag == 4 ? .low : .high
        let height = counterRadiusForPresure(presure)
        let container = containerFor(.side)
        let containerSize = container.frame.size
        let zArray = [1, -1] as [CGFloat]
        for z in zArray {
            let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 + z * layerCenter - height/2) // +- layerCenter
            let counter = NSView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
            counter.wantsLayer = true
            counter.layer?.backgroundColor = counterColorForPresure(presure)
            container.addSubview(counter)
            countersSide.append(counter)
        }
    }
    
    fileprivate func showCountersSide() {
        for view in countersSide {
            view.removeFromSuperview()
        }
        countersSide.removeAll()
        
        var fields = [layer1RadiusField, layer2RadiusField, layer3RadiusField] as [NSTextField]
        if layer4Control.state == .on {
            fields.append(layer4RadiusField)
        }
        for field in fields {
            showCountersSide(field, tag: 1 + fields.index(of: field)!)
        }
    }
    
    fileprivate func counterColorForPresure(_ presure: HeliumPressure) -> CGColor {
        return (presure == .high ? NSColor.blue : NSColor.red).cgColor
    }
    
    fileprivate func counterRadiusForPresure(_ presure: HeliumPressure) -> CGFloat {
        let field = (presure == .high) ? counterRadius7AtmField : counterRadius4AtmField
        return CGFloat(max(field!.floatValue, 1))
    }
    
    fileprivate func layerRadiusFrom(_ textField: NSTextField) -> CGFloat {
        return max(CGFloat(textField.floatValue), 10)
    }
    
    fileprivate func layerCountFrom(_ textField: NSTextField) -> Int {
        return max(textField.integerValue, 2)
    }
    
    fileprivate func showCountersFront() {
        for view in countersFront {
            view.removeFromSuperview()
        }
        countersFront.removeAll()
        
        // Layer 1
        let layerCenter1 = layerRadiusFrom(layer1RadiusField)
        let total1 = layerCountFrom(layer1CountField)
        var paddingAngle: CGFloat = 0 // Смещение угла относительно предыдущего ряда счетчиков (нужно по-максимуму закрыть промежутки между счетчиками чтобы увеличить эффективность)
        addCountersLayerFront(tag: 1, total: total1, paddingAngle: paddingAngle, layerCenter: layerCenter1)
        // Layer 2
        let layerCenter2 = layerRadiusFrom(layer2RadiusField)
        let total2 = layerCountFrom(layer2CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total1)) / 2
        addCountersLayerFront(tag: 2, total: total2, paddingAngle: paddingAngle, layerCenter: layerCenter2)
        // Layer 3
        let layerCenter3 = layerRadiusFrom(layer3RadiusField)
        let total3 = layerCountFrom(layer3CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total2)) / 2
        addCountersLayerFront(tag: 3, total: total3, paddingAngle: paddingAngle, layerCenter: layerCenter3)
        // Layer 4
        if layer4Control.state == .on {
            let layerCenter4 = layerRadiusFrom(layer4RadiusField)
            let total4 = layerCountFrom(layer4CountField)
            paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total3)) / 2
            addCountersLayerFront(tag: 4, total: total4, paddingAngle: paddingAngle, layerCenter: layerCenter4)
        }
    }
    
    fileprivate func addCountersLayerFront(tag: Int, total: Int, paddingAngle: CGFloat, layerCenter: CGFloat) {
        let frontSize = frontView.frame.size
        for i in 0...total-1 {
            let counterIndex = countersFront.count
            let presure = presureForCounterIndex(counterIndex, tag: tag)
            let counterRadius = counterRadiusForPresure(presure)
            let center = CGPoint(x: frontSize.width/2 - counterRadius/2, y: frontSize.height/2 - counterRadius/2)
            let angle = (CGFloat.pi * 2 * CGFloat(i)/CGFloat(total)) + paddingAngle // Угл центра счетчика относительно оси OX
            let x = center.x + layerCenter * cos(angle)
            let y = center.y + layerCenter * sin(angle)
            let frame = NSRect(x: x, y: y, width: counterRadius, height: counterRadius)
            
            let counter = CounterView(frame: frame)
            counter.index = counterIndex
            counter.presure = presure
            counter.onChangePresure = { [weak self] in
                self?.presures[counterIndex] = presure == .high ? .low : .high
                 // TODO: optimisation, refresh single counter
                self?.showCountersFront()
                self?.showCountersSide()
            }
            counter.wantsLayer = true
            counter.layer?.cornerRadius = counterRadius/2
            counter.layer?.masksToBounds = true
            counter.layer?.backgroundColor = counterColorForPresure(presure)
            
            let label = NSTextField(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height))
            label.isBezeled = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.alignment = .center
            label.textColor = NSColor.white
            label.font = NSFont.boldSystemFont(ofSize: 10)
            label.integerValue = counterIndex
            counter.addSubview(label)
            counter.label = label
            
            frontView.addSubview(counter)
            countersFront.append(counter)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
