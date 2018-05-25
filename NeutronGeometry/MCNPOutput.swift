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
    var fluxes = [String]()
    var errors = [String]()
    
    func addTime(_ time: String, flux: String, error: String) {
        times.append(time)
        fluxes.append(flux)
        errors.append(error)
    }
    
}

class MCNPOutput {
    
    fileprivate var resultsFilePath: String?
    
    var times = [MCNPTimeOutput]() {
        didSet {
            let result = timesInfo()
            print(result)
            if let resultsFilePath = resultsFilePath {
                let path = resultsFilePath + "_times.txt"
                FileManager.writeString(result, path: path)
                NSWorkspace.shared.openFile(path)
            }
        }
    }
    
    func timesInfo() -> String {
        let separator = "  "
        var result = ""
        let total = times.count
        if total > 0 {
            var headers = [String]()
            let columns = total * 2 + 1
            let timeValues = times[0].times
            let rows = timeValues.count
            for row in 0...rows-1 {
                var line = [String]()
                for column in 0...columns-1 {
                    if column == 0 {
                        let time = timeValues[row]
                        line.append(time)
                        if row == 0 {
                            headers.append("Time")
                        }
                    } else {
                        let dataIndex = (column-1) / 2
                        let data = times[dataIndex]
                        let isFlux = (column-1) % 2 == 0
                        let value = isFlux ? data.fluxes[row] : data.errors[row]
                        line.append(value)
                        if row == 0 {
                            headers.append("Layer\(dataIndex+1)_\(isFlux ? "Flux" : "Error")")
                        }
                    }
                }
                if row == 0 {
                    result += headers.joined(separator: separator) + "\n"
                }
                result += line.joined(separator: separator) + "\n"
            }
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
            output.resultsFilePath = path
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
                                    timeOutput.addTime(arrayTimes[k], flux: arrayValues[m], error: arrayValues[m+1])
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
