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

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView.autoresizingMask = [.width, .height]
        popupWebView.navigationDelegate = self
        popupWebView.uiDelegate = self
        _ = PopupWindowDelegate(title: "Cactbot Configuration", contentView: popupWebView)
        return popupWebView
    }
}
