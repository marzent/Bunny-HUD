/*
See LICENSE folder for licensing information.
*/

import Cocoa
import CEFswift

class WebViewController: NSViewController, NSWindowDelegate {
    @IBOutlet private var blurView: NSVisualEffectView!
    var cefHandler : CEFHandler = CEFHandler()
    var windowInfo : CEFWindowInfo = CEFWindowInfo()
    var cefSettings : CEFBrowserSettings = CEFBrowserSettings()
    
    @objc var node: Node? {
        didSet {
            update()
            refresh()
        }
    }
    
    var snapshot : NSImage? {
        get {
            guard let window = view.window else { return nil }

            let inf = CGFloat(FP_INFINITE)
            let null = CGRect(x: inf, y: inf, width: 0, height: 0)

            guard let cgImage = CGWindowListCreateImage(null, .optionIncludingWindow,
                                                  CGWindowID(window.windowNumber), .bestResolution)
            else { return nil }
            let image = NSImage(cgImage: cgImage, size: view.bounds.size)

            return image
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        cefSettings.localStorage = .enabled
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
    
    func windowWillClose(_ notification: Notification) {
        cefHandler.close(force: true)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.isOpaque = false
        view.window?.level = .screenSaver
        view.window?.isMovableByWindowBackground = true
        //view.window?.titlebarAppearsTransparent = true
        //view.window?.titleVisibility = NSWindow.TitleVisibility.hidden
        view.window?.collectionBehavior = .canJoinAllSpaces
        view.window?.delegate = self
        view.window?.backgroundColor = NSColor.clear
    }
    
    func refresh() {
        let url = node!.url!.computeURL
        if let browser = cefHandler.browser {
            browser.mainFrame?.loadURL(url)
            return
        }
        windowInfo.setAsChild(of: view as CEFWindowHandle, withRect: view.frame)
        cefHandler.close(force: true)
        CEFBrowserHost.createBrowser(windowInfo: windowInfo, client: cefHandler, url: url, settings: cefSettings, userInfo: nil, requestContext: nil)
        view.window?.title = node!.title
    }
    
    func update() {
        cefHandler.setZoom(level: node!.zoom!)
        if let win = view.window {
            win.ignoresMouseEvents = !node!.clickable!
            win.styleMask = node!.resizeable! ? [.resizable, .borderless] : [.borderless]
            if node!.draggable! {
                win.styleMask.insert(.titled)
            }
            if node!.fullscreen! {
                node!.pos = win.frame
            }
            win.setFrame(node!.hidden! ? NSRect.zero : node!.pos!, display: true)
            blurView.alphaValue = node!.background! ? 1.0 : 0.0
        }
    }
    
}

class DragWindow: NSWindow, NSWindowDelegate {

    var draggable = false
    
    override var acceptsFirstResponder: Bool { return true }

    override public func mouseDown(with event: NSEvent) {
        super.mouseDragged(with: event)
        if draggable {
            performDrag(with: event)
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

class CEFHandler: CEFClient, CEFLifeSpanHandler {
    var browser : CEFBrowser?
    private var zoom : Double = 0
    
    var lifeSpanHandler: CEFLifeSpanHandler? {
        return self
    }
    
    func onAfterCreated(browser: CEFBrowser) {
        self.browser = browser
        setZoom(level: zoom)
    }
    
    func setZoom(level: Double) {
        zoom = level
        browser?.host?.zoomLevel = level
    }
    
    func onBeforeClose(browser: CEFBrowser) {
        self.browser = nil
    }
    
    func close(force: Bool) {
        browser?.host?.closeBrowser(force: force)
        
    }
}
