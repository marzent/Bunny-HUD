/*
 See LICENSE folder for licensing information.
 */

import Cocoa
import WebKit

class CactbotConfig: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = OverlaySheetController.systemOverlayURLs["Cactbot Configuration"]!.computeURL
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
