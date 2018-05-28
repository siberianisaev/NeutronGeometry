//
//  MCNPInput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

class MCNPInput {
    
    fileprivate let npReactionId = 103 // (n,p) reaction
    
    fileprivate var counter4Atm = Counter(type: .atm4)
    fileprivate var counter7AtmOld = Counter(type: .atm7Old)
    fileprivate var counter7AtmNew = Counter(type: .atm7New)
    
    fileprivate func counterForType(_ type: CounterType) -> Counter {
        switch type {
        case .atm4:
            return counter4Atm
        case .atm7Old:
            return counter7AtmOld
        case .atm7New:
            return counter7AtmNew
        }
    }
    
    fileprivate func convertViewLayersToMCNP(_ counterViewLayers: [[CounterFrontView]]) -> [[CounterFrontView]] {
        var mcnpLayers = [[CounterFrontView]]()
        for viewLayer in counterViewLayers {
            var atm4 = [CounterFrontView]()
            var atm7New = [CounterFrontView]()
            var atm7Old = [CounterFrontView]()
            for counterView in viewLayer {
                switch counterView.type {
                case .atm4:
                    atm4.append(counterView)
                case .atm7Old:
                    atm7Old.append(counterView)
                case .atm7New:
                    atm7New.append(counterView)
                }
            }
            if atm4.count > 0 {
                mcnpLayers.append(atm4)
            }
            if atm7Old.count > 0 {
                mcnpLayers.append(atm7Old)
            }
            if atm7New.count > 0 {
                mcnpLayers.append(atm7New)
            }
        }
        return mcnpLayers
    }
    
    func generateWith(counterViewLayers: [[CounterFrontView]], chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, maxTime: Int, sourcePositionZ: Float) -> String {
        let layers = convertViewLayersToMCNP(counterViewLayers)
        let totalDetectorsCount = layers.joined().count
        var result = """
Geometry for \(totalDetectorsCount) detectors.
c ==== CELLS =====
10000 0 5 imp:n=0 $ Space Outside Barrel
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
                let counter = counterForType(counterView.type)
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
\nc ----- Lattice of Detectors (Moderator cell) ------------
10003 1 -0.92 2 -5
        \(excludedIdsString)
        imp:n=1
"""
        result += surfacesCard(chamberMax: chamberMax, chamberMin: chamberMin, barrelSize: barrelSize, barrelLenght: barrelLenght)
        result += modeCard()
        result += sourceCard(sourcePositionZ)
        result += materialsCard()
        result += tallyCard(layers, firstCounterCellId: ids.first!, totalDetectorsCount: totalDetectorsCount, lastCounterCellId: ids.last!)
        result += timeCard()
        result += controlCard(maxTime: maxTime)
        return result
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
    
    fileprivate func surfacesCard(chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float) -> String {
        return """
        \n\nc ==== Surfaces ====
        1 RPP \(-chamberMin/2) \(chamberMin/2) \(-chamberMin/2) \(chamberMin/2) \(-barrelLenght/2) \(barrelLenght/2) $ Internal Surface of Vacuum Chamber
        2 RPP \(-chamberMax/2) \(chamberMax/2) \(-chamberMax/2) \(chamberMax/2) \(-barrelLenght/2) \(barrelLenght/2) $ External Surface of Vacuum Chamber
        5 RPP \(-barrelSize/2) \(barrelSize/2) \(-barrelSize/2) \(barrelSize/2) \(-barrelLenght/2) \(barrelLenght/2) $ Border of Geometry (Barrel Size)
        \(counter4Atm.mcnpSurfaces())
        \(counter7AtmOld.mcnpSurfaces())
        \(counter7AtmNew.mcnpSurfaces())
        """
    }
    
    /**
     Watt spectrum for 252Cf.
     */
    fileprivate func sourceCard(_ positionZ: Float) -> String {
        return """
        \nc ---------------- SOURCE ------------
        SDEF erg=d1 pos=0 0 \(positionZ.stringWith(precision: 1)) wgt=1.0
        SP1 -3 1.025 2.926
        """
    }
    
    fileprivate func modeCard() -> String {
        return """
        \n\nMODE N
        """
    }
    
    fileprivate func materialsCard() -> String {
        return """
        \nc ---------------- MATERIALS ------------
        M1 6000.60c 1 1001.60c 2 $ Polyethylene
        M2 24000.42c -0.19 26000.21c -0.69 25055.50c -0.02 28000.42c -0.09
              29000.50c -0.01 $ Stainless Steel
        M3 2003.60c 1 $ He-3
        """
    }
    
    fileprivate func overalTallyCoefficient(_ layers: [[CounterFrontView]]) -> Float {
        let allCounterViews = layers.joined()
        let atm4 = allCounterViews.filter { (cv: CounterFrontView) -> Bool in
            return cv.type == .atm4
        }
        let atm7Old = allCounterViews.filter { (cv: CounterFrontView) -> Bool in
            return cv.type == .atm7Old
        }
        let atm7New = allCounterViews.filter { (cv: CounterFrontView) -> Bool in
            return cv.type == .atm7New
        }
        let countAtm4 = Float(atm4.count)
        let countAtm7Old = Float(atm7Old.count)
        let countAtm7New = Float(atm7New.count)
        let countTotal = countAtm4 + countAtm7Old + countAtm7New
        return counter4Atm.tallyCoefficient() * countAtm4/countTotal + counter7AtmOld.tallyCoefficient() * countAtm7Old/countTotal + counter7AtmNew.tallyCoefficient() * countAtm7New/countTotal
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
            let counter = counterForType(layer.first!.type)
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
