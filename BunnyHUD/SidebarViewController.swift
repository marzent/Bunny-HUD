/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The view controller that contains the lower UI controls and the embedded child view controller (split view controller).
*/

import Cocoa

class SidebarViewController: NSViewController {   
    
    // Remember the selected nodes from NSTreeController when the system calls "selectionDidChange".
    var selectedNodes: [NSTreeNode]?
    
    // MARK: View Controller Lifecycle
    
    
    override func viewWillAppear() {
        view.window?.styleMask.insert(.fullSizeContentView)
        super.viewWillAppear()
        let toolbar = NSToolbar(identifier: "toolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        self.view.window?.toolbar = toolbar
        self.view.window?.delegate = self
        typealias gsc = GeneralSettingsController
        if gsc.getSetting(settingKey: gsc.hiddenKey, defaultValue: false) {
            hideWindow()
        }
        NotificationCenter.default.addObserver(self,selector: #selector(selectionDidChange(_:)),name: .selectionChanged,object: nil)
        
        // A notification so you know when the icon view controller finishes populating its content.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: .selectionChanged, object: nil)
    }
    
    // MARK: NSNotifications
    
    // A notification that the IconViewController class sends to indicate when it receives the file system content.

    
    // Listens for selection changes to the NSTreeController so it can update the UI elements (add/remove buttons).
    @objc
    private func selectionDidChange(_ notification: Notification) {
        // Examine the current selection and adjust the UI elements.
        
        // The notification's object must be the tree controller.
        guard let treeController = notification.object as? NSTreeController else { return }
    
        // Remember the selected nodes for later when the system calls NSToolbarItemValidation and NSMenuItemValidation.
        selectedNodes = treeController.selectedNodes
    
    }
    
    // MARK: Actions
    

    @IBAction func addFolderAction(_: AnyObject) {
        // Post a notification to OutlineViewController to add a new folder group.
        NotificationCenter.default.post(name: .addFolder, object: nil)
    }
    
    @IBAction func addOverlayAction(_: AnyObject) {
        // Post a notification to OutlineViewController to add a new picture.
        NotificationCenter.default.post(name: .addOverlay, object: nil)
    }
    
    @IBAction func removeAction(_: AnyObject) {
        // Post a notification to OutlineViewController to remove an item.
        NotificationCenter.default.post(name: .removeItem, object: nil)
    }
    
    @IBAction func saveOverlays(_: AnyObject) {
        // Post a notification to OutlineViewController to add a new picture.
        NotificationCenter.default.post(name: .nodeChanged, object: nil)
    }
}

// MARK: - NSToolbarItemValidation

extension SidebarViewController: NSToolbarItemValidation {

    // Validate the toolbar items against the currently selected nodes.
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        var enable = false
        if let splitViewController = children[0] as? NSSplitViewController {
            let primary = splitViewController.splitViewItems[0]
            if primary.isCollapsed {
                // The primary side bar is in a collapsed state, don't allow the remove item to work.
                enable = false
            } else {
                // The primary side bar is in an expanded state, allow the remove item to work if there is a selection.
                if let selection = selectedNodes {
                    enable = !selection.isEmpty
                    for treeNode in selectedNodes! {
                        let node = treeNode.representedObject as! Node
                        if node.isSetting {
                            enable = false
                        }
                    }
                }
            }
        }
        return enable
    }
}

// MARK: - NSMenuItemValidation

extension SidebarViewController: NSMenuItemValidation {

    // Validate the two menu items in the Add toolbar item against the currently selected nodes.
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        var enable = false
        if let splitViewController = children[0] as? NSSplitViewController {
            let primary = splitViewController.splitViewItems[0]
            if primary.isCollapsed {
                // The primary side bar is in a collapsed state, don't allow the menu item to work.
                enable = false
            } else {
                enable = true
            }
        }
        return enable
    }
}

// MARK: - NSToolbarDelegate

private extension NSToolbarItem.Identifier {
    static let addItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "add")
    static let removeItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "remove")
}

extension SidebarViewController: NSToolbarDelegate {

    /** NSToolbar delegates require this function.
        It takes an identifier and returns the matching NSToolbarItem. It also takes a parameter telling
        whether this toolbar item is going into an actual toolbar, or whether it's going to appear
        in a customization palette.
     */
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        /// Create a new NSToolbarItem, and then go through the process of setting up its attributes.
        if itemIdentifier == NSToolbarItem.Identifier.addItem {
            // Configure the Add toolbar item.
            var image: NSImage!
            if #available(OSX 11.0, *) {
                let config = NSImage.SymbolConfiguration(scale: .large)
                image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add")!.withSymbolConfiguration(config)
            } else {
                image = NSImage(named: NSImage.addTemplateName)
            }
            let segmentControl = NSSegmentedControl(images: [image], trackingMode: .selectOne, target: nil, action: nil)
            
            let addMenu = NSMenu(title: "Add")
            addMenu.addItem(NSMenuItem(title: "Add Overlay", action: #selector(addOverlayAction), keyEquivalent: ""))
            addMenu.addItem(NSMenuItem(title: "Add Group", action: #selector(addFolderAction), keyEquivalent: ""))
            segmentControl.setMenu(addMenu, forSegment: 0)
            segmentControl.setShowsMenuIndicator(true, forSegment: 0)
            
            toolbarItem.view = segmentControl
            toolbarItem.label = "Add"
            toolbarItem.image = image
        } else if itemIdentifier == NSToolbarItem.Identifier.removeItem {
            // Configure the Remove toolbar item.
            if #available(OSX 11.0, *) {
                let config = NSImage.SymbolConfiguration(scale: .small)
                let image = NSImage(systemSymbolName: "minus", accessibilityDescription: "Remove")!.withSymbolConfiguration(config)
                toolbarItem.image = image
            } else {
                toolbarItem.image = NSImage(named: NSImage.removeTemplateName)
            }
            toolbarItem.action = #selector(removeAction)
            toolbarItem.label = "Remove"
        }
        
        return toolbarItem
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        /** Note that the system adds the .toggleSideBar toolbar item to the toolbar to the far left.
            This toolbar item hides and shows (toggle) the primary or side bar split-view item.
            
            For this toolbar item to work, you need to set the split-view item's NSSplitViewItem.Behavior to sideBar,
            which is already in the storyboard. Also note that the system automatically places .addItem and .removeItem to the far right.
        */
        var toolbarItemIdentifiers = [NSToolbarItem.Identifier]()
//        if #available(macOS 11.0, *) {
//            toolbarItemIdentifiers.append(.toggleSidebar)
//        }
        toolbarItemIdentifiers.append(.addItem)
        toolbarItemIdentifiers.append(.removeItem)
        return toolbarItemIdentifiers
    }
    
    /** NSToolbar delegates require this function. It returns an array holding identifiers for all allowed
        toolbar items in this toolbar. Any not listed here aren't available in the customization palette.
     */
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
}

extension SidebarViewController: NSWindowDelegate {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hideWindow()
        return false
    }
    
    func hideWindow() {
        view.window?.alphaValue = 0.0
        view.window?.ignoresMouseEvents = true
    }
    
    @IBAction func showWindow(_ sender: Any) {
        view.window?.alphaValue = 1.0
        view.window?.ignoresMouseEvents = false
        
    }
}
