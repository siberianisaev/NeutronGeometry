//
//  MCNPOutput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 23/05/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Foundation
import AppKit

class MCNPTimeOutput
{
    var times = [String]()
    var values1 = [String]()
    var values2 = [String]()
    
    func addTime(_ time: String, value1: String, value2: String) {
        times.append(time)
        values1.append(value1)
        values2.append(value2)
    }
    
    func stringValue() -> String {
        var result = ""
        for i in 0...times.count-1 {
            result += "\(times[i])  \(values1[i])   \(values2[i])\n"
        }
        return result
    }
    
}

class MCNPOutput {
    
    var times = [MCNPTimeOutput]() {
        didSet {
            let result = timesInfo()
            print(result)
            if let path = FileManager.mcnpTimesOutputFilePath(String.timeStamp()) {
                FileManager.writeString(result, path: path)
                NSWorkspace.shared.openFile(path)
            }
        }
    }
    
    func timesInfo() -> String {
        var result = ""
        for i in 0...times.count-1 {
            result += "Times for layer \(i+1):\n\n\(times[i].stringValue())\n\n"
        }
        return result
    }
    
    class func openResults(_ onFinish: @escaping ((MCNPOutput?) -> ())) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                let url = panel.urls.first
                onFinish(self.resultsWithUrl(url))
            }
        }
    }
    
    fileprivate class func resultsWithUrl(_ URL: Foundation.URL?) -> MCNPOutput? {
        let output = MCNPOutput()
        var timesResult = [MCNPTimeOutput]()
        if let URL = URL {
            let path = URL.path
            do {
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
//                print(content)
                let setLines = CharacterSet.newlines
                let lines = content.components(separatedBy: setLines)
                var i = 0
                while i < lines.count {
                    let line = lines[i]
                    if line.starts(with: " cell (") {
                        let next = lines[i+1]
                        if next.starts(with: " multiplier bin:") {
                            let timeOutput = MCNPTimeOutput()
                            var j = i+2
                            while j < lines.count {
                                let arrayTimes = lines[j].replacingOccurrences(of: "time:", with: "").components(separatedBy: CharacterSet.whitespaces).filter { (s: String) -> Bool in
                                    return !s.isEmpty
                                } // time headers
                                let arrayValues = lines[j+1].components(separatedBy: CharacterSet.whitespaces).filter { (s: String) -> Bool in
                                    return !s.isEmpty
                                } // A1 B1 A2 B2 ... values
                                for k in 0...arrayTimes.count-1 {
                                    let m = 2 * k
                                    timeOutput.addTime(arrayTimes[k], value1: arrayValues[m], value2: arrayValues[m+1])
                                }
                                
                                if lines[j+2].contains("1analysis") { // space line OR end line with info
                                    break
                                }
                                
                                j += 3
                            }
                            i = j
                            timesResult.append(timeOutput)
                        }
                    }
                    i += 1
                }
            } catch {
                print("Error load calibration from file at path \(path): \(error)")
            }
        }
        output.times = timesResult
        return output
    }
    
}
