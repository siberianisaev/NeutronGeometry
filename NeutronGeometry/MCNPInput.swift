//
//  MCNPInput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 20/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation

class MCNPInput {
    
    class func generate(_ layers: [[CounterView]]) -> String {
        var result = """
Geometry with 54 Detectors. Single Detectors.
c ==== CELLS =====
1000 0          5         imp:n=0
1001 2 -0.0012 -1   -3    imp:n=1  $ Interior of Tube
1002 4 -7.9    -2 1 -3    imp:n=1  $ Wall of Tube

c ---- Internal Border Cells ------------
1003 0    -6  2 -3    imp:n=1
1004 0    -7  2 -3    imp:n=1
1005 0    -8  2 -3    imp:n=1
1006 0    -9  2 -3    imp:n=1
1007 0    -10 2 -3    imp:n=1
1008 0    -11 2 -3    imp:n=1

c ---- External Border Cells ------------
1009 0    -12   -3    imp:n=1
1010 0    -13   -3    imp:n=1
1011 0    -14   -3    imp:n=1
1012 0    -15   -3    imp:n=1
1013 0    -16   -3    imp:n=1
1014 0    -17   -3    imp:n=1
1015 0    -18   -3    imp:n=1
1016 0    -19   -3    imp:n=1
1017 0    -20   -3    imp:n=1
1018 0    -21   -3    imp:n=1
1019 0    -22   -3    imp:n=1
1020 0    -23   -3    imp:n=1
1021 0    -24   -3    imp:n=1
1022 0    -25   -3    imp:n=1
1023 0    -26   -3    imp:n=1
1024 0    -27   -3    imp:n=1
1025 0    -28   -3    imp:n=1
1026 0    -29   -3    imp:n=1
1027 0    -30   -3    imp:n=1
1028 0    -31   -3    imp:n=1
1029 0    -32   -3    imp:n=1
1030 0    -33   -3    imp:n=1
1031 0    -34   -3    imp:n=1
1032 0    -35   -3    imp:n=1
1033 0    -36   -3    imp:n=1
1034 0    -37   -3    imp:n=1
1035 0    -38   -3    imp:n=1
1036 0    -39   -3    imp:n=1
1037 0    -40   -3    imp:n=1
1038 0    -41   -3    imp:n=1

c ----- External Shielding --------------
1039 6 -1.18   103 -4  51 -56  imp:n=1   $ C5H8O2
1040 3 -0.94     4 -5  51 -56  imp:n=1   $ Boride Polyethylene
1041 0         103 -5 -51      imp:n=1   $ Lower Complementation
1042 0         103 -5  56      imp:n=1   $ Upper Complementation
1043 0           3 -103        imp:n=1   $ Space between Detectors & C5H8O2


$c ----- Lattice of Detectors ------------
$1044 1 -0.92  2 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
$        28 29 30 31 32 33 34 35 36 37 38 39 40 41 -3 61 #15 #25 #35 #45 #55 #65
$       #75 #85 #95 #105 #115 #125 #135 #145 #155 #165 #175 #185  imp:n=1
$1045 1 -0.92  2 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
$        28 29 30 31 32 33 34 35 36 37 38 39 40 41 -3 60 -61 #195 #205 #215 #225
$       #235 #245 #255 #265 #275 #285 #295 #305 #315 #325 #335 #345 #355 #365
$        imp:n=1
$1046 1 -0.92  2 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
$        28 29 30 31 32 33 34 35 36 37 38 39 40 41 -3 -60 #375 #385 #395 #405
$       #415 #425 #435 #445 #455 #465 #475 #485 #495 #505 #515 #525 #535 #545
$        imp:n=1
"""
        
        var id = 10 // TODO: поменять нумерацию ячеек
        for layer in layers {
            for counter in layer {
                let center = counter.center()
                counter.mcnpCellId = id
                result += """
\n
c ---------- Detector \(counter.index) ---------------------------
\(id) 8 -3.930e-3  53 -54 -57      imp:n=1 u=1   $ Couter's SV
\(id+1) 8 -3.930e-3  52 -53 -57      imp:n=1 u=1   $ Lower Complementation to SV
\(id+2) 8 -3.930e-3  54 -55 -57      imp:n=1 u=1   $ Upper Complementation to SV
\(id+3) 5 -7.91      51 -56 -58 (-52:55:57) imp:n=1 u=1  $ Wall of Counter
\(id+4) 0           (-51:56:58)             imp:n=1 u=1   $ Space around Counter
\(id+5) 0           -59 -3                  imp:n=1 fill=1 TRCL=(\(center.x) \(center.y) 0)
"""
                id += 6
            }
        }
        
