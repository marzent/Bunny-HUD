/*
See LICENSE folder for licensing information.
*/

import Foundation
import CEFswift

@_silgen_name("HelperMain")
public func helperMain() -> Int {
    let mainArgs = CEFMainArgs(arguments: CommandLine.arguments)
    let commandLine = CEFCommandLine()!
    commandLine.initFromArguments(CommandLine.arguments)
    
    let retval: Int
    if commandLine.switchValue(for: "type") == "renderer" {
        // renderer process
        // uncomment the following line in order to have the process paused until a debugger is attached
        //raise(SIGSTOP)
        retval = CEFProcessUtils.executeProcess(with: mainArgs, app: App())
    }
    else {
        // other helper processes spawned by CEF
        retval = CEFProcessUtils.executeProcess(with: mainArgs)
    }
    
    return retval
}
