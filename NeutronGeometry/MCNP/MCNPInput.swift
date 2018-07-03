//
//  MCNPInput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20/01/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

class MCNPInput {
    
    fileprivate let npReactionId = 103 // (n,p) reaction
    
    fileprivate var _counters: [CounterType: Counter]?
    fileprivate var counters: [CounterType: Counter] {
        set {
            _counters = newValue
        }
        get {
            if nil == _counters {
                var dict = [CounterType: Counter]()
                for i in 0...CounterType.count-1 {
                    let type = CounterType(rawValue: i)!
                    let counter = Counter(type: type)
                    dict[type] = counter
                }
                _counters = dict
            }
            return _counters!
        }
    }
    
    fileprivate func convertViewLayersToMCNP(_ counterViewLayers: [[CounterFrontView]]) -> [[CounterFrontView]] {
        var mcnpLayers = [[CounterFrontView]]()
        for viewLayer in counterViewLayers {
            var dict = [CounterType: [CounterFrontView]]()
            for counterView in viewLayer {
                let type = counterView.type
                var array = dict[type] ?? []
                array.append(counterView)
                dict[type] = array
            }
            let sorted = dict.values.sorted { (a1: [CounterFrontView], a2: [CounterFrontView]) -> Bool in
                return a1.first!.type.rawValue < a2.first!.type.rawValue
            }
            for a in sorted {
                mcnpLayers.append(a)
            }
        }
        return mcnpLayers
    }
    
    func generateWith(counterViewLayers: [[CounterFrontView]], chamberMax: Float, chamberMin: Float, moderatorSize: Float, moderatorLenght: Float, maxTime: Int, sourcePositionZ: Float, sourceType: SourceType, sourceIsotope: SourceIsotope, shield: Shield) -> String {
        let layers = convertViewLayersToMCNP(counterViewLayers)
        let totalDetectorsCount = layers.joined().count
        var result = """
Geometry for \(totalDetectorsCount) detectors.
c ==== CELLS =====
10000 0 6 imp:n=0 $ Space Outside Shield
10001 0 -1 -5 imp:n=1 $ Space Inside of Vacuum Chamber
10002 2 -7.9 -2 1 -5 imp:n=1 $ Wall of Vacuum Chamber
"""
        let counterCellsCount = 5
        var id = 10
        var ids = [Int]()
        for layer in layers {
            for counterView in layer {
                let center = counterView.center()
                counterView.mcnpCellId = id
                let TRCL = String(format: "%.1f %.1f 0", center.x, center.y)
                let index = counterView.index + 1
                let counter = counters[counterView.type]!
                result += counter.mcnpCells(startId: id, index: index, TRCL: TRCL)
                ids.append(id)
                id += counterCellsCount + 1
            }
        }
        // Moderator cell negative to outer shell (surface 5), positive to vacuum tube (surface 2) and by excluding all He-3 counters cells (TRCL cell)
        let excludedIds = ids.map { (id: Int) -> String in
            let TRCLCellId = String(id + counterCellsCount)
            return "#\(TRCLCellId)"
        }
        // AI input lines are limited to 80 columns
        var excludedIdsString = ""
        var i = 0
        for id in excludedIds {
            if i > 11 {
                excludedIdsString += "\n        "
                i = 0
            } else {
                i += 1
                if excludedIdsString.count != 0 {
                    excludedIdsString += " "
                }
            }
            excludedIdsString += id
        }
        result += """
\nc ----- Moderator ------------
10003 1 -0.92 2 -5
        \(excludedIdsString)
        imp:n=1
"""
        result += """
\nc ----- Shield ------------
10004 4 -0.94 5 -6 imp:n=1
"""
        result += surfacesCard(chamberMax: chamberMax, chamberMin: chamberMin, moderatorSize: moderatorSize, moderatorLenght: moderatorLenght, shield: shield)
        result += modeCard()
        result += sourceCard(type: sourceType, isotope: sourceIsotope, sourcePositionZ: sourcePositionZ)
        result += materialsCard(shield: shield)
        result += tallyCard(layers, firstCounterCellId: ids.first!, totalDetectorsCount: totalDetectorsCount, lastCounterCellId: ids.last!)
        result += timeCard()
        result += controlCard(maxTime: maxTime)
        return result
    }
    
    fileprivate func sourceCard(type: SourceType, isotope: SourceIsotope, sourcePositionZ: Float) -> String {
        var sdef = ["erg=d1", "pos=0 0 \(sourcePositionZ.stringWith(precision: 1))", "wgt=1.0"]
        if type == .disk {
            sdef.append(contentsOf: ["axs=0 0 1", "ext=0.0001", "rad=\(type.radius)"]) // cylinder with 10 cm base and degenerate 1 μm height, placed parallel on z-axis
        }
        let sdefString = sdef.joined(separator: " ")
        return """
        \nc ---------------- SOURCE ------------
        SDEF \(sdefString)
        SP1 -3 \(isotope.coefficientA) \(isotope.coefficientB)
        """
    }
    
