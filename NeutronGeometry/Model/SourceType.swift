//
//  SourceType.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 30/05/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

enum SourceType: Int, CaseCountable {
    case point = 0, disk = 1
    
    static let count = SourceType.countCases()
    
    func toggle() -> SourceType {
        return SourceType(rawValue: rawValue + 1) ?? .point
    }
    
    var name: String {
        switch self {
        case .point:
            return "Point"
        case .disk:
            return "Disk"
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .point:
            return 0
        case .disk:
            return 5
        }
    }
    
}
