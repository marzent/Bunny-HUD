/*
See LICENSE folder for licensing information.
*/


import Cocoa
import CEFswift
import WebKit

class CactbotConfig: NSViewController{
    @IBOutlet private var browserView: NSView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        var windowInfo = CEFWindowInfo()
        windowInfo.setAsChild(of: browserView as CEFWindowHandle, withRect: browserView.frame)
        let cefSettings = CEFBrowserSettings()
        let url = OverlayURL(modern: true, path: "ui/config/config.html", folder: GeneralSettingsController.cactbotFolder).computeURL
        CEFBrowserHost.createBrowser(windowInfo: windowInfo, client: nil, url: url, settings: cefSettings, userInfo: nil, requestContext: nil)
    }
}
