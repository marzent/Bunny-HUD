/*
See LICENSE folder for licensing information.
*/


import Cocoa

enum NodeType: Int, Codable {
    case container
    case overlay
    case setting
    case separator
    case unknown
}

/// - Tag: NodeClass
class Node: NSObject, Codable {
    var type: NodeType = .unknown
    var title: String = ""
    var identifier: String = ""
    var url: OverlayURL?
    var pos: NSRect?
    var clickable: Bool?
    var resizeable: Bool?
    var draggable: Bool?
    var hidden: Bool?
    var background: Bool?
    var fullscreen: Bool?
    var zoom: CGFloat?
    @objc dynamic var children = [Node]()
    
    override init() {
        
    }
    
    convenience init (title: String, identifier: String, url: OverlayURL, pos: NSRect, clickable: Bool, resizeable: Bool, draggable: Bool, hidden: Bool, background: Bool, fullscreen:Bool, zoom: CGFloat) {
        self.init()
        self.type = .overlay
        self.title = title
        self.identifier = identifier
        self.url = url
        self.pos = pos
        self.children = []
        self.clickable = clickable
        self.resizeable = resizeable
        self.draggable = draggable
        self.hidden = hidden
        self.background = background
        self.fullscreen = fullscreen
        self.zoom = zoom
    }
    
    convenience init (title: String, url: OverlayURL, pos: NSRect) {
        self.init()
        self.type = .overlay
        self.title = title
        self.identifier = UUID().uuidString
        self.url = url
        self.pos = pos
        self.children = []
        self.clickable = true
        self.resizeable = true
        self.draggable = true
        self.hidden = false
        self.background = true
        self.fullscreen = false
        self.zoom = 0.0
    }
    
    convenience init (title: String) {
        self.init()
        self.type = .setting
        self.title = title
        self.identifier = "setting"+title
        self.children = []
    }
}

extension Node {
    
    /** The tree controller calls this to determine if this node is a leaf node,
        use it to determine if the node needs a disclosure triangle.
     */
    @objc dynamic var isLeaf: Bool {
        return type == .separator || type == .overlay || type == .setting
    }
    
    var isURLNode: Bool {
        return url != nil
    }
    
    var isSpecialGroup: Bool {
        return (!isURLNode &&
            (title == OutlineViewController.NameConstants.settings || title == OutlineViewController.NameConstants.overlays))
    }
    
    override class func description() -> String {
        return "Node"
    }
    
    var nodeIcon: NSImage {
        if isDirectory {
            return NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
        }
        else if isSetting {
            return NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!
        }
        else {
            return NSImage(systemSymbolName: "gamecontroller", accessibilityDescription: nil)!
        }
    }
    
    var canChange: Bool {
        return isDirectory || isOverlay
    }
    
    var canAddTo: Bool {
        return canChange
    }
    
    var isSeparator: Bool {
        return type == .separator
    }
    
    var isDirectory: Bool {
        return type == .container
    }
    
    var isSetting: Bool {
        return type == .setting
    }
    
    var isOverlay: Bool {
        return type == .overlay
    }
}
