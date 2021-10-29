/*
See LICENSE folder for licensing information.
*/


import Cocoa



extension NSTreeController {
    
    func indexPathOfObject(anObject: Node) -> IndexPath? {
        return indexPathOfObject(anObject: anObject, nodes: self.arrangedObjects.children)
    }
    
    func indexPathOfObject(anObject: Node, nodes: [NSTreeNode]!) -> IndexPath? {
        for node in nodes {
            if anObject == node.representedObject as? Node {
                return node.indexPath
            }
            if node.children != nil {
                if let path = indexPathOfObject(anObject: anObject, nodes: node.children) {
                    return path
                }
            }
        }
        return nil
    }
}

extension NSPasteboard.PasteboardType {
    
    // This UTI string needs be a unique identifier.
    static let nodeRowPasteBoardType =
        NSPasteboard.PasteboardType("com.bunnyhud.dezent.Sidebar.internalNodeDragType")
}

extension OutlineViewController: NSOutlineViewDataSource {

    // MARK: Drag and Drop
    
    /** This is the start of an internal drag, so decide what kind of pasteboard writer you want:
         either NodePasteboardWriter or a nonfile promiser writer.
          The system calls this for each dragged item in the selection.
    */
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        
        let rowIdx = outlineView.row(forItem: item)
        
        
            // The node isn't file-promised because it's a directory or a nonimage file.
            let pasteboardItem = NSPasteboardItem()
            
