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
    @IBOutlet weak var layersCollectionView: NSCollectionView!
    @IBOutlet weak var countersCountField: NSTextField!
    @IBOutlet weak var layersCountField: NSTextField!
    @IBOutlet weak var layersCountStepper: NSStepper!
    @IBOutlet weak var shieldThicknessX: NSTextField!
    @IBOutlet weak var shieldThicknessY: NSTextField!
    @IBOutlet weak var shieldBoronPercent: NSTextField!
    @IBOutlet weak var chamberSizeField: NSTextField!
    @IBOutlet weak var chamberThicknessField: NSTextField!
    @IBOutlet weak var moderatorSizeField: NSTextField!
    @IBOutlet weak var moderatorLenghtField: NSTextField!
    @IBOutlet weak var sourcePositionField: NSTextField!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var loadButton: NSButton!
    @IBOutlet weak var calculateButton: NSButton!
    @IBOutlet weak var gridStepField: NSTextField!
    @IBOutlet weak var maxTimeField: NSTextField!
    @IBOutlet weak var sourceIsotopeButton: NSPopUpButton!
    
    fileprivate var sourceType: SourceType = .point
    
    fileprivate var dataSource = [CountersLayer]()
    
    @IBAction func layersCountChanged(_ sender: Any) {
        let value = (sender as! NSStepper).integerValue
        let current = dataSource.count
        if current >= value {
            if current > 0 {
                dataSource.removeLast()
            }
        } else {
            let layer = CountersLayer(tag: value)
            dataSource.append(layer)
        }
        layersCountField.integerValue = value
        updateButton(nil)
    }
    
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
    
    fileprivate weak var moderatorFrontView: NSView?
    fileprivate weak var moderatorSideView: NSView?
    
    fileprivate weak var shieldFrontView: NSView?
    fileprivate weak var shieldSideView: NSView?
    
    fileprivate weak var chamberFrontView: ChamberView?
    fileprivate weak var chamberSideView: ChamberView?
    
    fileprivate var types = [Int: CounterType]()
    
    fileprivate func typeForCounterIndex(_ index: Int, tag: Int) -> CounterType {
        if let t = types[index] {
            return t
        }
        return defaultCounterTypeForTag(tag)
    }
    
    fileprivate func defaultCounterTypeForTag(_ tag: Int) -> CounterType {
        switch tag {
        case 1, 2:
            return .zaprudnya
        case 3, 4:
            return .mayak
        case 5, 6:
            return .flerov
        default:
            return .aspekt
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
    
    fileprivate var countersGap = [Float]() {
        didSet {
            layersCollectionView?.reloadData()
        }
    }
    
    fileprivate func calculateCountersGap() {
        countersGap.removeAll()
        let layers = counterLayers()
        for layer in layers {
            var result: Float = 0
            if layer.count > 1 {
                let counter1 = layer[0]
                let counter2 = layer[1]
                let p1 = counter1.center()
                let p2 = counter2.center()
                let distance = hypot(p1.x - p2.x, p1.y - p2.y) * 10
                let type1 = counter1.type
                let type2 = counter2.type
                let deltaRadius = (Counter(type: type1).radius - Counter(type: type2).radius) * 10
                result = roundf(Float(distance) - deltaRadius)
            }
            countersGap.append(result)
        }
    }
    
    @IBAction func updateButton(_ sender: Any?) {
        layersCollectionView.reloadData()
        setupProjections()
        showShield(.front)
        showModerator(.front)
        showChamberFront()
        showCountersFront()
        showShield(.side)
        showModerator(.side)
        showChamberSide()
        showCountersSide()
        showSource()
        countersCountField.integerValue = dataSource.map({ (cl: CountersLayer) -> Int in
            return cl.count
        }).reduce(0, +)
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
    fileprivate let keyModerator = "BARREL"
    fileprivate let keyChamber = "CHAMBER"
    fileprivate let keyGrid = "GRID"
    fileprivate let keyStep = "STEP"
    fileprivate let keyLenght = "LENGHT"
    fileprivate let keySize = "SIZE"
    fileprivate let keyType = "TYPE"
    fileprivate let keyPresure = "PRESURE"
    fileprivate let keyThickness = "THICKNESS"
    fileprivate let keyX = "X"
    fileprivate let keyY = "Y"
    fileprivate let keySource = "SOURCE"
    fileprivate let keyZ = "Z"
    fileprivate let keyValue = "VALUE"
    fileprivate let keyMaxTime = "MAX_TIME"
    fileprivate let keyIsotope = "ISOTOPE"
    fileprivate let keyAngle = "ANGLE"
    fileprivate let keyEven = "EVEN_COUNTER_SHIFT_ANGLE"
    fileprivate let keyPercent = "PERCENT"
    fileprivate let keyShield = "SHILD"
    
    fileprivate func getGeometry() -> String {
        var strings = [String]()
        // LAYERS INFO
        for cl in dataSource {
            let tag = cl.tag
            strings.append(keyLayer(tag) + " \(keyRadius)=\(cl.radius) \(keyCount)=\(cl.count) \(keyAngle)=\(cl.shiftAngle) \(keyEven)=\(cl.evenAngle)")
        }
        // COUNTERS
        for counter in countersFront {
            let center = counter.center()
            strings.append(keyCounter(counter.index+1) + " \(keyX)=\(center.x) \(keyY)=\(center.y) \(keyType)=\(counter.type.rawValue)")
        }
        // MODERATOR
        strings.append(keyModerator + " \(keySize)=\(moderatorSizeField.integerValue) \(keyLenght)=\(moderatorLenghtField.integerValue)")
        // CHAMBER
        strings.append(keyChamber + " \(keySize)=\(chamberSizeField.integerValue) \(keyThickness)=\(chamberThicknessField.integerValue)")
        // GRID
        strings.append(keyGrid + " \(keyStep)=\(gridStepField.integerValue)")
        // MAX TIME
        strings.append(keyMaxTime + " \(keyValue)=\(maxTimeField.integerValue)")
        // SOURCE
        strings.append(keySource + " \(keyZ)=\(sourcePositionField.integerValue) \(keyType)=\(sourceType.rawValue) \(keyIsotope)=\(sourceIsotope.rawValue)")
        // SHILD
        strings.append(keyShield + " \(keyThickness)\(keyX)=\(shieldThicknessX.integerValue) \(keyThickness)\(keyY)=\(shieldThicknessY.integerValue) \(keyPercent)=\(shieldBoronPercent.integerValue)")
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
        
        func preferenceFloatFor(key: String, preferences: [String]) -> Float? {
            if let s = preferenceStringFor(key: key, preferences: preferences) {
                return Float(s)
            } else {
                return nil
            }
        }
        
        // LAYERS INFO
        dataSource.removeAll()
        var countersCount = 0
        var tag = 1
        while tag > 0 {
            if let values = dict[keyLayer(tag)], let count = preferenceIntFor(key: keyCount, preferences: values), let radius = preferenceFloatFor(key: keyRadius, preferences: values) {
                countersCount += count
                let shiftAngle = preferenceFloatFor(key: keyAngle, preferences: values) ?? 0
                let evenAngle = preferenceFloatFor(key: keyEven, preferences: values) ?? 0
                let layer = CountersLayer(tag: tag, count: count, radius: radius, shiftAngle: shiftAngle, evenAngle: evenAngle)
                dataSource.append(layer)
                layersCountStepper.integerValue = tag
                layersCountField.integerValue = tag
                tag += 1
            } else {
                break
            }
        }
        // MODERATOR
        if let values = dict[keyModerator], let size = preferenceIntFor(key: keySize, preferences: values), let lenght = preferenceIntFor(key: keyLenght, preferences: values) {
            moderatorSizeField.integerValue = size
            moderatorLenghtField.integerValue = lenght
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
        // SHILD
        if let values = dict[keyShield], let x = preferenceIntFor(key: keyThickness + keyX, preferences: values), let y = preferenceIntFor(key: keyThickness + keyY, preferences: values), let p = preferenceIntFor(key: keyPercent, preferences: values) {
            shieldThicknessX.integerValue = x
            shieldThicknessY.integerValue = y
            shieldBoronPercent.integerValue = p
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
                        types[i] = .aspekt
                    case 7:
                        types[i] = .flerov
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
        let moderatorSize = moderatorSizeField.floatValue/10
        let moderatorLenght = moderatorLenghtField.floatValue/10
        let sourcePositionZ = sourcePositionField.floatValue/10
        let shield = Shield(thiknessX: shieldThicknessX.floatValue/10, thiknessY: shieldThicknessY.floatValue/10, boronPercent: shieldBoronPercent.floatValue)
        
        print("Vacuum chamber size: \(chamberSize) cm")
        print("Vacuum chamber thikness: \(chamberThinkness) cm")
        print("Moderator size: \(moderatorSize) cm")
        print("Moderator lenght: \(moderatorLenght) cm")
        print("Source position Z: \(sourcePositionZ) cm")
        print("Source type: \(sourceType.name)")
        print("Source isotope: \(sourceIsotope.name)")
        print("Shield: \(shield)")
        
        // MCNP
        let layers = counterLayers()
        print("------- MCNP Input -------")
        let result = MCNPInput().generateWith(counterViewLayers: layers, chamberMax: chamberSize, chamberMin: (chamberSize - chamberThinkness), moderatorSize: moderatorSize, moderatorLenght: moderatorLenght, maxTime: maxTimeField.integerValue, sourcePositionZ: sourcePositionZ, sourceType: sourceType, sourceIsotope: sourceIsotope, shield: shield)
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
        
        layersCollectionView.register(CountersLayerViewItem.nib, forItemWithIdentifier: CountersLayerViewItem.identifier)
        layersCollectionView.delegate = self
        layersCollectionView.dataSource = self
        layersCollectionView.wantsLayer = true
        layersCollectionView.layer?.backgroundColor = NSColor.clear.cgColor
        
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
    
    fileprivate func shieldWidth(_ projection: Projection) -> CGFloat {
        return CGFloat((projection == .front ? moderatorSizeField : moderatorLenghtField)!.floatValue + 2 * shieldThicknessX.floatValue)
    }
    
    fileprivate func showShield(_ projection: Projection) {
        let isFront = projection == .front
        (isFront ? shieldFrontView : shieldSideView)?.removeFromSuperview()
        let width = shieldWidth(projection)
        let height = CGFloat(moderatorSizeField.floatValue + 2 * shieldThicknessY.floatValue)
        let container = containerFor(projection)
        let containerSize = container.frame.size
        let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 - height/2)
        let shield = NSView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
        shield.wantsLayer = true
        shield.layer?.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 63.0/255.0, alpha: 1.0).cgColor
        container.addSubview(shield)
        isFront ? (shieldFrontView = shield) : (shieldSideView = shield)
    }
    
    fileprivate func showModerator(_ projection: Projection) {
        let isFront = projection == .front
        (isFront ? moderatorFrontView : moderatorSideView)?.removeFromSuperview()
        let width = CGFloat((isFront ? moderatorSizeField : moderatorLenghtField)!.floatValue)
        let height = CGFloat(moderatorSizeField.floatValue)
        let container = containerFor(projection)
        let containerSize = container.frame.size
        let center = CGPoint(x: containerSize.width/2 - width/2, y: containerSize.height/2 - height/2)
        let moderator = NSView(frame: NSRect(x: center.x, y: center.y, width: width, height: height))
        moderator.wantsLayer = true
        moderator.layer?.backgroundColor = NSColor.darkGray.cgColor
        container.addSubview(moderator)
        isFront ? (moderatorFrontView = moderator) : (moderatorSideView = moderator)
    }
    
    fileprivate func showChamber(_ projection: Projection) {
        let isFront = projection == .front
        (isFront ? chamberFrontView : chamberSideView)?.removeFromSuperview()
        let width = isFront ? CGFloat(chamberSizeField.floatValue) : shieldWidth(projection)
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
    
    fileprivate func showCountersSide(_ countersLayer: CountersLayer) {
        let layerCenter = CGFloat(countersLayer.radius)
        let tag = countersLayer.tag
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
        
        for cl in dataSource {
            showCountersSide(cl)
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
        
        var paddingAngle: CGFloat = 0
        var total: Int?
        for cl in dataSource {
            let layerCenter = CGFloat(cl.radius)
            paddingAngle += CGFloat(cl.shiftAngle) // Смещение угла относительно предыдущего ряда счетчиков (нужно по-максимуму закрыть промежутки между счетчиками чтобы увеличить эффективность)
            if let total = total { // start do this from second layer
                paddingAngle += (CGFloat.pi * 2/CGFloat(total))/2
            }
            total = cl.count
            addCountersLayerFront(tag: cl.tag, total: total!, paddingAngle: paddingAngle, evenAngle: CGFloat(cl.evenAngle), layerCenter: layerCenter)
        }
        
        calculateCountersGap()
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

extension ViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ note: Notification) {
        if let tf = note.object as? NSTextField {
            let row = tf.tag - 1
            if row >= 0, row < dataSource.count {
                let layer = dataSource[row]
                let item = layersCollectionView.item(at: IndexPath(item: row, section: 0)) as! CountersLayerViewItem
                switch tf {
                case item.countField:
                    layer.count = tf.integerValue
                case item.radiusField:
                    layer.radius = tf.floatValue
                case item.shiftAngleField:
                    layer.shiftAngle = tf.floatValue
                case item.evenAngleField:
                    layer.evenAngle = tf.floatValue
                default:
                    break
                }
            }
        }
    }
    
}

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: CountersLayerViewItem.identifier, for: indexPath) as! CountersLayerViewItem
        let row = indexPath.item
        let layer = dataSource[row]
        item.nameField.integerValue = layer.tag
        item.countField.integerValue = layer.count
        item.radiusField.integerValue = Int(layer.radius)
        item.shiftAngleField.stringValue = String(layer.shiftAngle)
        item.evenAngleField.stringValue = String(layer.evenAngle)
        for tf in [item.countField, item.radiusField, item.shiftAngleField, item.evenAngleField] {
            tf?.tag = layer.tag
            tf?.delegate = self
        }
        // TODO: get gap from layer
        let gaps = countersGap
        let gap = row < gaps.count ? countersGap[row] : 0
        item.gapField.floatValue = gap
        item.gapField.textColor = gap > 0 ? NSColor.darkGray : NSColor.red
        return item
    }
    
}
