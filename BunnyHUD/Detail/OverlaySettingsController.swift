/*
See LICENSE folder for licensing information.
*/


import Cocoa

class OverlaySettingsController: NSViewController {
    
    struct NotificationNames {
        static let nodeChanged = "NodeChangedNotification"
        static let layoutChanged = "LayoutChangedNotification"
    }
    
    @IBOutlet private var xPosition: NSTextField!
    @IBOutlet private var yPosition: NSTextField!
    @IBOutlet private var width: NSTextField!
    @IBOutlet private var height: NSTextField!
    @IBOutlet private var clickable: NSButton!
    @IBOutlet private var hidden: NSButton!
    @IBOutlet private var resizeable: NSButton!
    @IBOutlet private var draggable: NSButton!
    @IBOutlet private var fullscreen: NSButton!
    @IBOutlet private var background: NSButton!
    @IBOutlet private var reload: NSButton!
    @IBOutlet private var resetZoom: NSButton!
    @IBOutlet private var zoom: NSSlider!
    
    var overlayController: WebViewController?
    
    @objc var node: Node? {
        // Listen for changes in the file URL.
        didSet {
            updateView()
        }
    }
    
    @IBAction func updateNode(_ sender: Any) {
        updateNode()
        overlayController?.update()
        updateView()
    }
    
    private func updateNode() {
        node!.pos = NSRect(x: xPosition.doubleValue, y: yPosition.doubleValue, width: width.doubleValue, height: height.doubleValue)
        node!.clickable = clickable.state == NSControl.StateValue.on ? true : false
        node!.hidden = hidden.state == NSControl.StateValue.on ? true : false
        node!.resizeable = resizeable.state == NSControl.StateValue.on ? true : false
        node!.draggable = draggable.state == NSControl.StateValue.on ? true : false
        node!.background = background.state == NSControl.StateValue.on ? true : false
        node!.fullscreen = fullscreen.state == NSControl.StateValue.on ? true : false
        node!.zoom = CGFloat(zoom.floatValue)
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.nodeChanged), object: nil)
    }
    
    private func updateView() {
        if node == nil  {
            return
        }
        xPosition.stringValue = "\(Int(node!.pos!.origin.x))"
        yPosition.stringValue = "\(Int(node!.pos!.origin.y))"
        width.stringValue = "\(Int(node!.pos!.width))"
        height.stringValue = "\(Int(node!.pos!.height))"
        clickable.state = node!.clickable! ? NSControl.StateValue.on : NSControl.StateValue.off
        hidden.state = node!.hidden! ? NSControl.StateValue.on : NSControl.StateValue.off
        resizeable.state = node!.resizeable! ? NSControl.StateValue.on : NSControl.StateValue.off
        draggable.state = node!.draggable! ? NSControl.StateValue.on : NSControl.StateValue.off
        background.state = node!.background! ? NSControl.StateValue.on : NSControl.StateValue.off
        fullscreen.state = node!.fullscreen! ? NSControl.StateValue.on : NSControl.StateValue.off
        zoom.floatValue = Float(node!.zoom!)
    }
    
    @IBAction func resetZoom(_ sender: Any) {
        zoom.floatValue = 0.0
        node!.zoom = CGFloat(zoom.floatValue)
        overlayController?.update()
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.nodeChanged), object: nil)
    }
    
    @IBAction func reloadURL(_ sender: Any) {
        overlayController?.refresh()
    }
    
    @objc
    private func updateLayout(_ notif: Notification) {
        updateView()
        NotificationCenter.default.post(name: Notification.Name(NotificationNames.nodeChanged), object: nil)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLayout(_:)),
            name: Notification.Name(OverlaySettingsController.NotificationNames.layoutChanged),
            object: nil)
    }
    
}