            // Remember the dragged node by its row number for later.
            let propertyList = ["rowKey" : rowIdx]
            pasteboardItem.setPropertyList(propertyList, forType: .nodeRowPasteBoardType)
            return pasteboardItem

    }

    // A utility function to detect if the user is dragging an item into its descendants.
    private func okToDrop(draggingInfo: NSDraggingInfo, locationItem: NSTreeNode?) -> Bool {
        var droppedOntoItself = false
        draggingInfo.enumerateDraggingItems(options: [],
                                            for: outlineView,
                                            classes: [NSPasteboardItem.self],
                                            searchOptions: [:]) { dragItem, _, _ in
              if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
                if let checkItem = self.itemFromPasteboardItem(droppedPasteboardItem) {
                    // Start at the root and recursively search.
                    let treeRoot = self.treeController.arrangedObjects
                    let node = treeRoot.descendant(at: checkItem.indexPath)
                    var parent = locationItem
                    while parent != nil {
                        if parent == node {
                            droppedOntoItself = true
                            break
                        }
                        parent = parent?.parent
                    }
                }
            }
        }
        draggingInfo.enumerateDraggingItems(options: [],
                                            for: outlineView,
                                            classes: [NSPasteboardItem.self],
                                            searchOptions: [:]) { dragItem, _, _ in
              if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
                if let checkItem = self.itemFromPasteboardItem(droppedPasteboardItem) {
                    // Start at the root and recursively search.
                    let treeRoot = self.treeController.arrangedObjects
                    var parent = locationItem
                    while parent != nil {
                        if parent == self.treeController.arrangedObjects.children![1] {
                            droppedOntoItself = true
                            break
                        }
                        parent = parent?.parent
                    }
                    let node = treeRoot.descendant(at: checkItem.indexPath)?.representedObject as! Node
                    if node.isSetting {
                        droppedOntoItself = true
                    }
                }
            }
        }
        return !droppedOntoItself
    }
    
    /** The system calls this during a drag over the outline view before the drop occurs.
        The outline view uses it to determine a visual drop target.
        Use this function to specify how to respond to a proposed drop operation.
    */
    func outlineView(_ outlineView: NSOutlineView,
                     validateDrop info: NSDraggingInfo,
                     proposedItem item: Any?, // The place the drop is hovering over.
                     proposedChildIndex index: Int) -> NSDragOperation { // The child index the drop is hovering over.
        var result = NSDragOperation()
        
        guard index != -1,     // Don't allow dropping on a child.
                item != nil    // Make sure you have a valid outline view item to drop on.
        else { return result }
        
        // Find the node you're dropping onto.
        if let dropNode = OutlineViewController.node(from: item as Any) {
            // Don't allow dropping into file system objects.
            if !dropNode.isURLNode {
                // The current drop location is inside the container.
                if info.draggingPasteboard.availableType(from: [.nodeRowPasteBoardType]) != nil {
                    // The drag source is from within the outline view.
                    if dropNode.isDirectory {
                        // Check if you're dropping onto yourself.
                        if okToDrop(draggingInfo: info, locationItem: item as? NSTreeNode) {
                            result = .move
                        }
                    } else {
                        result = .move
                    }
                } else if info.draggingPasteboard.availableType(from: [.fileURL]) != nil {
                    // The drag source is from outside this app as a file URL, so a drop means adding a link/reference.
                    result = .link
                } else {
                    // The drag source is from outside this app and is likely a file promise, so it's going to be a copy.
                    result = .copy
                }
            }
        }

        return result
    }
    
    
    
   
    
    // The user is doing a drop or intra-app drop within the outline view.
    private func handleInternalDrops(_ outlineView: NSOutlineView, draggingInfo: NSDraggingInfo, indexPath: IndexPath) {
        // Accumulate all drag items and move them to the proper indexPath.
        var itemsToMove = [NSTreeNode]()
        
        draggingInfo.enumerateDraggingItems(options: [],
                                            for: outlineView,
                                            classes: [NSPasteboardItem.self],
                                            searchOptions: [:]) { dragItem, _, _ in
            if let droppedPasteboardItem = dragItem.item as? NSPasteboardItem {
                if let itemToMove = self.itemFromPasteboardItem(droppedPasteboardItem) {
                    itemsToMove.append(itemToMove)
                }
            }
        }
        self.treeController.move(itemsToMove, to: indexPath)
        NotificationCenter.default.post(name: Notification.Name(OverlaySettingsController.NotificationNames.nodeChanged), object: nil)
    }
    
    /** Accept the drop.
         The system calls the following function when the user finishes dragging one or more objects.
         This occurs when the mouse releases over an outline view that allows a drop via the validateDrop method.
        Handle the data from the dragging pasteboard that's dropping onto the outline view.
     
        The param 'index' is the location to insert the data as a child of 'item', and are the values previously set in the validateDrop: method.
         Note that "targetItem" is an NSTreeNode proxy node.
     */
    func outlineView(_ outlineView: NSOutlineView,
                     acceptDrop info: NSDraggingInfo,
                     item targetItem: Any?,
                     childIndex index: Int) -> Bool {
        // Find the index path to insert the dropped objects.
        if let dropIndexPath = droppedIndexPath(item: targetItem, childIndex: index) {
            // Check the dragging type.
            if info.draggingPasteboard.availableType(from: [.nodeRowPasteBoardType]) != nil {
                // The user dropped one of your own items.
                handleInternalDrops(outlineView, draggingInfo: info, indexPath: dropIndexPath)
            } else {
                // The user dropped items from the Finder, Photos, Mail, Safari, and so forth.
            }
        }
        return true
    }
    
    /** The system calls this when the dragging session ends. Use this to know when the dragging source
        operation ends at a specific location, such as the Trash (by checking for an operation of NSDragOperationDelete).
     */
    func outlineView(_ outlineView: NSOutlineView,
                     draggingSession session: NSDraggingSession,
                     endedAt screenPoint: NSPoint,
                     operation: NSDragOperation) {
        if operation == .delete,
            let items = session.draggingPasteboard.pasteboardItems {
            var itemsToRemove = [Node]()
            
            // Find the items the user is dragging to the Trash (as a dictionary containing their row numbers).
            for draggedItem in items {
                if let item = itemFromPasteboardItem(draggedItem) {
                    if let itemToRemove = OutlineViewController.node(from: item) {
                        itemsToRemove.append(itemToRemove)
                    }
                }
            }
            removeItems(itemsToRemove)
        }
    }
    
    // MARK: Utilities

    func handleError(_ error: Error) {
        OperationQueue.main.addOperation {
            if let window = self.view.window {
                self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
            } else {
                self.presentError(error)
            }
        }
    }
    
    // A utility functon to return convert an NSPasteboardItem to an NSTreeNode.
    private func itemFromPasteboardItem(_ item: NSPasteboardItem) -> NSTreeNode? {
        // Obtain the property list and find the row number of the dragged node.
        guard let itemPlist = item.propertyList(forType: .nodeRowPasteBoardType) as? [String: Any],
            let rowIndex = itemPlist["rowKey" ] as? Int else { return nil }

        // Ask the outline view for the tree node.
        return outlineView.item(atRow: rowIndex) as? NSTreeNode
    }
    
    // Find the index path to insert the dropped objects.
    private func droppedIndexPath(item targetItem: Any?, childIndex index: Int) -> IndexPath? {
        let dropIndexPath: IndexPath?
        
        if targetItem != nil {
            // Drop-down inside the tree node: fetch the index path to insert the dropped node.
            dropIndexPath = (targetItem! as AnyObject).indexPath!.appending(index)
        } else {
            // Drop at the top root level.
            if index == -1 { // The drop area might be ambiguous (not at a particular location).
                dropIndexPath = IndexPath(index: contents.count) // Drop at the end of the top level.
            } else {
                dropIndexPath = IndexPath(index: index) // Drop at a particular place at the top level.
            }
        }
        return dropIndexPath
    }
    
}
