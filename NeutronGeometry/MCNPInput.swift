//
//  MCNPInput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

class MCNPInput {
    
    fileprivate static let npReactionId = 103 // (n,p) reaction
    
    class func generateWith(layers: [[CounterView]], chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, counterLenght: Float, counterRadius7Atm: Float, counterRadius4Atm: Float, neutronSource: NeutronSource) -> String {
        let totalDetectorsCount = layers.joined().count
        //TODO: extract cells card method
        var result = """
Geometry for \(totalDetectorsCount) detectors.
c ==== CELLS =====
10000 0          5         imp:n=0  $ Space Outside Barrel
10001 0         -1   -5    imp:n=1  $ Space Inside of Vacuum Chamber
10002 2 -7.9    -2 1 -5    imp:n=1  $ Wall of Vacuum Chamber
"""
        var id = 10
        var ids = [Int]()
        for layer in layers {
            for counter in layer {
                let center = counter.center()
                counter.mcnpCellId = id
                let TRCL = String(format: "%.1f %.1f 0", center.x, center.y)
                let detector = counter.index + 1
                result += """
\nc ---------- Detector \(detector) ---------------------------
\(id) 4 -3.930e-3  53 -54 -57      imp:n=1 u=\(detector)   $ Couter's SV
\(id+1) 4 -3.930e-3  52 -53 -57      imp:n=1 u=\(detector)   $ Lower Complementation to SV
\(id+2) 4 -3.930e-3  54 -55 -57      imp:n=1 u=\(detector)   $ Upper Complementation to SV
\(id+3) 3 -7.91      51 -56 -58 (-52:55:57) imp:n=1 u=\(detector)  $ Wall of Counter
\(id+4) 0   (-51:56:58)   imp:n=1 u=\(detector)   $ Space around Counter
\(id+5) 0   -59 -5  imp:n=1 fill=\(detector)  TRCL=(\(TRCL))
"""
                id += 10
                ids.append(id-5)
            }
        }
        // Moderator cell negative to outer shell (surface 5), positive to vacuum tube (surface 2) and by excluding all He-3 counters cells
        let excludedIds = ids.map { (id: Int) -> String in
            return "#\(String(id))"
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
        result += surfacesCard(chamberMax: chamberMax, chamberMin: chamberMin, barrelSize: barrelSize, barrelLenght: barrelLenght, counterLenght: counterLenght, counterRadius7Atm: counterRadius7Atm, counterRadius4Atm: counterRadius4Atm)
        result += modeCard()
        result += sourceCard(neutronSource)
        result += materialsCard()
        result += tallyCard(layers, firstCounterCellId: ids.first!-5, totalDetectorsCount: totalDetectorsCount, lastCounterCellId: ids.last!-5) // TODO: -5 used to get start of cell
        result += controlCard()
        return result
    }
    
    fileprivate class func surfacesCard(chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, counterLenght: Float, counterRadius7Atm: Float, counterRadius4Atm: Float) -> String {
        return """
        \n\nc ==== Surfaces ====
        1 RPP \(-chamberMin/2) \(chamberMin/2) \(-chamberMin/2) \(chamberMin/2) \(-barrelLenght/2) \(barrelLenght/2) $ Internal Surface of Vacuum Chamber
        2 RPP \(-chamberMax/2) \(chamberMax/2) \(-chamberMax/2) \(chamberMax/2) \(-barrelLenght/2) \(barrelLenght/2) $ External Surface of Vacuum Chamber
        5 RPP \(-barrelSize/2) \(barrelSize/2) \(-barrelSize/2) \(barrelSize/2) \(-barrelLenght/2) \(barrelLenght/2) $ Border of Geometry (Barrel Size)
        \(counterSurfaces(counterLenght: counterLenght, counterRadius7Atm: counterRadius7Atm, counterRadius4Atm: counterRadius4Atm))
        """
    }
    
    fileprivate class func counterSurfaces(counterLenght: Float, counterRadius7Atm: Float, counterRadius4Atm: Float) -> String {
        // TODO: surfaces for 4 atm counter
        let counterWallThikness: Float = 0.08
        let counterСap: Float = 1.42
        let counterPZOutside = counterLenght/2
        let counterPZInside = counterPZOutside - counterWallThikness
        let counterPZActiveArea = counterPZInside - counterСap
        let counterCZOutside = counterRadius7Atm/10
        let counterCZInside = counterCZOutside - counterWallThikness
        let counterCZOutsideSpace = counterCZOutside + 0.02
        let s = """
        c ***** Detector *************************
        51 pz  -\(counterPZOutside)
        52 pz  -\(counterPZInside)
        53 pz  -\(counterPZActiveArea)
        54 pz   \(counterPZActiveArea)
        55 pz   \(counterPZInside)
        56 pz   \(counterPZOutside)
        57 cz   \(counterCZInside)
        58 cz   \(counterCZOutside)
        59 cz   \(counterCZOutsideSpace)
        """
        return s
    }
    
    fileprivate class func sourceCard(_ neutronSource: NeutronSource) -> String {
        let position = "pos=0 0 0"
        switch neutronSource {
        case .monoLine:
            return """
            \nc ---------------- SOURCE ------------
            SDEF  erg=0.5 \(position) wgt=1.0
            """
        case .Maxwell:
            return """
            \nc ---------------- SOURCE ------------
            SDEF  erg=d1 \(position) wgt=1.001938
            SI1   0.01  10 $ 10 MeV
            SP1  -2  1.28866
            """
        }
    }
    
    fileprivate class func modeCard() -> String {
        return """
        \n\nMODE N
        """
    }
    
    fileprivate class func materialsCard() -> String {
        return """
        \nc ---------------- MATERIALS ------------
        M1 6000.60c 1 1001.60c 2 $ Polyethylene
        c -------------- Stainless Steel ------------------------------------
        M2    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09
        c      Cr-nat           Fe-nat           Mn-55            Ni-nat
        29000.50c -0.01
        c      Cu-nat
        M3    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09 $ Fe
        c ----- Gas in Counter (2.7 atm. He-3 + 2 atm. Ar) ---------
        M4    2003.60c 0.57447  18000.35c 0.42553  $ Material of counters; Ro = 3.929868e-3
        M5     2003.60c 1                            $ He-3
        """
    }
    
    fileprivate class func tallyCard(_ layers: [[CounterView]], firstCounterCellId: Int, totalDetectorsCount: Int, lastCounterCellId: Int) -> String {
        var result = """
\nc ---------------- TALLY ------------
F4:N  \(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId) (\(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId))
FM4   (2.1627e-2 5 \(npReactionId))
FQ4   f e
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
            // 'FM' - поток по объему ячеек; '0.021627' - нормированный множитель, количество ядер He-3 в объеме; 'M5' - вещество He-3
            let s2 = "FM\(i)4   (\(0.021627 * Double(detectorsCount)) 5 \(npReactionId))   $ \(detectorsCount) Detectors of Layer \(i)"
            result += "\n" + s1 + "\n" + s2
        }
        return result
    }
    
    fileprivate class func controlCard() -> String {
        return """
        \nNPS 2000000000
        CTME 90\n
        """
    }
    
}
