//
//  OverlaySheetController.swift
//  BunnyHUD
//
//  Created by Marc-Aurel Zent on 26.10.21.
//
import Cocoa

class OverlaySheetController: NSViewController {
    
    @IBOutlet private var okButton: NSButton!
    @IBOutlet private var selector: NSPopUpButton!
    @IBOutlet private var nameField: NSTextField!
    
    @IBAction func okAction(_ sender: Any) {
        NotificationCenter.default.post(name: .addOverlayDone, object: nil,
                                        userInfo:[Notification.overlayKey.selector: selector.titleOfSelectedItem!,
                                                  Notification.overlayKey.name: nameField.stringValue])
        view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        view.window?.close()
    }
    
    override func viewWillAppear() {
        okButton.isHighlighted = true
    }
}
