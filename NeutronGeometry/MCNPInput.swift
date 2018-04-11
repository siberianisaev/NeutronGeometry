//
//  MCNPInput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

class MCNPInput {
    
    class func generateWith(layers: [[CounterView]], chamberMax: Float, chamberMin: Float, barrelSize: Float, barrelLenght: Float, counterLenght: Float, counterRadius7Atm: Float, counterRadius4Atm: Float) -> String {
        var result = """
Geometry for \(layers.joined().count) detectors.
c ==== CELLS =====
1000 0          5         imp:n=0  $ Space Outside Barrel
1001 2 -0.0012 -1   -5    imp:n=1  $ Space Inside of Vacuum Chamber
1002 4 -7.9    -2 1 -5    imp:n=1  $ Wall of Vacuum Chamber
"""
        var id = 10 // TODO: поменять нумерацию ячеек
        var ids = [id]
        for layer in layers {
            for counter in layer {
                let center = counter.center()
                counter.mcnpCellId = id
                let TRCL = String(format: "%.3f %.3f 0", center.x, center.y)
                result += """
\nc ---------- Detector \(counter.index + 1) ---------------------------
\(id) 8 -3.930e-3  53 -54 -57      imp:n=1 u=1   $ Couter's SV
\(id+1) 8 -3.930e-3  52 -53 -57      imp:n=1 u=1   $ Lower Complementation to SV
\(id+2) 8 -3.930e-3  54 -55 -57      imp:n=1 u=1   $ Upper Complementation to SV
\(id+3) 5 -7.91      51 -56 -58 (-52:55:57) imp:n=1 u=1  $ Wall of Counter
\(id+4) 0   (-51:56:58)   imp:n=1 u=1   $ Space around Counter
\(id+5) 0   -59 -5  imp:n=1 fill=1  TRCL=(\(TRCL))
"""
                id += 6
                ids.append(id)
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
\n$c ----- Lattice of Detectors (Moderator cell) ------------
1044 1 -0.92 2 -5
        \(excludedIdsString)
        imp:n=1
"""
        // TODO: detectors lenghts and radiuses for different atmospheres
        result += """
\nc ==== Surfaces ====
1 RPP \(-chamberMin/2) \(chamberMin/2) \(-chamberMin/2) \(chamberMin/2) \(-barrelLenght/2) \(barrelLenght/2) $ Internal Surface of Vacuum Chamber
2 RPP \(-chamberMax/2) \(chamberMax/2) \(-chamberMax/2) \(chamberMax/2) \(-barrelLenght/2) \(barrelLenght/2) $ External Surface of Vacuum Chamber
5 RPP \(-barrelSize/2) \(barrelSize/2) \(-barrelSize/2) \(barrelSize/2) \(-barrelLenght/2) \(barrelLenght/2) $ Border of Geometry (Barrel Size)
c ***** Detector *************************
51 pz  -25
52 pz  -24.92
53 pz  -23.5
54 pz   23.5
55 pz   24.92
56 pz   25
57 cz   1.42
58 cz   1.5
59 cz   1.52
"""
        result += modeCard(layers, lastCounterCellId: id)
        return result
    }
    
    fileprivate class func modeCard(_ layers: [[CounterView]], lastCounterCellId: Int) -> String {
        var result = """
\nMODE N
SDEF  erg=d1 pos=0 0 0 wgt=1.001938 $ Source definition
SI1   0.01  10 $ 10 MeV
SP1  -2  1.28866
c --------------------------------------------------
M1     6000.60c 1  1001.60c 2      $ Polyethylene
$ MT1 poly.03t
M2   7014.60c -0.755  8016.60c -0.232  18000.35c -0.013 $ Air
c -------------- Borided (3% weight) Polyethylene, Ro=0.94 ----------
c M3   6000.60c -0.8314  1001.60c -0.1386  5010.60c -0.00594 5011.60c -0.02406
c -------------- Borided (5% weight) Polyethylene, Ro=0.94 ----------
M3   6000.60c -0.8143  1001.60c -0.1357  5010.60c -0.00990 5011.60c -0.04010
c -------------- Stainless Steel ------------------------------------
M4    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09
c      Cr-nat           Fe-nat           Mn-55            Ni-nat
29000.50c -0.01
c      Cu-nat
M5    24000.42c -0.19  26000.21c -0.69  25055.50c -0.02  28000.42c -0.09 $ Fe
M6     6000.60c 5  1001.60c 8  8016.60c 2    $ C5H8O2 (Ro = 1.18)
M7     2003.60c 1                            $ He-3
c ----- TODO: !!! Gas in Counter (2.7 atm. He-3 + 2 atm. Ar) ---------
M8    2003.60c 0.57447  18000.35c 0.42553  $ Material of counters; Ro = 3.929868e-3
F4:N  10 52i \(lastCounterCellId) (10 52i \(lastCounterCellId))
FM4   (2.1627e-2 7 103)
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
                    if s1Indexes.count != 0 {
                        s1Indexes += " "
                    }
                    s1Indexes += index
                }
            }
            let s1 = "F\(i)4:N (\(s1Indexes))"
            
            let detectorsCount = layer.count
            // 'FM' - поток по объему ячеек; '0.021627' - нормированный множитель, количество ядер He-3 в объеме; '7' - вещество He-3; '103' - номер реакции (n + He-3)
            let s2 = "FM\(i)4   (\(0.021627 * Double(detectorsCount)) 7 103)   $ \(detectorsCount) Detectors of Layer \(i)"
            result += "\n" + s1 + "\n" + s2
        }
        result += """
\nNPS   2000000000
CTME  90
"""
        return result
    }
    
}
