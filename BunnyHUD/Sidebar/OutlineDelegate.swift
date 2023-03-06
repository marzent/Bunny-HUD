/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 NSOutlineViewDelegate support for OutlineViewController.
 */

import Cocoa

extension OutlineViewController: NSOutlineViewDelegate {
    // Is the outline view item a group node? Not a folder but a group, with Hide/Show buttons.
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let node = OutlineViewController.node(from: item)
        return node!.isSpecialGroup
    }
    
    // Should you select the outline view item? No selection for special groupings or separators.
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let node = OutlineViewController.node(from: item) {
            return !node.isSpecialGroup && !node.isSeparator
        } else {
            return false
        }
    }
    
    // What should be the row height of an outline view item?
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        var rowHeight = outlineView.rowHeight
        
        guard let node = OutlineViewController.node(from: item) else { return rowHeight }

        if node.isSeparator {
            // Separator rows have a smaller height.
            rowHeight = 8.0
        }
        return rowHeight
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        guard let node = OutlineViewController.node(from: item) else { return view }
        
        if node.isSeparator {
            // The row is a separator node, so make a custom view for it,.
            if let separator =
                outlineView.makeView(
                    withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Separator"), owner: self) as? SeparatorView
            {
                return separator
            }
        } else if self.outlineView(outlineView, isGroupItem: item) {
            // The row is a group node, so return NSTableCellView as a special group row.
            view = outlineView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GroupCell"), owner: self) as? NSTableCellView
            view?.textField?.stringValue = node.title.uppercased()
        } else {
            // The row is a regular outline node, so return NSTableCellView with an image and title.
            view = outlineView.makeView(
                withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MainCell"), owner: self) as? NSTableCellView
            
            view?.textField?.stringValue = node.title
            view?.imageView?.image = node.nodeIcon

            // Folder titles are editable only if they don't have a file URL,
            // You don't want users to rename file system-based nodes.
            view?.textField?.isEditable = node.canChange
        }

        return view
    }
    
    // The user inserted an outline view row.
    func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
        // Are you adding a newly inserted row that needs a new name?
        if rowToAdd != -1 {
            // Force-edit the newly added row's name.
            if let view = outlineView.view(atColumn: 0, row: rowToAdd, makeIfNecessary: false) {
                if let cellView = view as? NSTableCellView {
                    view.window?.makeFirstResponder(cellView.textField)
                }
                rowToAdd = -1
            }
        }
    }
}
