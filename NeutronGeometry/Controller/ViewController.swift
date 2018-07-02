//
//  ViewController.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 16/01/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    
    enum Projection {
        case front, side
    }

    @IBOutlet weak var frontView: ProjectionView!
    @IBOutlet weak var sideView: ProjectionView!
    @IBOutlet weak var layer1CountField: NSTextField!
    @IBOutlet weak var layer2CountField: NSTextField!
    @IBOutlet weak var layer3CountField: NSTextField!
    @IBOutlet weak var layer4CountField: NSTextField!
    @IBOutlet weak var layer5CountField: NSTextField!
    @IBOutlet weak var layer6CountField: NSTextField!
    @IBOutlet weak var countersCountField: NSTextField!
    @IBOutlet weak var layer1RadiusField: NSTextField!
    @IBOutlet weak var layer2RadiusField: NSTextField!
    @IBOutlet weak var layer3RadiusField: NSTextField!
    @IBOutlet weak var layer4RadiusField: NSTextField!
    @IBOutlet weak var layer5RadiusField: NSTextField!
    @IBOutlet weak var layer6RadiusField: NSTextField!
    @IBOutlet weak var layer1CountersGapField: NSTextField!
    @IBOutlet weak var layer2CountersGapField: NSTextField!
    @IBOutlet weak var layer3CountersGapField: NSTextField!
    @IBOutlet weak var layer4CountersGapField: NSTextField!
    @IBOutlet weak var layer5CountersGapField: NSTextField!
    @IBOutlet weak var layer6CountersGapField: NSTextField!
    @IBOutlet weak var layer1ShiftAngleField: NSTextField!
    @IBOutlet weak var layer2ShiftAngleField: NSTextField!
    @IBOutlet weak var layer3ShiftAngleField: NSTextField!
    @IBOutlet weak var layer4ShiftAngleField: NSTextField!
    @IBOutlet weak var layer5ShiftAngleField: NSTextField!
    @IBOutlet weak var layer6ShiftAngleField: NSTextField!
    @IBOutlet weak var layer1EvenAngleField: NSTextField!
    @IBOutlet weak var layer2EvenAngleField: NSTextField!
    @IBOutlet weak var layer3EvenAngleField: NSTextField!
    @IBOutlet weak var layer4EvenAngleField: NSTextField!
    @IBOutlet weak var layer5EvenAngleField: NSTextField!
    @IBOutlet weak var layer6EvenAngleField: NSTextField!
    @IBOutlet weak var chamberSizeField: NSTextField!
    @IBOutlet weak var chamberThicknessField: NSTextField!
    @IBOutlet weak var barrelSizeField: NSTextField!
    @IBOutlet weak var barrelLenghtField: NSTextField!
    @IBOutlet weak var sourcePositionField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var calculateButton: NSButton!
    @IBOutlet weak var layer4Control: NSButton!
    @IBOutlet weak var layer5Control: NSButton!
    @IBOutlet weak var layer6Control: NSButton!
    @IBOutlet weak var gridStepField: NSTextField!
    @IBOutlet weak var maxTimeField: NSTextField!
    @IBOutlet weak var sourceIsotopeButton: NSPopUpButton!
    
    fileprivate var sourceType: SourceType = .point
    
    fileprivate var defaultSourceIsotope: SourceIsotope = .Cf252
    fileprivate var sourceIsotope: SourceIsotope {
        set {
            sourceIsotopeButton?.selectItem(at: newValue.rawValue)
        }
        get {
            if let i = sourceIsotopeButton?.indexOfSelectedItem, let si = SourceIsotope(rawValue: i) {
                return si
            } else {
                return defaultSourceIsotope
            }
        }
    }
    
    fileprivate var countersFront = [CounterFrontView]()
    fileprivate var countersSide = [NSView]()
    
    fileprivate weak var chamberFrontView: ChamberView?
    fileprivate weak var chamberSideView: ChamberView?
    
    fileprivate weak var barrelFrontView: NSView?
    fileprivate weak var barrelSideView: NSView?
    
    fileprivate var types = [Int: CounterType]()
    
    fileprivate func typeForCounterIndex(_ index: Int, tag: Int) -> CounterType {
        if let t = types[index] {
            return t
        }
        return defaultCounterTypeForTag(tag)
    }
    
    fileprivate func defaultCounterTypeForTag(_ tag: Int) -> CounterType {
        switch tag {
        case 1:
            return .atm7New
        case 4, 5, 6:
            return .atm4
        default:
            return .atm7Old
        }
    }
    
    fileprivate func setupSourceIsotopes() {
        var isotopes = [String]()
        for i in 0...SourceIsotope.count-1 {
            let si = SourceIsotope(rawValue: i)!
            isotopes.append(si.name)
        }
        sourceIsotopeButton.removeAllItems()
        sourceIsotopeButton.addItems(withTitles: isotopes)
    }
    
    @IBAction func loadResults(_ sender: Any) {
        MCNPOutput.openResults { (results: MCNPOutput?) in
        }
    }
    
    @IBAction func layer4Control(_ sender: Any) {
        layer4ControlValueChanged()
        updateButton(nil)
    }
    
    @IBAction func layer5Control(_ sender: Any) {
        layer5ControlValueChanged()
        updateButton(nil)
    }
    
    @IBAction func layer6Control(_ sender: Any) {
        layer6ControlValueChanged()
        updateButton(nil)
    }
    
    fileprivate func layer4ControlValueChanged() {
        let isOn = layer4Control.state == .on
        layer4RadiusField.isEnabled = isOn
        layer4CountField.isEnabled = isOn
        layer4CountersGapField.isHidden = !isOn
        layer5ControlValueChanged()
    }
    
    fileprivate func layer5ControlValueChanged() {
        let isOn = layer5Control.state == .on && layer4Control.state == .on
        layer5Control.state = isOn ? .on : .off
        layer5RadiusField.isEnabled = isOn
        layer5CountField.isEnabled = isOn
        layer5CountersGapField.isHidden = !isOn
        layer6ControlValueChanged()
    }
    
    fileprivate func layer6ControlValueChanged() {
        let isOn = layer6Control.state == .on && layer5Control.state == .on && layer4Control.state == .on
        layer6Control.state = isOn ? .on : .off
        layer6RadiusField.isEnabled = isOn
        layer6CountField.isEnabled = isOn
        layer6CountersGapField.isHidden = !isOn
    }
    
    fileprivate let maxLayersCount: Int = 6
    
    fileprivate func showCountersGap() {
        let layers = counterLayers()
        for i in 0...maxLayersCount-1 {
            var result: Int = 0
            if i < layers.count {
                let layer =  layers[i]
                if layer.count > 1 {
                    let counter1 = layer[0]
                    let counter2 = layer[1]
                    let p1 = counter1.center()
                    let p2 = counter2.center()
                    let distance = hypot(p1.x - p2.x, p1.y - p2.y) * 10
                    let type1 = counter1.type
                    let type2 = counter2.type
                    let deltaRadius = (Counter(type: type1).radius - Counter(type: type2).radius) * 10
                    result = lroundf(Float(distance) - deltaRadius)
                }
            }
            var textField: NSTextField?
            switch i {
            case 0:
                textField = layer1CountersGapField
            case 1:
                textField = layer2CountersGapField
            case 2:
                textField = layer3CountersGapField
            case 3:
                textField = layer4CountersGapField
            case 4:
                textField = layer5CountersGapField
            case 5:
                textField = layer6CountersGapField
            default:
                break
            }
            textField?.integerValue = result
            textField?.textColor = result > 0 ? NSColor.darkGray : NSColor.red
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
        showCountersGap()
        showSource()
        storeLastGeometryToDefaults()
    }
    
    fileprivate func showSource() {
        let onTap = { [weak self] in
            self?.sourceType = (self?.sourceType.toggle())!
            self?.showSource()
        }
        frontView.showSource(sourceType, onTap: onTap)
        sideView.showSource(sourceType, shift: CGFloat(sourcePositionField.floatValue), onTap: onTap)
    }
    
    @IBAction func saveButton(_ sender: Any?) {
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
    fileprivate let keyType = "TYPE"
    fileprivate let keyPresure = "PRESURE"
    fileprivate let keyThickness = "THICKNESS"
    fileprivate let keyCenterX = "X"
    fileprivate let keyCenterY = "Y"
    fileprivate let keySource = "SOURCE"
    fileprivate let keyZ = "Z"
    fileprivate let keyValue = "VALUE"
    fileprivate let keyMaxTime = "MAX_TIME"
    fileprivate let keyIsotope = "ISOTOPE"
    fileprivate let keyAngle = "ANGLE"
    fileprivate let keyEven = "EVEN_COUNTER_SHIFT_ANGLE"
    
    fileprivate func getGeometry() -> String {
        var strings = [String]()
        var layerCountFields = [layer1CountField, layer2CountField, layer3CountField]
        var layerAnglesFields = [layer1ShiftAngleField, layer2ShiftAngleField, layer3ShiftAngleField]
        var layerEvenAngleFields = [layer1EvenAngleField, layer2EvenAngleField, layer3EvenAngleField]
        var layerRadiusFields = [layer1RadiusField, layer2RadiusField, layer3RadiusField]
        if layer4Control.state == .on {
            layerCountFields.append(layer4CountField)
            layerAnglesFields.append(layer4ShiftAngleField)
            layerEvenAngleFields.append(layer4EvenAngleField)
            layerRadiusFields.append(layer4RadiusField)
            if layer5Control.state == .on {
                layerCountFields.append(layer5CountField)
                layerAnglesFields.append(layer5ShiftAngleField)
                layerEvenAngleFields.append(layer5EvenAngleField)
                layerRadiusFields.append(layer5RadiusField)
                if layer6Control.state == .on {
                    layerCountFields.append(layer6CountField)
                    layerAnglesFields.append(layer6ShiftAngleField)
                    layerEvenAngleFields.append(layer6EvenAngleField)
                    layerRadiusFields.append(layer6RadiusField)
                }
            }
        }
        // LAYERS INFO
        for i in 0..<layerCountFields.count {
            strings.append(keyLayer(i+1) + " \(keyRadius)=\(layerRadiusFields[i]!.integerValue) \(keyCount)=\(layerCountFields[i]!.integerValue) \(keyAngle)=\(layerAnglesFields[i]!.stringValue) \(keyEven)=\(layerEvenAngleFields[i]!.stringValue)")
        }
        // COUNTERS
        for counter in countersFront {
            let center = counter.center()
            strings.append(keyCounter(counter.index+1) + " \(keyCenterX)=\(center.x) \(keyCenterY)=\(center.y) \(keyType)=\(counter.type.rawValue)")
        }
        // BARREL
        strings.append(keyBarrel + " \(keySize)=\(barrelSizeField.integerValue) \(keyLenght)=\(barrelLenghtField.integerValue)")
        // CHAMBER
        strings.append(keyChamber + " \(keySize)=\(chamberSizeField.integerValue) \(keyThickness)=\(chamberThicknessField.integerValue)")
        // GRID
        strings.append(keyGrid + " \(keyStep)=\(gridStepField.integerValue)")
        // MAX TIME
        strings.append(keyMaxTime + " \(keyValue)=\(maxTimeField.integerValue)")
        // SOURCE
        strings.append(keySource + " \(keyZ)=\(sourcePositionField.integerValue) \(keyType)=\(sourceType.rawValue) \(keyIsotope)=\(sourceIsotope.rawValue)")
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
        
        func preferenceStringFor(key: String, preferences: [String]) -> String? {
            let prefix = key + "="
            let preference = preferences.filter { (s: String) -> Bool in
                return s.hasPrefix(prefix)
                }.first
            if let preference = preference, let range = preference.range(of: prefix) {
                let end = preference.index(preference.endIndex, offsetBy: 0)
                let result = String(preference[range.upperBound..<end])
                return result
            } else {
                return nil
            }
        }
        
        func preferenceIntFor(key: String, preferences: [String]) -> Int? {
            if let s = preferenceStringFor(key: key, preferences: preferences) {
                return Int(s)
            } else {
                return nil
            }
        }
        
        // LAYERS INFO
        var countersCount = 0
        for i in 0...maxLayersCount-1 {
            let values = dict[keyLayer(i+1)]
            if let values = values, let count = preferenceIntFor(key: keyCount, preferences: values), let radius = preferenceIntFor(key: keyRadius, preferences: values) {
                countersCount += count
                
                var countField: NSTextField?
                var radiusField: NSTextField?
                var angleField: NSTextField?
                var evenAngleField: NSTextField?
                switch i {
                case 0:
                    countField = layer1CountField
                    radiusField = layer1RadiusField
                    angleField = layer1ShiftAngleField
                    evenAngleField = layer1EvenAngleField
                case 1:
                    countField = layer2CountField
                    radiusField = layer2RadiusField
                    angleField = layer2ShiftAngleField
                    evenAngleField = layer2EvenAngleField
                case 2:
                    countField = layer3CountField
                    radiusField = layer3RadiusField
                    angleField = layer3ShiftAngleField
                    evenAngleField = layer3EvenAngleField
                case 3:
                    countField = layer4CountField
                    radiusField = layer4RadiusField
                    angleField = layer4ShiftAngleField
                    evenAngleField = layer4EvenAngleField
                case 4:
                    countField = layer5CountField
                    radiusField = layer5RadiusField
                    angleField = layer5ShiftAngleField
                    evenAngleField = layer5EvenAngleField
                case 5:
                    countField = layer6CountField
                    radiusField = layer6RadiusField
                    angleField = layer6ShiftAngleField
                    evenAngleField = layer6EvenAngleField
                default:
                    break
                }
                countField?.integerValue = count
                radiusField?.integerValue = radius
                angleField?.stringValue = preferenceStringFor(key: keyAngle, preferences: values) ?? "0"
                evenAngleField?.stringValue = preferenceStringFor(key: keyEven, preferences: values) ?? "0"
            }
            if i == 3 {
                layer4Control.state = values == nil ? .off : .on
                layer4ControlValueChanged()
            }
            if i == 4 {
                layer5Control.state = values == nil ? .off : .on
                layer5ControlValueChanged()
            }
            if i == 5 {
                layer6Control.state = values == nil ? .off : .on
                layer6ControlValueChanged()
            }
        }
        // BARREL
        if let values = dict[keyBarrel], let size = preferenceIntFor(key: keySize, preferences: values), let lenght = preferenceIntFor(key: keyLenght, preferences: values) {
            barrelSizeField.integerValue = size
            barrelLenghtField.integerValue = lenght
        }
        // CHAMBER
        if let values = dict[keyChamber], let size = preferenceIntFor(key: keySize, preferences: values), let thickness = preferenceIntFor(key: keyThickness, preferences: values) {
            chamberSizeField.integerValue = size
            chamberThicknessField.integerValue = thickness
        }
        // GRID
        if let values = dict[keyGrid], let step = preferenceIntFor(key: keyStep, preferences: values) {
            gridStepField.integerValue = step
        }
        // MAX TIME
        if let values = dict[keyMaxTime], let time = preferenceIntFor(key: keyValue, preferences: values) {
            maxTimeField.integerValue = time
        }
        // SOURCE POSITION
        if let values = dict[keySource] {
            if let z = preferenceIntFor(key: keyZ, preferences: values) {
                sourcePositionField.integerValue = z
            }
            if let t = preferenceIntFor(key: keyType, preferences: values), let type = SourceType(rawValue: t) {
                sourceType = type
            }
            if let i = preferenceIntFor(key: keyIsotope, preferences: values), let si = SourceIsotope(rawValue: i) {
                sourceIsotope = si
            }
        }
        
        // UPDATE GEOMETRY
        updateButton(nil)
            
        // COUNTERS
        // We update only presure there. Counter center point will be automaticly set after geometry re-drawing.
        if countersCount > 0 {
            for i in 0..<countersCount {
                if let values = dict[keyCounter(i+1)], let t = preferenceIntFor(key: keyType, preferences: values), let type = CounterType(rawValue: t) {
                    types[i] = type
                } else if let values = dict[keyCounter(i+1)], let p = preferenceIntFor(key: keyPresure, preferences: values) { // Old geometry version support
                    switch p {
                    case 4:
                        types[i] = .atm4
                    case 7:
                        types[i] = .atm7Old
                    default:
                        break
                    }
                }
            }
            showCountersFront()
            showCountersSide()
        }
    }
    
    fileprivate func counterLayers() -> [[CounterFrontView]] {
        var layers = [[CounterFrontView]]()
        let layerIndexes = countersFront.map { (c: CounterFrontView) -> Int in
            return c.layerIndex
        }
        let indexes = Array(Set(layerIndexes)).sorted { (i1: Int, i2: Int) -> Bool in
            return i1 < i2
        }
        for i in indexes {
            let layer = countersFront.filter({ (c: CounterFrontView) -> Bool in
                return c.layerIndex == i
            }).sorted(by: { (c1: CounterFrontView, c2: CounterFrontView) -> Bool in
                return c1.index < c2.index
            })
            layers.append(layer)
        }
        return layers
    }
    
    @IBAction func calculateButton(_ sender: Any?) {
        updateButton(nil)
        
        print("\nConfiguration results:")
        for counter in countersFront {
            let center = counter.center()
            print("Counter: \(counter.index), center: (\(center.x), \(center.y)) cm, type: \(counter.type.name)")
        }
        
        let chamberSize = chamberSizeField.floatValue/10
        let chamberThinkness = chamberThicknessField.floatValue/10
        let barrelSize = barrelSizeField.floatValue/10
        let barrelLenght = barrelLenghtField.floatValue/10
        let sourcePositionZ = sourcePositionField.floatValue/10
        
        print("Vacuum chamber size: \(chamberSize) cm")
        print("Vacuum chamber thikness: \(chamberThinkness) cm")
        print("Barrel size: \(barrelSize) cm")
        print("Barrel lenght: \(barrelLenght) cm")
        print("Source position Z: \(sourcePositionZ) cm")
        print("Source type: \(sourceType.name)")
        print("Source isotope: \(sourceIsotope.name)")
        
        // MCNP
        let layers = counterLayers()
        print("------- MCNP Input -------")
        let result = MCNPInput().generateWith(counterViewLayers: layers, chamberMax: chamberSize, chamberMin: (chamberSize - chamberThinkness), barrelSize: barrelSize, barrelLenght: barrelLenght, maxTime: maxTimeField.integerValue, sourcePositionZ: sourcePositionZ, sourceType: sourceType, sourceIsotope: sourceIsotope)
        print(result)
        
        // Files
        let timeStamp = String.timeStamp()
        FileManager.writeString(result, path: FileManager.mcnpFilePath(timeStamp))
        FileManager.writeImage(view.window?.screenshot(), path: FileManager.screenshotFilePath(timeStamp))
        FileManager.writeString(getGeometry(), path: FileManager.geometryFilePath(timeStamp))
        MCNPRun.generateRunInfo(timeStamp)
        NSWorkspace.shared.openFile(FileManager.desktopFolderPathWithName(timeStamp)! as String)
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
        
        setupSourceIsotopes()
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
        frontView.projection = .front
        sideView.projection = .side
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
        let type: CounterType = countersForLayerTag(tag).first?.type ?? defaultCounterTypeForTag(tag)
        let counter = Counter(type: type)
        let width = CGFloat(counter.lenght * 10)
        let height = CGFloat(counter.radius * 10) * 2
        let container = containerFor(.side)
        let containerSize = container.frame.size
        let zArray = [1, -1] as [CGFloat]
        for z in zArray {
            let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 + z * layerCenter - height/2) // +- layerCenter
            let counterView = CounterSideView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
            counterView.onTap = { [weak self] in
                let newType = type.toggle()
                self?.changeType(newType, forLayer: tag)
            }
            counterView.wantsLayer = true
            counterView.type = type
            container.addSubview(counterView)
            countersSide.append(counterView)
        }
    }
    
    fileprivate func countersForLayerTag(_ tag: Int) -> [CounterFrontView] {
        return countersFront.filter { (cv: CounterFrontView) -> Bool in
            return cv.layerIndex == tag
        }
    }
    
    fileprivate func changeType(_ newType: CounterType, forLayer tag: Int) {
        let indexes = countersForLayerTag(tag).map { (cv: CounterFrontView) -> Int in
            return cv.index
        }
        for index in indexes {
            types[index] = newType
        }
        showCountersFront()
        showCountersSide()
    }
    
    fileprivate func showCountersSide() {
        for view in countersSide {
            view.removeFromSuperview()
        }
        countersSide.removeAll()
        
        var fields = [layer1RadiusField, layer2RadiusField, layer3RadiusField] as [NSTextField]
        if layer4Control.state == .on {
            fields.append(layer4RadiusField)
            if layer5Control.state == .on {
                fields.append(layer5RadiusField)
                if layer6Control.state == .on {
                    fields.append(layer6RadiusField)
                }
            }
        }
        for field in fields {
            showCountersSide(field, tag: 1 + fields.index(of: field)!)
        }
    }
    
    fileprivate func layerRadiusFrom(_ textField: NSTextField) -> CGFloat {
        return max(CGFloat(textField.floatValue), 10)
    }
    
    fileprivate func layerCountFrom(_ textField: NSTextField) -> Int {
        return max(textField.integerValue, 2)
    }
    
    fileprivate func layerShiftAngleFrom(_ textField: NSTextField) -> CGFloat {
        return CGFloat(textField.floatValue)
    }
    
    fileprivate func layerEvenAngleFrom(_ textField: NSTextField) -> CGFloat {
        return CGFloat(textField.floatValue)
    }
    
    fileprivate func showCountersFront() {
        for view in countersFront {
            view.removeFromSuperview()
        }
        countersFront.removeAll()
        
        // Layer 1
        let layerCenter1 = layerRadiusFrom(layer1RadiusField)
        let total1 = layerCountFrom(layer1CountField)
        var paddingAngle: CGFloat = layerShiftAngleFrom(layer1ShiftAngleField) // Смещение угла относительно предыдущего ряда счетчиков (нужно по-максимуму закрыть промежутки между счетчиками чтобы увеличить эффективность)
        addCountersLayerFront(tag: 1, total: total1, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer1EvenAngleField), layerCenter: layerCenter1)
        // Layer 2
        let layerCenter2 = layerRadiusFrom(layer2RadiusField)
        let total2 = layerCountFrom(layer2CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total1))/2 + layerShiftAngleFrom(layer2ShiftAngleField)
        addCountersLayerFront(tag: 2, total: total2, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer2EvenAngleField), layerCenter: layerCenter2)
        // Layer 3
        let layerCenter3 = layerRadiusFrom(layer3RadiusField)
        let total3 = layerCountFrom(layer3CountField)
        paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total2))/2 + layerShiftAngleFrom(layer3ShiftAngleField)
        addCountersLayerFront(tag: 3, total: total3, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer3EvenAngleField), layerCenter: layerCenter3)
        // Layer 4
        if layer4Control.state == .on {
            let layerCenter4 = layerRadiusFrom(layer4RadiusField)
            let total4 = layerCountFrom(layer4CountField)
            paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total3))/2 + layerShiftAngleFrom(layer4ShiftAngleField)
            addCountersLayerFront(tag: 4, total: total4, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer4EvenAngleField), layerCenter: layerCenter4)
            // Layer 5
            if layer5Control.state == .on {
                let layerCenter5 = layerRadiusFrom(layer5RadiusField)
                let total5 = layerCountFrom(layer5CountField)
                paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total4))/2 + layerShiftAngleFrom(layer5ShiftAngleField)
                addCountersLayerFront(tag: 5, total: total5, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer5EvenAngleField), layerCenter: layerCenter5)
                // Layer 6
                if layer6Control.state == .on {
                    let layerCenter6 = layerRadiusFrom(layer6RadiusField)
                    let total6 = layerCountFrom(layer6CountField)
                    paddingAngle += (CGFloat.pi * 2 * CGFloat(1)/CGFloat(total5))/2 + layerShiftAngleFrom(layer6ShiftAngleField)
                    addCountersLayerFront(tag: 6, total: total6, paddingAngle: paddingAngle, evenAngle: layerEvenAngleFrom(layer6EvenAngleField), layerCenter: layerCenter6)
                }
            }
        }
        
        countersCountField.integerValue = countersFront.count
    }
    
    fileprivate func addCountersLayerFront(tag: Int, total: Int, paddingAngle: CGFloat, evenAngle: CGFloat, layerCenter: CGFloat) {
        let frontSize = frontView.frame.size
        for i in 0...total-1 {
            let counterIndex = countersFront.count
            let type = typeForCounterIndex(counterIndex, tag: tag)
            let counter = Counter(type: type)
            let counterRadius = CGFloat(counter.radius * 10)
            let center = CGPoint(x: frontSize.width/2 - counterRadius, y: frontSize.height/2 - counterRadius)
            var angle = (CGFloat.pi * 2 * CGFloat(i)/CGFloat(total)) + paddingAngle // Угл центра счетчика относительно оси OX
            if (i + 1) % 2 == 0 {
                angle -= evenAngle
            }
            let x = center.x + layerCenter * cos(angle)
            let y = center.y + layerCenter * sin(angle)
            let frame = NSRect(x: x, y: y, width: counterRadius * 2, height: counterRadius * 2)
            
            let counterView = CounterFrontView(frame: frame)
            counterView.index = counterIndex
            counterView.layerIndex = tag
            counterView.onTap = { [weak self] in
                self?.types[counterIndex] = type.toggle()
                 // TODO: optimisation, refresh single counter
                self?.showCountersFront()
                self?.showCountersSide()
            }
            counterView.wantsLayer = true
            counterView.layer?.cornerRadius = counterRadius
            counterView.layer?.masksToBounds = true
            counterView.type = type
            
            frontView.addSubview(counterView)
            countersFront.append(counterView)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
