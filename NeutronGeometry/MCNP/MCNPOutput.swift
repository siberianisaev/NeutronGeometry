//
//  MCNPOutput.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 23/05/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
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
            }
        }
    }
    
    var tallies = [MCNPResult]() {
        didSet {
            var result = "Tally means for layers:\n" + tallies.map{ $0.toString() }.joined(separator: "\n")
            var totalTally: Double = 0
            var errorsSquaresSumm: Double = 0
            for tally in tallies {
                totalTally += tally.value
                errorsSquaresSumm += pow(tally.error, 2)
            }
            let efficiency = Float(totalTally * 100)
            let error = Float(errorsSquaresSumm.squareRoot() * 100)
            result += "\n\nEfficiency:\n\(efficiency.stringWith(precision: 2)) ± \(error.stringWith(precision: 2))%"
            print(result)
            if let resultsFilePath = resultsFilePath {
                let path = resultsFilePath + "_efficiency.txt"
                FileManager.writeString(result, path: path)
                
                let folder = (resultsFilePath as NSString).deletingLastPathComponent
                NSWorkspace.shared.openFile(folder)
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
                            headers.append("Time in Shakes") // 1 shake = 1E-8 seconds
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
                    if line.starts(with: " cell (") { // Times
                        var next = lines[i+1]
                        while !next.starts(with: " multiplier bin:") {
                            i += 1
                            next = lines[i+1]
                            if i >= lines.count {
                                break
                            }
                        }
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
                    
                    let chartPrefix = "1tally fluctuation charts"
                    if line.starts(with: chartPrefix) { // Tally start
                        var tallyLines = [String]()
                        var j = i+2
                        while j < lines.count {
                            let l = lines[j]
                            j += 1
                            if l.contains("***") { // Tally end
                                tallyLines = tallyLines.filter { (s: String) -> Bool in // 'chartPrefix' sometimes appears between tally tables
                                    return !s.starts(with: chartPrefix)
                                }
                                output.handleTally(tallyLines)
                                break
                            } else {
                                tallyLines.append(l)
                            }
                        }
                        i = j
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
    
    fileprivate func handleTally(_ lines: [String]) {
        let tallyChart = "tally"
        let count = lines.count
        var tallies = [MCNPResult]()
        if count > 0 {
            var i = 0
            while i < count {
                let line = lines[i]
                if line.contains(tallyChart) {
//                    do {
//                        let tallyRegex =  try NSRegularExpression(pattern: tallyChart, options: .caseInsensitive)
//                        let tablesCount = tallyRegex.numberOfMatches(in: line, options: [], range: NSRange(location: 0, length: line.count))
                        var j = i + 2
                        var values = [String]()
                        while j < count {
                            let l = lines[j]
                            if l.replacingOccurrences(of: " ", with: "").isEmpty {
                                if let last = values.last { // last line of tally charts
                                    // nps[0] mean[1] error[2] vov slope fom ... nps[0] mean[1] error[2] vov slope    fom
                                    let components = last.components(separatedBy: CharacterSet.whitespaces).filter { (s: String) -> Bool in
                                        return !s.isEmpty
                                    }
                                    for i in 0...components.count-1 {
                                        if components[i].contains("E") {
                                            let tally = MCNPResult(valueAndError: (components[i], components[i+1]))
                                            tallies.append(tally)
                                        }
                                    }
                                }
                                i = j
                                break
                            } else {
                                values.append(l)
                                j += 1
                            }
                        }
//                    } catch {
//                        print(error)
//                        return
//                    }
                }
                i += 1
            }
        }
        tallies.removeFirst() // filter overal "tally 4", we use only layers tally.
        self.tallies = tallies
    }
    
}
