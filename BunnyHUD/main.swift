/*
See LICENSE folder for licensing information.
*/

import Cocoa
import CEFswift

class CEFApplication: NSApplication, CefAppProtocol {
    private var handlingSendEvent = false

    @objc
    func isHandlingSendEvent() -> Bool {
        return handlingSendEvent
    }

    @objc
    func setHandlingSendEvent(_ handlingSendEvent: Bool) {
        self.handlingSendEvent = handlingSendEvent
    }

    @objc
    override func sendEvent(_ event: NSEvent) {
        let stashedIsHandlingSendEvent = handlingSendEvent
        handlingSendEvent = true
        defer { handlingSendEvent = stashedIsHandlingSendEvent }
        super.sendEvent(event)
    }
}

let app = CEFApplication.shared
let args = CEFMainArgs(arguments: CommandLine.arguments + ["--use-mock-keychain", "--autoplay-policy=no-user-gesture-required"])
var settings = CEFSettings()
let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
settings.cachePath = applicationSupport.appendingPathComponent("Bunny HUD/Cache").path
if !FileManager.default.fileExists(atPath: settings.cachePath) {
    do {
        try FileManager.default.createDirectory(atPath: settings.cachePath, withIntermediateDirectories: true, attributes: nil)
    }
    catch {
        print(error.localizedDescription)
    }
}
settings.persistSessionCookies = true
settings.persistUserPreferences = true
_ = CEFProcessUtils.initializeMain(with: args, settings: settings)

let delegate = AppDelegate()
app.delegate = delegate

DispatchQueue.main.async {
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
CEFProcessUtils.runMessageLoop()
CEFProcessUtils.shutDown()

exit(0)


