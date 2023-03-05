/*
See LICENSE folder for licensing information.
*/


import Cocoa
import WebKit

class CactbotConfig: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = OverlayURL(modern: true, path: "http://proxy.iinact.com/overlay/cactbot/ui/config/config.html").computeURL
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

class KagerouConfig: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = OverlayURL(modern: true, path: "http://unsecure.idyllshi.re/kagerou/config").computeURL
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