        result += """
\n
c ==== Surfaces ====
1 cz   6.19                         $ Internal Surface of Tube
2 cz   6.59                         $ External Surface of Tube
3 RHP  0 0 -30  0 0 60  0 20.207 0  $ Internal Surface of C5H8O2
103 RHP  0 0 -30  0 0 60  0 20.8   0  $ Internal Surface of C5H8O2
4 RHP  0 0 -30  0 0 60  0 25.8   0  $ Internal Surface of CH2 + B
5 RHP  0 0 -30  0 0 60  0 30.8   0  $ Border of Geometry
c *** Internal Border *****************
6 RHP  2.5  4.3301 -31  0 0 62  2.5 0 0
7 RHP  5    0      -31  0 0 62  2.5 0 0
8 RHP  2.5 -4.3301 -31  0 0 62  2.5 0 0
9 RHP -2.5 -4.3301 -31  0 0 62  2.5 0 0
10 RHP -5    0      -31  0 0 62  2.5 0 0
11 RHP -2.5  4.3301 -31  0 0 62  2.5 0 0
c *** External Border ******************
12 RHP -7.5 21.6506 -31  0 0 62  2.5 0 0
13 RHP -2.5 21.6506 -31  0 0 62  2.5 0 0
14 RHP  2.5 21.6506 -31  0 0 62  2.5 0 0
15 RHP  7.5 21.6506 -31  0 0 62  2.5 0 0
c -----------------------------
16 RHP  15   17.3205 -31  0 0 62  2.5 0 0
17 RHP  17.5 12.9904 -31  0 0 62  2.5 0 0
18 RHP  20    8.6603 -31  0 0 62  2.5 0 0
19 RHP  22.5  4.3301 -31  0 0 62  2.5 0 0
c -----------------------------
20 RHP  22.5 -4.3301  -31  0 0 62  2.5 0 0
21 RHP  20.0 -8.6603  -31  0 0 62  2.5 0 0
22 RHP  17.5 -12.9904 -31  0 0 62  2.5 0 0
23 RHP  15.0 -17.3205 -31  0 0 62  2.5 0 0
c ------------------------------
24 RHP   7.5 -21.6506 -31  0 0 62  2.5 0 0
25 RHP   2.5 -21.6506 -31  0 0 62  2.5 0 0
26 RHP  -2.5 -21.6506 -31  0 0 62  2.5 0 0
27 RHP  -7.5 -21.6506 -31  0 0 62  2.5 0 0
c ------------------------------
28 RHP -15.0 -17.3205 -31  0 0 62  2.5 0 0
29 RHP -17.5 -12.9904 -31  0 0 62  2.5 0 0
30 RHP -20.0  -8.6603 -31  0 0 62  2.5 0 0
31 RHP -22.5  -4.3301 -31  0 0 62  2.5 0 0
c ------------------------------
32 RHP -22.5   4.3301 -31  0 0 62  2.5 0 0
33 RHP -20.0   8.6603 -31  0 0 62  2.5 0 0
34 RHP -17.5  12.9904 -31  0 0 62  2.5 0 0
35 RHP -15.0  17.3205 -31  0 0 62  2.5 0 0
c ------------------------------
36 RHP -12.5  21.6506 -31  0 0 62  2.5 0 0
37 RHP  12.5  21.6506 -31  0 0 62  2.5 0 0
38 RHP  25.0   0.0    -31  0 0 62  2.5 0 0
39 RHP -25.0   0.0    -31  0 0 62  2.5 0 0
40 RHP  12.5 -21.6506 -31  0 0 62  2.5 0 0
41 RHP -12.5 -21.6506 -31  0 0 62  2.5 0 0
c ***** Detector *************************
50 RHP  0 0 -30.5  0 0 61  2.5 0 0
51 pz  -25
52 pz  -24.92
53 pz  -23.5
54 pz   23.5
55 pz   24.92
56 pz   25
57 cz   1.42
58 cz   1.5
59 cz   1.52
c ------ Additional Surfaces -----
60 py  -6.4952
61 py   6.4952
"""
        result += modeCard(layers)
        return result
    }
    
    fileprivate class func modeCard(_ layers: [[CounterView]]) -> String {
        var result = """
\n
MODE N
SDEF  erg=d1 pos=0 0 0 wgt=1.001938
SI1   0.01  10
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
M8    2003.60c 0.57447  18000.35c 0.42553  $ Ro = 3.929868e-3
F4:N  10 52i 540 (10 52i 540)
FM4   (2.1627e-2 7 103)
FQ4   f e
"""
        var i = 0
        for layer in layers {
            i += 1
            let indexes = layer.map({ (c: CounterView) -> String in
                return String(c.mcnpCellId)
            }).joined(separator: " ")
            let detectorsCount = indexes.count
            let s1 = "F\(i)4:N  (\(indexes))"
            let s2 = "FM\(i)4   (\(0.021627 * Double(detectorsCount)) 7 103)   $ \(detectorsCount) Detectors of Layer \(i)"
            result += "\n" + s1 + "\n" + s2
        }
        
        result += """
\n
NPS   2000000000
CTME  90
"""
        return result
    }
    
}
