//
//  Extensions.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 23/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

extension NSWindow {
    
    func screenshot() -> NSImage? {
        if let windowImage = CGWindowListCreateImage(CGRect.null, .optionIncludingWindow, CGWindowID(windowNumber), .nominalResolution) {
            return NSImage(cgImage: windowImage, size: frame.size)
        } else {
            return nil
        }
    }
    
}

extension NSImage {
    
    func imagePNGRepresentation() -> Data? {
        if let imageTiffData = tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageTiffData) {
            return imageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey.interlaced: NSNumber(value: true)])
        }
        return nil
    }
    
}

extension FileManager {
    
    class func desktopFolder() -> NSString? {
        return NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first as NSString?
    }
    
    class func createIfNeedsDirectoryAtPath(_ path: String?) {
        if let path = path {
            let fm = FileManager.default
            if false == fm.fileExists(atPath: path) {
                do {
                    try fm.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    class func desktopFolderPathWithName(_ timeStamp: String?) -> NSString? {
        var path = desktopFolder()
        if let timeStamp = timeStamp {
            path = path?.appendingPathComponent(timeStamp) as NSString?
            createIfNeedsDirectoryAtPath(path as String?)
        }
        return path
    }
    
    class func desktopFilePathWithName(_ fileName: String, timeStamp: String?) -> String? {
        return desktopFolderPathWithName(timeStamp)?.appendingPathComponent(fileName)
    }
    
    class func screenshotFilePath(_ timeStamp: String) -> String? {
        return self.desktopFilePathWithName("screenshot_\(timeStamp).png", timeStamp: timeStamp)
    }
    
    class func writeImage(_ image: NSImage?, path: String?) {
        if let path = path {
            let url = URL.init(fileURLWithPath: path)
            do {
                try image?.imagePNGRepresentation()?.write(to: url)
            } catch {
                print("Error writing to file \(path): \(error)")
            }
        }
    }
    
    class func geometryFilePath(_ timeStamp: String) -> String? {
        return desktopFilePathWithName("\(timeStamp).geometry", timeStamp: timeStamp)
    }
    
    class func mcnpRunFilePath(_ timeStamp: String) -> String? {
        return desktopFilePathWithName("run.txt", timeStamp: timeStamp)
    }
    
    class func mcnpFilePath(_ timeStamp: String) -> String? {
        return desktopFilePathWithName("\(timeStamp).dat", timeStamp: timeStamp)
    }
    
    class func mcnpTimesOutputFilePath(_ timeStamp: String) -> String? {
        return desktopFilePathWithName("\(timeStamp).txt", timeStamp: timeStamp)
    }
    
    class func writeString(_ string: String, path: String?) {
        if let path = path {
            do {
                try string.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print("Error writing to file \(path): \(error)")
            }
        }
    }
    
}

extension String {
    
    static func timeStamp() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let sMonth = DateFormatter().monthSymbols[components.month! - 1]
        return String(format: "%d_%@_%d_%02d-%02d-%02d", components.year!, sMonth, components.day!, components.hour!, components.minute!, components.second!)
    }
    
}
