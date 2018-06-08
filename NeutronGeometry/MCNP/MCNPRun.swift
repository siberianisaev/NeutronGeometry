//
//  MCNPRun.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 24/05/2018.
//  Copyright © 2018 Flerov Laboratory. All rights reserved.
//

import Foundation

class MCNPRun {
    
    class func generateRunInfo(_ timeStamp: String) {
        let folder = FileManager.desktopFolderPathWithName(timeStamp)!
        let mcnpInputWithExtension = (FileManager.mcnpFilePath(timeStamp)! as NSString).lastPathComponent
        let mcnpInput = mcnpInputWithExtension.components(separatedBy: ".").first!
        let mcnpOutput = "\(mcnpInput)_o"
        var commands = [String]()
        let user = "aisaev@sbgli2.in2p3.fr"
        let userPath = "\(user):."
        commands.append("cd \(mcnpInput)")
        commands.append("scp -r \(mcnpInputWithExtension) \(userPath)")
        commands.append("mcnpx i=\(mcnpInputWithExtension) o=\(mcnpOutput) r=\(mcnpInput)_r")
        commands.append("scp \(userPath)/\(mcnpOutput) \(folder)")
        commands.append("cd ..")
        commands.append("\n\n\n\nssh -X \(user)")
        commands.append("source /libcern/mcnp/v27/sl5.8-x86_64/setup.sh")
        commands.append("\n\n\n\nrm *")
        let infoPath = FileManager.mcnpRunFilePath(timeStamp)!
        FileManager.writeString(commands.joined(separator: "\n"), path: infoPath)
    }
    
}
