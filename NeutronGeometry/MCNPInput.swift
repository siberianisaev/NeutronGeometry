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
    
    fileprivate var counter7Atm = Counter(presure: .high)
    fileprivate var counter4Atm = Counter(presure: .low)
    
    fileprivate func convertViewLayersToMCNP(_ counterViewLayers: [[CounterView]]) -> [[CounterView]] {
        var mcnpLayers = [[CounterView]]()
        for viewLayer in counterViewLayers {
            var atm4 = [CounterView]()
            var atm7 = [CounterView]()
            for counterView in viewLayer {
                switch counterView.presure {
                case .high:
                    atm7.append(counterView)
                case .low:
                    atm4.append(counterView)
                }
            }
            if atm4.count > 0 {
                mcnpLayers.append(atm4)
            }
            if atm7.count > 0 {
                mcnpLayers.append(atm7)
            }
        }
        return mcnpLayers
    }
    
    func generateWith(counterViewLayers: [[CounterView]], chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, maxTime: Int) -> String {
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
                let counter = counterView.presure == .high ? counter7Atm : counter4Atm
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
        result += sourceCard()
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
        \(counter7Atm.mcnpSurfaces())
        \(counter4Atm.mcnpSurfaces())
        """
    }
    
    /**
     Watt spectrum for 252Cf.
     */
    fileprivate func sourceCard() -> String {
        return """
        \nc ---------------- SOURCE ------------
        SDEF erg=d1 pos=0 0 0 wgt=1.0
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
    
    fileprivate func overalTallyCoefficient(_ layers: [[CounterView]]) -> Float {
        let allCounterViews = layers.joined()
        let atm7 = allCounterViews.filter { (cv: CounterView) -> Bool in
            return cv.presure == .high
        }
        let atm4 = allCounterViews.filter { (cv: CounterView) -> Bool in
            return cv.presure == .low
        }
        let countAtm7 = Float(atm7.count)
        let countAtm4 = Float(atm4.count)
        let countTotal = countAtm7 + countAtm4
        return counter7Atm.tallyCoefficient() * countAtm7/countTotal + counter4Atm.tallyCoefficient() * countAtm4/countTotal
    }
    
    fileprivate func tallyCard(_ layers: [[CounterView]], firstCounterCellId: Int, totalDetectorsCount: Int, lastCounterCellId: Int) -> String {
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
            let indexes = layer.map({ (c: CounterView) -> String in
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
            let counter = layer.first!.presure == .high ? counter7Atm : counter4Atm
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
