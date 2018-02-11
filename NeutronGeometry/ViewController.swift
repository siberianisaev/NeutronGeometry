//
//  ViewController.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa
import AppKit

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
    @IBOutlet weak var layer1InteritemSpaceField: NSTextField!
    @IBOutlet weak var layer2InteritemSpaceField: NSTextField!
    @IBOutlet weak var layer3InteritemSpaceField: NSTextField!
    @IBOutlet weak var layer4InteritemSpaceField: NSTextField!
    @IBOutlet weak var chamberSizeField: NSTextField!
    @IBOutlet weak var chamberThicknessField: NSTextField!
    @IBOutlet weak var barrelSizeField: NSTextField!
    @IBOutlet weak var barrelLenghtField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var calculateButton: NSButton!
    @IBOutlet weak var layer4Control: NSButton!
    @IBOutlet weak var gridStepField: NSTextField!
    
    fileprivate var countersFront = [CounterView]()
    fileprivate var countersSide = [NSView]()
    
    fileprivate weak var chamberFrontView: ChamberView?
    fileprivate weak var chamberSideView: ChamberView?
    
    fileprivate weak var barrelFrontView: NSView?
    fileprivate weak var barrelSideView: NSView?
    
    fileprivate var presures = [Int: HeliumPressure]()
    
    fileprivate func presureForCounterIndex(_ index: Int, tag: Int) -> HeliumPressure {
        return presures[index] ?? (tag == 4 ? .low : .high)
    }
    
    @IBAction func layer4Control(_ sender: Any) {
        layer4ControlValueChanged()
        updateButton(nil)
    }
    
    fileprivate func layer4ControlValueChanged() {
        let isOn = layer4Control.state == .on
        layer4RadiusField.isEnabled = isOn
        layer4CountField.isEnabled = isOn
        layer4InteritemSpaceField.isHidden = !isOn
    }
    
    fileprivate func showInteritemSpace() {
        let layers = counterLayers()
        for i in 0...3 {
            var result: Int = 0
            if i < layers.count {
                let layer =  layers[i]
                if layer.count > 1 {
                    let counter1 = layer[0]
                    let counter2 = layer[1]
                    let p1 = counter1.center()
                    let p2 = counter2.center()
                    let distance = hypot(p1.x - p2.x, p1.y - p2.y) * 10
                    let presure1 = counter1.presure
                    let presure2 = counter2.presure
                    let radius1 = counterRadiusForPresure(presure1)
                    let radius2 = counterRadiusForPresure(presure2)
                    result = lroundf(Float(distance - radius1 - radius2))
                }
            }
            switch i {
            case 0:
                layer1InteritemSpaceField.integerValue = result
            case 1:
                layer2InteritemSpaceField.integerValue = result
            case 2:
                layer3InteritemSpaceField.integerValue = result
            default:
                layer4InteritemSpaceField.integerValue = result
            }
        }
    }
    
    @IBAction func updateButton(_ sender: Any?) {
        setupProjections()
        showBarrelFront()
        showChamberFront()
        showCountersFront()
        showBarrelSide()
        showChamberSide()
        showCountersSide()
        showInteritemSpace()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let timeStamp = String.timeStamp()
        let geometryPath = FileManager.geometryFilePath(timeStamp)
        let result = getGeometry()
        FileManager.writeString(result, path: geometryPath)
    }
    
    fileprivate let keyCounterInfo = "COUNTER_INFO"
    fileprivate let keyRadius = "RADIUS"
    fileprivate func keyRadiusAtm(_ value: Int) -> String {
        return "\(keyRadius)_\(value)ATM"
    }
    fileprivate func keyLayer(_ value: Int) -> String {
        return "LAYER_\(value)"
    }
    fileprivate func keyCounter(_ value: Int) -> String {
        return "COUNTER_\(value)"
    }
    fileprivate let keyCount = "COUNT"
    fileprivate let keyBarrel = "BARREL"
    fileprivate let keyChamber = "CHAMBER"
    fileprivate let keyGrid = "GRID"
    fileprivate let keyStep = "STEP"
    fileprivate let keyLenght = "LENGHT"
    fileprivate let keySize = "SIZE"
    fileprivate let keyPresure = "PRESURE"
    fileprivate let keyThickness = "THICKNESS"
    fileprivate let keyCenterX = "X"
    fileprivate let keyCenterY = "Y"
    
    fileprivate func getGeometry() -> String {
        var strings = [String]()
        var layerCountFields = [layer1CountField, layer2CountField, layer3CountField]
        var layerRadiusFields = [layer1RadiusField, layer2RadiusField, layer3RadiusField]
        if layer4Control.state == .on {
            layerCountFields.append(layer4CountField)
            layerRadiusFields.append(layer4RadiusField)
        }
        // LAYERS INFO
        for i in 0..<layerCountFields.count {
            strings.append(keyLayer(i+1) + " \(keyRadius)=\(layerRadiusFields[i]!.integerValue) \(keyCount)=\(layerCountFields[i]!.integerValue)")
        }
        // COUNTER INFO
        strings.append(keyCounterInfo + " \(keyRadiusAtm(4))=\(counterRadius4AtmField.integerValue) \(keyRadiusAtm(7))=\(counterRadius7AtmField.integerValue) \(keyLenght)=\(counterLenghtField.integerValue)")
        // COUNTERS
        for counter in countersFront {
            let center = counter.center()
            strings.append(keyCounter(counter.index+1) + " \(keyCenterX)=\(center.x) \(keyCenterY)=\(center.y) \(keyPresure)=\(counter.presure.rawValue)")
        }
        // BARREL
        strings.append(keyBarrel + " \(keySize)=\(barrelSizeField.integerValue) \(keyLenght)=\(barrelLenghtField.integerValue)")
        // CHAMBER
        strings.append(keyChamber + " \(keySize)=\(chamberSizeField.integerValue) \(keyThickness)=\(chamberThicknessField.integerValue)")
        // GRID
        strings.append(keyGrid + " \(keyStep)=\(gridStepField.integerValue)")
        return strings.joined(separator: "\n")
    }
    
    @IBAction func loadButton(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.begin { [weak self] (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let path = panel.urls.first?.path, path.hasSuffix(".geometry") {
                    do {
                        let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                        self?.restoreGeometry(content)
                    } catch {
                        print("Error load geometry from file at path \(path): \(error)")
                    }
                }
            }
        }
    }
    
    fileprivate func restoreGeometry(_ content: String) {
        let tuples = content.components(separatedBy: "\n").map({ (string: String) -> (String, [String]) in
            var values = string.components(separatedBy: " ")
            if values.count > 0 {
                let key = values.removeFirst()
                return (key, values)
            } else {
                return ("", values)
            }
        })
        var dict = [String: [String]]()
        for tuple in tuples {
            dict[tuple.0] = tuple.1
        }
        
        func preferenceFor(key: String, preferences: [String]) -> Int? {
            let prefix = key + "="
            let preference = preferences.filter { (s: String) -> Bool in
                return s.hasPrefix(prefix)
            }.first
            if let preference = preference, let range = preference.range(of: prefix) {
                let end = preference.index(preference.endIndex, offsetBy: 0)
                let result = String(preference[range.upperBound..<end])
                return Int(result)
            } else {
                return nil
            }
        }
        
        // LAYERS INFO
        var countersCount = 0
        for i in 0...3 {
            let values = dict[keyLayer(i+1)]
            if let values = values, let count = preferenceFor(key: keyCount, preferences: values), let radius = preferenceFor(key: keyRadius, preferences: values) {
                countersCount += count
                
                var countField: NSTextField?
                var radiusField: NSTextField?
                switch i {
                case 0:
                    countField = layer1CountField
                    radiusField = layer1RadiusField
                case 1:
                    countField = layer2CountField
                    radiusField = layer2RadiusField
                case 2:
                    countField = layer3CountField
                    radiusField = layer3RadiusField
                default:
                    countField = layer4CountField
                    radiusField = layer4RadiusField
                }
                countField?.integerValue = count
                radiusField?.integerValue = radius
            }
            if i == 3 {
                layer4Control.state = values == nil ? .off : .on
                layer4ControlValueChanged()
            }
        }
        // COUNTER INFO
        if let values = dict[keyCounterInfo], let radius4Atm = preferenceFor(key: keyRadiusAtm(4), preferences: values), let radius7Atm = preferenceFor(key: keyRadiusAtm(7), preferences: values), let lenght = preferenceFor(key: keyLenght, preferences: values) {
            counterRadius4AtmField.integerValue = radius4Atm
            counterRadius7AtmField.integerValue = radius7Atm
            counterLenghtField.integerValue = lenght
        }
        // BARREL
        if let values = dict[keyBarrel], let size = preferenceFor(key: keySize, preferences: values), let lenght = preferenceFor(key: keyLenght, preferences: values) {
            barrelSizeField.integerValue = size
            barrelLenghtField.integerValue = lenght
        }
        // CHAMBER
        if let values = dict[keyChamber], let size = preferenceFor(key: keySize, preferences: values), let thickness = preferenceFor(key: keyThickness, preferences: values) {
            chamberSizeField.integerValue = size
            chamberThicknessField.integerValue = thickness
        }
        // GRID
        if let values = dict[keyGrid], let step = preferenceFor(key: keyStep, preferences: values) {
            gridStepField.integerValue = step
        }
        
        // UPDATE GEOMETRY
        updateButton(nil)
            
        // COUNTERS
        // We update only presure there. Counter center point will be automaticly set after geometry re-drawing.
        if countersCount > 0 {
            for i in 0..<countersCount {
                if let values = dict[keyCounter(i+1)], let p = preferenceFor(key: keyPresure, preferences: values), let presure = HeliumPressure(rawValue: p) {
                    presures[i] = presure
                }
            }
            showCountersFront()
            showCountersSide()
        }
    }
    
    fileprivate func counterLayers() -> [[CounterView]] {
        var layers = [[CounterView]]()
        let layerIndexes = countersFront.map { (c: CounterView) -> Int in
            return c.layerIndex
        }
        let indexes = Array(Set(layerIndexes)).sorted { (i1: Int, i2: Int) -> Bool in
            return i1 < i2
        }
        for i in indexes {
            let layer = countersFront.filter({ (c: CounterView) -> Bool in
                return c.layerIndex == i
            }).sorted(by: { (c1: CounterView, c2: CounterView) -> Bool in
                return c1.index < c2.index
            })
            layers.append(layer)
        }
        return layers
    }
    
    @IBAction func calculateButton(_ sender: Any) {
        print("\nConfiguration results:")
        for counter in countersFront {
            let center = counter.center()
            print("Counter: \(counter.index), center: (\(center.x), \(center.y)) cm, presure: \(counter.presure.rawValue) atm.")
        }
        print("Barrel size: \(barrelSizeField.floatValue/10) cm")
        print("Barrel lenght: \(barrelLenghtField.floatValue/10) cm")
        print("Counter lenght: \(counterLenghtField.floatValue/10) cm")
        
        // MCNP
        let layers = counterLayers()
        print("------- MCNP Input -------")
        let result = MCNPInput.generate(layers)
        print(result)
        
        // Files
        let timeStamp = String.timeStamp()
        FileManager.writeString(result, path: FileManager.mcnpFilePath(timeStamp))
        FileManager.writeImage(view.window?.screenshot(), path: FileManager.screenshotFilePath(timeStamp))
        FileManager.writeString(getGeometry(), path: FileManager.geometryFilePath(timeStamp))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        restoreLastGeometryFromDefaults()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: OperationQueue.main) { [weak self] (note: Notification) in
            self?.storeLastGeometryToDefaults()
        }
    }
    
    deinit {
        storeLastGeometryToDefaults()
    }
    
    fileprivate let keyDefaultsLastGeometry = "DefaultsLastGeometry"
    
    fileprivate func restoreLastGeometryFromDefaults() {
        if let geometry = UserDefaults.standard.string(forKey: keyDefaultsLastGeometry) {
            restoreGeometry(geometry)
        } else {
            updateButton(nil)
        }
    }
    
    fileprivate func storeLastGeometryToDefaults() {
        let ud = UserDefaults.standard
        ud.set(getGeometry(), forKey: keyDefaultsLastGeometry)
        ud.synchronize()
    }
    
    fileprivate func setupProjections() {
        let newStep = max(gridStepField.integerValue, 1)
        for view in [frontView, sideView] as [ProjectionView] {
            if view.step != newStep {
                view.step = newStep
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
        barrel.layer?.backgroundColor = NSColor.darkGray.cgColor
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
        let chamber = ChamberView(frame: NSRect(x: center.x, y: center.y, width: width, height: height), thickness: CGFloat(chamberThicknessField.floatValue))
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
        let height = counterRadiusForPresure(presure) * 2
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
            let center = CGPoint(x: frontSize.width/2 - counterRadius, y: frontSize.height/2 - counterRadius)
            let angle = (CGFloat.pi * 2 * CGFloat(i)/CGFloat(total)) + paddingAngle // Угл центра счетчика относительно оси OX
            let x = center.x + layerCenter * cos(angle)
            let y = center.y + layerCenter * sin(angle)
            let frame = NSRect(x: x, y: y, width: counterRadius * 2, height: counterRadius * 2)
            
            let counter = CounterView(frame: frame)
            counter.index = counterIndex
            counter.layerIndex = tag
            counter.presure = presure
            counter.onChangePresure = { [weak self] in
                self?.presures[counterIndex] = presure == .high ? .low : .high
                 // TODO: optimisation, refresh single counter
                self?.showCountersFront()
                self?.showCountersSide()
            }
            counter.wantsLayer = true
            counter.layer?.cornerRadius = counterRadius
            counter.layer?.masksToBounds = true
            counter.layer?.backgroundColor = counterColorForPresure(presure)
            
            let labelHeight: CGFloat = 14
            let label = NSTextField(frame: NSRect(x: 0, y: frame.height/2 - labelHeight/2, width: frame.width, height: labelHeight))
            label.isBezeled = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.alignment = .center
            label.textColor = NSColor.white
            label.font = NSFont.boldSystemFont(ofSize: labelHeight - 4)
            label.integerValue = counterIndex + 1
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
