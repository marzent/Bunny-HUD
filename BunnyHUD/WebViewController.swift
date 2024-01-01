/*
 See LICENSE folder for licensing information.
 */

import Cocoa
import WebKit

class WebViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, NSWindowDelegate {
    var webView: WebDragView!
    var blurView: NSVisualEffectView!
    var newWebviewPopupWindow: WKWebView?
    weak var windowController: NSWindowController?
    @objc var node: Node? {
        didSet {
            refresh()
            update()
        }
    }
   
    override func loadView() {
        let pool = WKProcessPool()
        let selector = NSSelectorFromString("_registerURLSchemeAsSecure:")
        pool.perform(selector, with: NSString(string: "ws"))
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = pool
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webConfiguration.preferences.setValue(true, forKey: "javaScriptCanOpenWindowsAutomatically")
        webConfiguration.preferences.setValue(true, forKey: "javaScriptEnabled")
        webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webView = WebDragView(frame: CGRect(x: 0, y: 0, width: 800, height: 600), configuration: webConfiguration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.uiDelegate = self
        blurView = NSVisualEffectView(frame: webView.frame)
        blurView.blendingMode = .behindWindow
        blurView.material = .hudWindow
        blurView.state = .active
        blurView.autoresizingMask = [.width, .height]
        view = webView
        view.addSubview(blurView, positioned: .below, relativeTo: webView)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView.autoresizingMask = [.width, .height]
        popupWebView.navigationDelegate = self
        popupWebView.uiDelegate = self
        _ = PopupWindowDelegate(title: node?.title ?? "Popup", contentView: popupWebView)
        return popupWebView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    func updateLayout() {
        if node!.hidden! {
            return
        }
        if let pos = view.window?.frame {
            node!.pos = pos
            NotificationCenter.default.post(name: Notification.Name(OverlaySettingsController.NotificationNames.layoutChanged), object: nil)
        }
    }
    
    func windowDidResize(_: Notification) {
        updateLayout()
    }
    
    func windowDidMove(_: Notification) {
        updateLayout()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.isOpaque = false
        view.window?.level = .screenSaver
        view.window?.titlebarAppearsTransparent = true
        view.window?.titleVisibility = NSWindow.TitleVisibility.hidden
        view.window?.collectionBehavior = .canJoinAllSpaces
        view.window?.backgroundColor = NSColor.clear
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
        blurView.alphaValue = node!.background! ? 1.0 : 0.0
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
}
