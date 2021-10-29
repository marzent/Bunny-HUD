/*
See LICENSE folder for licensing information.
*/

import Cocoa
import WebKit

class WebViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, NSWindowDelegate
    {
    var webView: WebDragView!
    var newWebviewPopupWindow: WKWebView?
    weak var windowController: NSWindowController?
    @objc var node: Node? {
        didSet {
            refresh()
            update()
        }
    }
   
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration ()
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webConfiguration.preferences.setValue(true, forKey: "javaScriptCanOpenWindowsAutomatically")
        //webConfiguration.preferences.setValue(true, forKey: "allowsContentJavaScript")
        webConfiguration.preferences.setValue(true, forKey: "javaScriptEnabled")
        webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webView = WebDragView (frame: CGRect(x:0, y:0, width:800, height:600), configuration:webConfiguration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.uiDelegate = self
        view = webView
        }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) { completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!)) }
    
    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        self.webView?.load(navigationAction.request)
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    func updateLayout() {
        if node!.hidden! {
            return
        }
        if let pos = view.window?.frame  {
            node!.pos = pos
            NotificationCenter.default.post(name: Notification.Name(OverlaySettingsController.NotificationNames.layoutChanged), object: nil)
        }
    }
    
    func windowDidResize(_ notification: Notification) {
        updateLayout()
    }
    
    func windowDidMove(_ notification: Notification) {
        updateLayout()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.isOpaque = false
        view.window?.level = .screenSaver
        //view.window?.isMovableByWindowBackground = true
        view.window?.titlebarAppearsTransparent = true
        view.window?.titleVisibility = NSWindow.TitleVisibility.hidden
        //view.window?.makeKeyAndOrderFront(self.view.window)
        view.window?.collectionBehavior = .canJoinAllSpaces
        view.window?.delegate = self
        windowController = view.window?.windowController
        
    }
    
    func refresh() {
        let url = node!.url!.computeURL
        if node!.url!.remote {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        else {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        view.window?.title = node!.title
    }
    
    func update() {
        webView.pageZoom = node!.zoom!
        view.window?.ignoresMouseEvents = !node!.clickable!
        if node!.resizeable! {
            view.window?.styleMask = [.resizable, .fullSizeContentView, .closable]
        }
        else {
            view.window?.styleMask = [.fullSizeContentView, .closable]
        }
        if node!.fullscreen! {
            node!.pos = view.window?.screen?.frame
        }
        view.window?.setFrame(node!.hidden! ? NSRect.zero : node!.pos!, display: true)
        webView.draggable = node!.draggable!
        if node!.background! {
            view.window?.backgroundColor = NSColor.init(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        }
        else {
            view.window?.backgroundColor = NSColor.clear
        }
    }
    
}

class WebDragView: WKWebView {
    
    var draggable = false
    
    override public func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        if draggable {
            window?.performDrag(with: event)
        }
    }
//    
//    override func hitTest(_ point: NSPoint) -> NSView? {
//        return nil
//    }
}

class ClickTroughWindow: NSWindow {
//    override func accessibilityHitTest(_ point: NSPoint) -> Any? {
//        return nil
//    }
}
