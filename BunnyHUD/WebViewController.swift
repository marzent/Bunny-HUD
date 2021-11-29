/*
See LICENSE folder for licensing information.
*/

import Cocoa
import CEFswift

class WebViewController: NSViewController, NSWindowDelegate {
    var cefHandler : CEFHandler = CEFHandler()
    var windowInfo : CEFWindowInfo = CEFWindowInfo()
    var cefSettings : CEFBrowserSettings = CEFBrowserSettings()
    
    @objc var node: Node? {
        didSet {
            update()
            refresh()
            cefHandler.setZoom(level: node!.zoom!)
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        cefSettings.localStorage = .enabled
//        view.wantsLayer = true
//        view.layer?.backgroundColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 0.3)
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
        //view.window?.isMovableByWindowBackground = true
        //view.window?.titlebarAppearsTransparent = true
        //view.window?.titleVisibility = NSWindow.TitleVisibility.hidden
        //view.window?.makeKeyAndOrderFront(self.view.window)
        view.window?.collectionBehavior = .canJoinAllSpaces
        view.window?.delegate = self
    }
    
    func refresh() {
        windowInfo.setAsChild(of: view as CEFWindowHandle, withRect: view.frame)
        let url = node!.url!.computeURL
        cefHandler.close(force: true)
        CEFBrowserHost.createBrowser(windowInfo: windowInfo, client: cefHandler, url: url, settings: cefSettings, userInfo: nil, requestContext: nil)
        view.window?.title = node!.title
    }
    
    func update() {
        cefHandler.setZoom(level: node!.zoom!)
        let win = view.window
        win?.ignoresMouseEvents = !node!.clickable!
        if node!.resizeable! {
            win?.styleMask = [.resizable, .borderless]
        }
        else {
            win?.styleMask = [.borderless]
        }
        if node!.draggable! {
            win?.styleMask.insert(.titled)
        }
        if node!.fullscreen! {
            node!.pos = win?.frame
        }
        win?.setFrame(node!.hidden! ? NSRect.zero : node!.pos!, display: true)
        if node!.background! {
            view.window?.backgroundColor = NSColor.init(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        }
        else {
            view.window?.backgroundColor = NSColor.clear
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
    private var _browser : CEFBrowser?
    
    var lifeSpanHandler: CEFLifeSpanHandler? {
        return self
    }
    
    func onAfterCreated(browser: CEFBrowser) {
        _browser = browser
    }
    
    func setZoom(level: Double) {
        _browser?.host?.zoomLevel = level
    }
    
    func onBeforeClose(browser: CEFBrowser) {
        self.dragHandler
        _browser = nil
    }
    
    func close(force: Bool) {
        _browser?.host?.closeBrowser(force: force)
        
    }
}
