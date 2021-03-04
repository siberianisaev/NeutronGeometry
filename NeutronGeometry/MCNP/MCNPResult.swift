//
//  MCNPResult.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 04.03.2021.
//  Copyright © 2021 Flerov Laboratory. All rights reserved.
//

import Foundation

class MCNPResult {
    
    var value: Double = 0
    var error: Double = 0
    
    init(valueAndError: (String, String)) {
        var sError = valueAndError.1
        let sValue = valueAndError.0
        if let range = sValue.range(of: "E") {
            let expPower = sValue[range.lowerBound...]
            sError += expPower
        }
        value = Double(sValue)!
        error = Double(sError)!
    }
    
    func toString() -> String {
        return String(format: "%.5f ± %.5f", value, error)
    }
    
}
