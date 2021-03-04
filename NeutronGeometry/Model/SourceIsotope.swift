//
//  SourceIsotope.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 06/06/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

/**
 Watt spectrum
 */
enum SourceIsotope: Int, CaseCountable {
    case Pu240, Pu242, Cm242, Cm244, Cm248, Cf252
    
    var name: String {
        switch self {
        case .Pu240:
            return "Pu-240"
        case .Pu242:
            return "Pu-242"
        case .Cm242:
            return "Cm-242"
        case .Cm244:
            return "Cm-244"
        case .Cm248:
            return "Cm-248"
        case .Cf252:
            return "Cf-252"
        }
    }
    
    var coefficientA: Float {
        switch self {
        case .Pu240:
            return 0.799
        case .Pu242:
            return 0.833668
        case .Cm242:
            return 0.891
        case .Cm244:
            return 0.906
        case .Cm248:
            return 0.808387
        case .Cf252:
            return 1.025
        }
    }
    
    var coefficientB: Float {
        switch self {
        case .Pu240:
            return 4.903
        case .Pu242:
            return 4.431658
        case .Cm242:
            return 4.046
        case .Cm244:
            return 3.848
        case .Cm248:
            return 4.53623
        case .Cf252:
            return 2.926
        }
    }
    
    static let count = SourceIsotope.countCases()
}
