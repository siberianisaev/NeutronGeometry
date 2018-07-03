//
//  CountersLayerViewItem.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 03/07/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Cocoa

class CountersLayerViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var countField: NSTextField!
    @IBOutlet weak var radiusField: NSTextField!
    @IBOutlet weak var gapField: NSTextField!
    @IBOutlet weak var shiftAngleField: NSTextField!
    @IBOutlet weak var evenAngleField: NSTextField!
    
    class var identifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(rawValue: "CountersLayerViewItem")
    }
    
    class var nib: NSNib {
        let n = NSNib(nibNamed: NSNib.Name(rawValue: identifier.rawValue), bundle: nil)!
        return n
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.yellow.cgColor
    }
    
}
