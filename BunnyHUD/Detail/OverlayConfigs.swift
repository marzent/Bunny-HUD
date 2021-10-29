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
        let url = OverlayURL(modern: true, path: "cactbot/ui/config/config.html").computeURL
        webView.loadFileURL(url, allowingReadAccessTo: url)
    }
}

class KagerouConfig: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = OverlayURL(modern: true, remote: true, path: "http://unsecure.idyllshi.re/kagerou/config").computeURL
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
