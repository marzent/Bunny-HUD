/*
See LICENSE folder for licensing information.
*/


import Cocoa
import CEFswift
import WebKit

class CactbotConfig: NSViewController{
    @IBOutlet private var browserView: NSView!
    private var cefHandler : CEFHandler = CEFHandler()
    let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/config/config.html").computeURL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        var windowInfo = CEFWindowInfo()
        windowInfo.setAsChild(of: browserView as CEFWindowHandle, withRect: browserView.frame)
        let cefSettings = CEFBrowserSettings()
        CEFBrowserHost.createBrowser(windowInfo: windowInfo, client: cefHandler, url: url, settings: cefSettings, userInfo: nil, requestContext: nil)
    }
    
    func reload() {
        cefHandler.browser?.mainFrame?.loadURL(url)
    }
}
