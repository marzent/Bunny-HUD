/*
See LICENSE folder for licensing information.
*/


import Cocoa
import CEFswift
import WebKit

class CactbotConfig: NSViewController{
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue.cgColor
        var windowInfo = CEFWindowInfo()
        windowInfo.setAsChild(of: view as CEFWindowHandle, withRect: view.frame)
        let cefSettings = CEFBrowserSettings()
        let url = OverlayURL(modern: true, path: "ui/config/config.html", folder: GeneralSettingsController.cactbotFolder).computeURL
        CEFBrowserHost.createBrowser(windowInfo: windowInfo, client: nil, url: url, settings: cefSettings, userInfo: nil, requestContext: nil)
    }
}
