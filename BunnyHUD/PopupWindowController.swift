//
//  PopupWindowController.swift
//  BunnyHUD
//
//  Created by Marc-Aurel Zent on 06.03.23.
//

import Cocoa

class PopupWindowDelegate: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.contentView?.removeFromSuperview()
        sender.contentViewController = nil
        return true
    }
    
    init(title: String, geometry: NSRect = NSRect(x: 20, y: 20, width: 800, height: 600), style: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable], contentView: NSView) {
        super.init()
        window = NSWindow(contentRect: geometry, styleMask: style, backing: .buffered, defer: false)
        window?.center()
        window?.isReleasedWhenClosed = false
        window?.title = title
        window?.delegate = self
        window?.contentView = contentView
        window?.makeKeyAndOrderFront(nil)
    }
}
