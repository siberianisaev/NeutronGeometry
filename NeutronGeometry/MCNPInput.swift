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
    
    fileprivate var counter7Atm: Counter!
    fileprivate var counter4Atm: Counter!
    
    func generateWith(layers: [[CounterView]], chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, counter7Atm: Counter, counter4Atm: Counter, neutronSource: NeutronSource, maxTime: Int) -> String {
        self.counter7Atm = counter7Atm
        self.counter4Atm = counter4Atm
        
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
        result += surfacesCard(chamberMax: chamberMax, chamberMin: chamberMin, barrelSize: barrelSize, barrelLenght: barrelLenght)
        result += modeCard()
        result += sourceCard(neutronSource)
        result += materialsCard()
        result += tallyCard(layers, firstCounterCellId: ids.first!-5, totalDetectorsCount: totalDetectorsCount, lastCounterCellId: ids.last!-5) // TODO: -5 used to get start of cell
        result += controlCard(maxTime: maxTime)
        return result
    }
    
    fileprivate func surfacesCard(chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float) -> String {
        return """
        \n\nc ==== Surfaces ====
        1 RPP \(-chamberMin/2) \(chamberMin/2) \(-chamberMin/2) \(chamberMin/2) \(-barrelLenght/2) \(barrelLenght/2) $ Internal Surface of Vacuum Chamber
        2 RPP \(-chamberMax/2) \(chamberMax/2) \(-chamberMax/2) \(chamberMax/2) \(-barrelLenght/2) \(barrelLenght/2) $ External Surface of Vacuum Chamber
        5 RPP \(-barrelSize/2) \(barrelSize/2) \(-barrelSize/2) \(barrelSize/2) \(-barrelLenght/2) \(barrelLenght/2) $ Border of Geometry (Barrel Size)
        \(counterSurfaces())
        """
    }
    
    // TODO: surfaces for 4 atm counter
    fileprivate func counterSurfaces() -> String {
        let s = """
        c ***** Detector *************************
        51 pz  -\(counter7Atm.pzOutside)
        52 pz  -\(counter7Atm.pzInside)
        53 pz  -\(counter7Atm.pzActiveArea)
        54 pz   \(counter7Atm.pzActiveArea)
        55 pz   \(counter7Atm.pzInside)
        56 pz   \(counter7Atm.pzOutside)
        57 cz   \(counter7Atm.czInside)
        58 cz   \(counter7Atm.czOutside)
        59 cz   \(counter7Atm.czOutsideSpace)
        """
        return s
    }
    
    fileprivate func sourceCard(_ neutronSource: NeutronSource) -> String {
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
    
    fileprivate func modeCard() -> String {
        return """
        \n\nMODE N
        """
    }
    
    // TODO: material for 4 atm counter
    fileprivate func materialsCard() -> String {
        return """
        \nc ---------------- MATERIALS ------------
        M1 6000.60c 1 1001.60c 2 $ Polyethylene
        c -------------- Stainless Steel ------------------------------------
        M2    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09
        c      Cr-nat           Fe-nat           Mn-55            Ni-nat
              29000.50c -0.01
        c      Cu-nat
        M3    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09 $ Fe
        c ----- Gas in Counter (\(counter7Atm.heliumPresure) atm. He-3 + \(counter7Atm.argonPresure) atm. Ar) ---------
        M4    2003.60c \(counter7Atm.heliumFraction) 18000.35c \(counter7Atm.argonFraction) $ Material of counters; Ro = 3.929868e-3
        M5     2003.60c 1                            $ He-3
        """
    }
    
    fileprivate func stringFrom(number: Float, precision: Int) -> String {
        let format = "%.\(precision)f"
        return String(format: format, number)
    }
    
    fileprivate func tallyCard(_ layers: [[CounterView]], firstCounterCellId: Int, totalDetectorsCount: Int, lastCounterCellId: Int) -> String {
        let coefficient = counter7Atm.tallyCoefficient()
        var result = """
\nc ---------------- TALLY ------------
F4:N  \(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId) (\(firstCounterCellId) \(totalDetectorsCount-2)i \(lastCounterCellId))
FM4   (\(stringFrom(number: coefficient, precision: 6)) 5 \(npReactionId))
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
            let s2 = "FM\(i)4   (\(stringFrom(number: coefficient * Float(detectorsCount), precision: 6)) 5 \(npReactionId))   $ \(detectorsCount) Detectors of Layer \(i)" // M5 is He-3
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
