/*
See LICENSE folder for licensing information.

Abstract:
The primary view controller that contains the NSOutlineView and NSTreeController.
*/

import Cocoa

class OutlineViewController: NSViewController,
                                NSTextFieldDelegate, // To respond to the text field's edit sending.
                                NSUserInterfaceValidations
{ // To enable/disable menu items for the outline view.
    // MARK: Constants
    
    struct NameConstants {
        // The default name for added folders and leafs.
        static let untitled = NSLocalizedString("untitled string", comment: "")
        // The places group title.
        static let settings = NSLocalizedString("settings string", comment: "")
        // The pictures group title.
        static let overlays = NSLocalizedString("overlays string", comment: "")
    }
    
    var overlayControllers: [String: WebViewController] = [:]

    var overlayRootNode : Node {
        return treeController.arrangedObjects.children![0].representedObject as! Node
    }
    
    @IBAction func reloadOverlays(_: AnyObject) {
        removeWindow(item: overlayRootNode)
        newOverlayWindow(node: overlayRootNode)
    }
    
    private func newOverlayWindow(node: Node) {
        if node.isDirectory {
            for child in node.children {
                newOverlayWindow(node: child)
            }
        }
        else if node.isOverlay {
            let overlayWinController = self.storyboard!.instantiateController(withIdentifier: "OverlayWindow") as! NSWindowController
            overlayWinController.showWindow(self)
            let overlayController = overlayWinController.contentViewController! as! WebViewController
            overlayController.node = node
            overlayControllers[node.identifier] = overlayController
        }
    }
    
    func removeWindow(item: Node) {
        if item.isDirectory {
            for child in item.children {
                removeWindow(item: child)
            }
        } else if item.isOverlay {
            self.overlayControllers[item.identifier]?.view.window?.close()
        }
    }
    
    // MARK: Outlets
    
    // The data source backing of the NSOutlineView.
    @IBOutlet weak var treeController: NSTreeController!

    @IBOutlet weak var outlineView: NSOutlineView! {
        didSet {
            // As soon the outline view loads, populate its content tree controller.
            populateOutlineContents()
            newOverlayWindow(node: overlayRootNode)
        }
    }
    
    
    
    @IBOutlet private weak var placeHolderView: NSView!
    
    // MARK: Instance Variables
    
    // The observer of the tree controller when its selection changes using KVO.
    private var treeControllerObserver: NSKeyValueObservation?
    
    // The outline view of top-level content. NSTreeController backs this.
    @objc dynamic var contents: [AnyObject] = []
    
      var rowToAdd = -1 // The addition of a flagged row (for later renaming).
    
    // The directory for accepting promised files.
    lazy var promiseDestinationURL: URL = {
        let promiseDestinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
        try? FileManager.default.createDirectory(at: promiseDestinationURL, withIntermediateDirectories: true, attributes: nil)
        return promiseDestinationURL
    }()
    
    private var overlayViewController: OverlaySettingsController!
    private var settingsViewController: NSViewController!
    private var cactbotViewController: NSViewController!
        
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Dragging items out: Set the default operation mask so you can drag (copy) items to outside this app, and delete them in the Trash can.
        outlineView?.setDraggingSourceOperationMask([.copy, .delete], forLocal: false)
        
        // Register for drag types coming in to receive file promises from Photos, Mail, Safari, and so forth.
        outlineView.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
        
        // You want these drag types: your own type (outline row number), and fileURLs.
        outlineView.registerForDraggedTypes([
              .nodeRowPasteBoardType, // Your internal drag type, the outline view's row number for internal drags.
            NSPasteboard.PasteboardType.fileURL // To receive file URL drags.
            ])
        
        // Expand all nodes
        outlineView.expandItem(treeController.arrangedObjects.children![0], expandChildren: true)
        outlineView.expandItem(treeController.arrangedObjects.children![1], expandChildren: true)


        // Load the multiple items selected view controller from the storyboard for later use as your Detail view.
        overlayViewController =
            storyboard!.instantiateController(withIdentifier: "OverlaySettings") as? OverlaySettingsController
        overlayViewController.view.translatesAutoresizingMaskIntoConstraints = false
        settingsViewController =
            storyboard!.instantiateController(withIdentifier: "GeneralSettings") as? NSViewController
        settingsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        cactbotViewController =
            storyboard!.instantiateController(withIdentifier: "CactbotSettings") as? NSViewController
        cactbotViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        
       //  Set up observers for the outline view's selection, adding items, and removing items.
        setupObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,name: .addFolder,object: nil)
        NotificationCenter.default.removeObserver(self,name: .addOverlay,object: nil)
        NotificationCenter.default.removeObserver(self,name: .removeItem,object: nil)
    }
    
    // MARK: OutlineView Setup

    // Take the currently selected node and select its parent.
    private func selectParentFromSelection() {
        if !treeController.selectedNodes.isEmpty {
            let firstSelectedNode = treeController.selectedNodes[0]
            if let parentNode = firstSelectedNode.parent {
                // Select the parent.
                let parentIndex = parentNode.indexPath
                treeController.setSelectionIndexPath(parentIndex)
            } else {
                // No parent exists (you are at the top of tree), so make no selection in your outline.
                let selectionIndexPaths = treeController.selectionIndexPaths
                treeController.removeSelectionIndexPaths(selectionIndexPaths)
            }
        }
    }



    private func addGroupNode(_ folderName: String, identifier: String) {
        let node = Node()
        node.type = .container
        node.title = folderName
        node.identifier = identifier
    
        // Insert the group node.
        
        // Get the insertion indexPath from the current selection.
        var insertionIndexPath: IndexPath
        // If there is no selection, add a new group to the end of the content's array.
        if treeController.selectedObjects.isEmpty {
            // There's no selection, so add the folder to the top-level and at the end.
            insertionIndexPath = IndexPath(index: contents.count)
        } else {
            /** Get the index of the currently selected node, then add the number of its children to the path.
                This gives you an index that allows you to add a node to the end of the currently
                selected node's children array.
             */
            insertionIndexPath = treeController.selectionIndexPath!
            if let selectedNode = treeController.selectedObjects[0] as? Node {
                // The user is trying to add a folder on a selected folder, so add the selection to the children.
                insertionIndexPath.append(selectedNode.children.count)
            }
        }
        
        treeController.insert(node, atArrangedObjectIndexPath: insertionIndexPath)
    }

    private func addNode(_ node: Node) {
        // Find the selection to insert the node.
        var indexPath: IndexPath
        if treeController.selectedObjects.isEmpty {
            // No selection, so just add the child to the end of the tree.
            indexPath = IndexPath(index: contents.count)
        } else {
            // There's a selection, so insert the child at the end of the selection.
            indexPath = treeController.selectionIndexPath!
            if let node = treeController.selectedObjects[0] as? Node {
                indexPath.append(node.children.count)
            }
        }

        // The user is adding a child node, so tell the controller directly.
        treeController.insert(node, atArrangedObjectIndexPath: indexPath)

        if !node.isDirectory {
            // For leaf children, select its parent for further additions.
            selectParentFromSelection()
        }
    }

    // MARK: Outline Content

    
    private func addSettingsGroup() {
        // Add the Places outline group section.
        // Note that the system shares the nodeID and the expansion restoration ID.
        
        addGroupNode(OutlineViewController.NameConstants.settings, identifier: "settingsGroup")
        addNode(Node(title: "General"))
        typealias gsc = GeneralSettingsController
        if gsc.getSetting(settingKey: gsc.cactbotKey, defaultValue: false) {
            addNode(Node(title: "Cactbot"))
        }
        
        treeController.setSelectionIndexPath(nil) // Start back at the root level.
    }


    private func addOverlaysGroup() {
        addGroupNode(OutlineViewController.NameConstants.overlays, identifier: "overlayGroup")
        // Populate the outline view with the .plist file content.
//        var url: OverlayURL
//        var node : Node
//        url = OverlayURL(modern: false, path: "mopimopi/index.html")
//        node = Node(title: "Mopi Mopi", identifier: UUID().uuidString, url: url, pos: NSRect(x: -600, y: 750, width: 600, height: 400),
//                    clickable: true, resizeable: true, draggable: false, hidden: false, background: true, fullscreen: false, zoom: 1.0)
//        addNode(node)
//        url = OverlayURL(modern: true, path: "cactbot/ui/raidboss/raidboss.html", options: "&alerts=1&timeline=0")
//        node = Node(title: "Cactbot Alerts", identifier: UUID().uuidString, url: url, pos: NSRect(x: 880, y: 1440-430, width: 800, height: 250),
//                    clickable: false, resizeable: false, draggable: false, hidden: false, background: true, fullscreen: false, zoom: 1.0)
//        addNode(node)
//        url = OverlayURL(modern: true, path: "cactbot/ui/raidboss/raidboss.html", options: "&alerts=0&timeline=1")
//        node = Node(title: "Cactbot Timeline", identifier: UUID().uuidString, url: url, pos: NSRect(x: -370, y: 50, width: 370, height: 300),
//                    clickable: false, resizeable: false, draggable: false, hidden: false, background: true,fullscreen: false, zoom: 1.7)
//        addNode(node)
//        url = OverlayURL(modern: true, path: "cactbot/ui/oopsyraidsy/oopsyraidsy.html")
//        node = Node(title: "Cactbot Oopsy", identifier: UUID().uuidString, url: url, pos: NSRect(x: -370, y: 400, width: 370, height: 300),
//                    clickable: false, resizeable: false, draggable: false, hidden: false, background: true, fullscreen: false,zoom: 1.0)
//        addNode(node)

        
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        let folderURL = supportURL.appendingPathComponent("Bunny HUD")
        let newPlistURL = folderURL.appendingPathComponent("Overlays.plist")
        do {
            // Populate the outline view with the .plist file content.
            // Decode the top-level children of the outline.
            let plistDecoder = PropertyListDecoder()
            let data = try Data(contentsOf: newPlistURL)
            let decodedData = try plistDecoder.decode(Node.self, from: data)
            for node in decodedData.children {
                // Recursively add further content from the specified node.
                addNode(node)
                if node.type == .container {
                    selectParentFromSelection()
                }
            }
        } catch {
            saveOverlays(NSNull())
        }
        
        treeController.setSelectionIndexPath(nil) // Start back at the root level.
        
    }
    
    private func populateOutlineContents() {
        addSettingsGroup()
        addOverlaysGroup()
    }

    // MARK: Removal and Addition

    private func removalConfirmAlert(_ itemsToRemove: [Node]) -> NSAlert {
        let alert = NSAlert()

        var messageStr: String
        if itemsToRemove.count > 1 {
            // Remove multiple items.
            alert.messageText = NSLocalizedString("remove multiple string", comment: "")
        } else {
            // Remove the single item.
            if itemsToRemove[0].isURLNode {
                messageStr = NSLocalizedString("remove link confirm string", comment: "")
            } else {
                messageStr = NSLocalizedString("remove confirm string", comment: "")
            }
            alert.messageText = String(format: messageStr, itemsToRemove[0].title)
        }

        alert.addButton(withTitle: NSLocalizedString("ok button title", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("cancel button title", comment: ""))

        return alert
    }

    
    // The system calls this from handleContextualMenu() or the remove button.
    func removeItems(_ itemsToRemove: [Node]) {
        // Confirm the removal operation.
        let confirmAlert = removalConfirmAlert(itemsToRemove)
        confirmAlert.beginSheetModal(for: view.window!) { returnCode in
            if returnCode == NSApplication.ModalResponse.alertFirstButtonReturn {
                // Remove the specified set of node objects from the tree controller.
                var indexPathsToRemove = [IndexPath]()
                for item in itemsToRemove {
                    self.removeWindow(item: item)
                    if let indexPath = self.treeController.indexPathOfObject(anObject: item) {
                        indexPathsToRemove.append(indexPath)
                    }
                }
                self.treeController.removeObjects(atArrangedObjectIndexPaths: indexPathsToRemove)

                // Remove the current selection after the removal.
                self.treeController.setSelectionIndexPaths([])
                self.saveOverlays(NSNull())
            }
        }
    }


    // Return a Node class from the specified outline view item through its representedObject.
    class func node(from item: Any) -> Node? {
        if let treeNode = item as? NSTreeNode, let node = treeNode.representedObject as? Node {
            return node
        } else {
            return nil
        }
    }

    // Remove the currently selected items.
    private func removeItems() {
        var nodesToRemove = [Node]()

        for item in treeController.selectedNodes {
            if let node = OutlineViewController.node(from: item) {
                nodesToRemove.append(node)
            }
        }
        removeItems(nodesToRemove)
    }

/// - Tag: Delete
    // The user chose the Delete menu item or pressed the Delete key.
    @IBAction func delete(_ sender: AnyObject) {
        removeItems()
    }

    // The system calls this from handleContextualMenu() or the add group button.
   func addNodeToOverlays(_ item: Node) {
       guard let rowItemNode = OutlineViewController.node(from: treeController.arrangedObjects.children![0]),
           let itemNodeIndexPath = treeController.indexPathOfObject(anObject: rowItemNode) else { return }
   
       // You're inserting a new group folder at the node index path, so add it to the end.
       let indexPathToInsert = itemNodeIndexPath.appending(rowItemNode.children.count)
   
       if item.isOverlay {
           //rowToAdd += 1
           newOverlayWindow(node: item)
       }
       treeController.insert(item, atArrangedObjectIndexPath: indexPathToInsert)
       rowToAdd = outlineView.row(forItem: item) + rowItemNode.children.count
       if item.isOverlay {
           rowToAdd += 1 //dunno why but it has to be this way....
       }
       self.saveOverlays(NSNull())
    }


    // MARK: Notifications

    private func setupObservers() {
        // A notification to add a folder.
        NotificationCenter.default.addObserver(self,selector: #selector(addFolder(_:)),name: .addFolder, object: nil)

        // A notification to add a picture.
        NotificationCenter.default.addObserver(self,selector: #selector(addOverlay(_:)),name: .addOverlay,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(addOverlayDone(_:)),name: .addOverlayDone,object: nil)

        // A notification to remove an item.
        NotificationCenter.default.addObserver(self,selector: #selector(removeItem(_:)),name: .removeItem,object: nil)

        NotificationCenter.default.addObserver(self,selector: #selector(saveOverlays(_:)),name: .nodeChanged,object: nil)
        // Listen to the treeController's selection change so you inform clients to react to selection changes.
        treeControllerObserver =
            treeController.observe(\.selectedObjects, options: [.new]) {(treeController, change) in
                            // Post this notification so other view controllers can react to the selection change.
                            // Interested view controllers are: WindowViewController and SplitViewController.
                            NotificationCenter.default.post(name: .selectionChanged, object: treeController)

                            // Save the outline selection state for later when the app relaunches.
                            self.invalidateRestorableState()
                        }
    }

    @objc
    private func saveOverlays(_ notif: Any) {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        let folderURL = supportURL.appendingPathComponent("Bunny HUD")
        let fileURL = folderURL.appendingPathComponent("Overlays.plist")
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        do {
            let data = try encoder.encode(treeController.arrangedObjects.children![0].representedObject as! Node)
          try data.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }

    
    // A notification that the WindowViewController class sends to add a generic folder to the current selection.
    @objc
    private func addFolder(_ notif: Notification) {
        // Add the folder with the "untitled" title.
        let nodeToAdd = Node()
        nodeToAdd.title = OutlineViewController.NameConstants.untitled
        nodeToAdd.identifier = NSUUID().uuidString
        nodeToAdd.type = .container
        addNodeToOverlays(nodeToAdd)
        rowToAdd = outlineView.selectedRow
    }

    // A notification that the WindowViewController class sends to add a picture to the selected folder node.


    // A notification that the WindowViewController remove button sends to remove a selected item from the outline view.
    @objc
    private func removeItem(_ notif: Notification) {
        removeItems()
    }

    // MARK: NSTextFieldDelegate

    // For a text field in each outline view item, the user commits the edit operation.
    func controlTextDidEndEditing(_ obj: Notification) {
        // Commit the edit by applying the text field's text to the current node.
        guard let item = outlineView.item(atRow: outlineView.selectedRow),
            let node = OutlineViewController.node(from: item) else { return }

        if let textField = obj.object as? NSTextField {
            node.title = textField.stringValue
        }
    }

    // MARK: NSValidatedUserInterfaceItem

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(delete(_:)) {
            return !treeController.selectedObjects.isEmpty
        }
        return true
    }

    // MARK: Detail View Management

    // Use this to decide which view controller to use as the detail.
    func viewControllerForSelection(_ selection: [NSTreeNode]?) -> NSViewController? {
        guard let outlineViewSelection = selection else { return nil }

        var viewController: NSViewController?

        switch outlineViewSelection.count {
        case 0:
            // No selection.
            viewController = nil
        case 1:
            // A single selection.
            if let node = OutlineViewController.node(from: selection?[0] as Any) {
                if node.isDirectory {
                    viewController = nil
                } else if node.isSetting {
                    if node.identifier == "settingCactbot" {
                        viewController = cactbotViewController
                    } else {
                        viewController = settingsViewController
                    }
                } else if node.isOverlay {
                    overlayViewController.node = node
                    overlayViewController.overlayController = overlayControllers[node.identifier]
                    viewController = overlayViewController
                }
            }
        default:
            // The selection is multiple or more than one.
            viewController = nil
        }

        return viewController
    }

    // MARK: File Promise Drag Handling

    /// The queue for reading and writing file promises.
    lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()
    
}

extension OutlineViewController {
    
    // A restorable key for the currently selected outline node on state restoration.
    private static let savedSelectionKey = "savedSelectionKey"

    /// The key paths for window restoration (including the view controller).
    override class var restorableStateKeyPaths: [String] {
        var keys = super.restorableStateKeyPaths
        keys.append(savedSelectionKey)
        return keys
    }

    /// An encode state that helps save the restorable state of this view controller.
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(treeController.selectionIndexPaths, forKey: OutlineViewController.savedSelectionKey)
        super.encodeRestorableState(with: coder)
    }

    /** A decode state that helps restore any previously stored state.
        Note that when "Close windows when quitting an app" is in a selected state in the System Preferences General pane,
        selection restoration works if you choose Option-Command-Quit.
    */
    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
        
        // Restore the selected indexPaths.
        if let savedSelectedIndexPaths =
            coder.decodeObject(forKey: OutlineViewController.savedSelectionKey) as? [IndexPath] {
            treeController.setSelectionIndexPaths(savedSelectedIndexPaths)
        }
    }
    
}