    fileprivate func timeCard() -> String {
        let max = 51200
        let step = 100
        var steps = ""
        var i = 0
        var j = 0
        while i <= max {
            if j > 5 {
                steps += "\n      "
                j = 0
            } else {
                j += 1
            }
            if steps.count != 0 {
                steps += " "
            }
            steps += String(i)
            i += step
        }
        return """
        \nT0 \(steps)
        """
    }
    
    fileprivate func surfacesCard(chamberMax: Float, chamberMin: Float, moderatorSize: Float, moderatorLenght: Float, shield: Shield) -> String {
        let counterSurfaces = counters.values.sorted { (c1: Counter, c2: Counter) -> Bool in // Sorting is important there, see Counter -convertSurfaceId() method implementation
            return c1.type.rawValue < c2.type.rawValue
            }.map { (c: Counter) -> String in
                return c.mcnpSurfaces()
            }.joined(separator: "\n")
        let shieldY = (moderatorSize + shield.thiknessY)/2
        let shieldX = (moderatorLenght + shield.thiknessX)/2
        return """
        \n\nc ==== Surfaces ====
        1 RPP \(-chamberMin/2) \(chamberMin/2) \(-chamberMin/2) \(chamberMin/2) \(-shieldX) \(shieldX) $ Internal Surface of Vacuum Chamber
        2 RPP \(-chamberMax/2) \(chamberMax/2) \(-chamberMax/2) \(chamberMax/2) \(-shieldX) \(shieldX) $ External Surface of Vacuum Chamber
        5 RPP \(-moderatorSize/2) \(moderatorSize/2) \(-moderatorSize/2) \(moderatorSize/2) \(-moderatorLenght/2) \(moderatorLenght/2) $ External Surface of Moderator
        6 RPP \(-shieldY) \(shieldY) \(-shieldY) \(shieldY) \(-shieldX) \(shieldX) $ Border of Geometry (Shield Size)
        \(counterSurfaces)
        """
    }
    
    fileprivate func modeCard() -> String {
        return """
        \n\nMODE N
        """
    }
    
    fileprivate func materialsCard(shield: Shield) -> String {
        return """
        \nc ---------------- MATERIALS ------------
        M1 6000.60c 1 1001.60c 2 $ Polyethylene
        M2 24000.42c -0.19 26000.21c -0.69 25055.50c -0.02 28000.42c -0.09
              29000.50c -0.01 $ Stainless Steel
        M3 2003.60c 1 $ He-3
        \(shield.materialCard(index: 4))
        """
    }
    
    fileprivate func overalTallyCoefficient(_ layers: [[CounterFrontView]]) -> Float {
        let allCounterViews = layers.joined()
        let countTotal = allCounterViews.count
        var result: Float = 0
        for (key, value) in counters {
            let filtered = allCounterViews.filter { (cv: CounterFrontView) -> Bool in
                return cv.type == key
            }
            result += value.tallyCoefficient() * Float(filtered.count)/Float(countTotal)
        }
        return result
    }
    
    fileprivate func tallyCard(_ layers: [[CounterFrontView]], firstCounterCellId: Int, totalDetectorsCount: Int, lastCounterCellId: Int) -> String {
        let overalCoefficient = overalTallyCoefficient(layers).stringWith(precision: 6)
        var result = """
\nc ---------------- TALLY ------------
F4:N \(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId) (\(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId))
FM4 (\(overalCoefficient) 3 \(npReactionId))
FQ4 f e
"""        
        //AI input lines are limited to 80 columns
        var i = 0
        for layer in layers {
            i += 1
            let indexes = layer.map({ (c: CounterFrontView) -> String in
                return String(c.mcnpCellId)
            })
            
            var s1Indexes = ""
            var j = 0
            for index in indexes {
                if j > 11 {
                    s1Indexes += "\n        "
                    j = 0
                } else {
                    j += 1
                }
                if s1Indexes.count != 0 {
                    s1Indexes += " "
                }
                s1Indexes += index
            }
            let s1 = "F\(i)4:N (\(s1Indexes))"
            
            let detectorsCount = layer.count
            let counter = counters[layer.first!.type]!
            let coefficient = (counter.tallyCoefficient() * Float(detectorsCount)).stringWith(precision: 6)
            let s2 = "FM\(i)4 (\(coefficient) 3 \(npReactionId)) $ \(detectorsCount) Detectors of Layer \(i)"
            result += "\n" + s1 + "\n" + s2
        }
        return result
    }
    
    fileprivate func controlCard(maxTime: Int) -> String {
        return """
        \nNPS 1000000000
        CTME \(maxTime)\n
        """
    }
    
}
