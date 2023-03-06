/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 The view controller that manages the split-view interface.
 */

import Cocoa

class DetailViewContainer: NSView {
    /** You embed a child view controller into the detail view controller each time a different outline view item becomes selected.
         For the split view controller to consistently remain in the responder chain, the detail view controller's view property needs to
         accept first responder status. This is especially important for the consistent validation of the Show/Hide Sidebar
         menu item in the View menu.
     */
    override var acceptsFirstResponder: Bool { return true }
}

class SplitViewController: NSSplitViewController {
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    private var treeControllerObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Note: Keep the left split-view item from growing as the window grows by setting its hugging priority to 200,
            and the right split view item to 199. The view with the lowest priority is the first to take on additional
            width if the split-view grows or shrinks.
         */
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectionChange(_:)), name: .selectionChanged, object: nil)
        // This preserves the split-view divider position.
        splitView.autosaveName = "SplitViewAutoSave"
        // embedChildViewController(OverlaySettings)
    }
    
    // MARK: Detail View Controller Management
    
    private var detailViewController: NSViewController {
        let rightSplitViewItem = splitViewItems[1]
        return rightSplitViewItem.viewController
    }
    
    private var hasChildViewController: Bool {
        return !detailViewController.children.isEmpty
    }
    
    public func embedChildViewController(_ childViewController: NSViewController) {
        // This embeds a new child view controller.
        let currentDetailVC = detailViewController
        currentDetailVC.addChild(childViewController)
        currentDetailVC.view.addSubview(childViewController.view)
        
        // Build the horizontal, vertical constraints so that an added child view controller matches the width and height of its parent.
        let views = ["targetView": childViewController.view]
        horizontalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        verticalConstraints =
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[targetView]|",
                                           options: [],
                                           metrics: nil,
                                           views: views)
        NSLayoutConstraint.activate(verticalConstraints)
    }
    
    // MARK: Notifications
    
    // Listens for selection changes to the NSTreeController.
    @objc
    private func handleSelectionChange(_ notification: Notification) {
        // Examine the current selection and adjust the UI.

        // Make sure the notification's object is a tree controller.
        guard let treeController = notification.object as? NSTreeController else { return }

        let leftSplitViewItem = splitViewItems[0]
        if let outlineViewControllerToObserve = leftSplitViewItem.viewController as? OutlineViewController {
            let currentDetailVC = detailViewController

            // Let the outline view controller handle the selection (helps you decide which detail view to use).
            if let vcForDetail = outlineViewControllerToObserve.viewControllerForSelection(treeController.selectedNodes) {
                if hasChildViewController && currentDetailVC.children[0] != vcForDetail {
                    /** The incoming child view controller is different from the one you currently have,
                         so remove the old one and add the new one.
                     */
                    currentDetailVC.removeChild(at: 0)
                    // Remove the old child detail view.
                    detailViewController.view.subviews[0].removeFromSuperview()
                    // Add the new child detail view.
                    embedChildViewController(vcForDetail)
                } else {
                    if !hasChildViewController {
                        // You don't have a child view controller, so embed the new one.
                        embedChildViewController(vcForDetail)
                    }
                }
            } else {
                // No selection. You don't have a child view controller to embed, so remove the current child view controller.
                if hasChildViewController {
                    currentDetailVC.removeChild(at: 0)
                    detailViewController.view.subviews[0].removeFromSuperview()
                }
            }
        }
    }
}
