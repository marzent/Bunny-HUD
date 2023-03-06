/*
 See LICENSE folder for licensing information.
 */

import Cocoa

extension OutlineViewController {
    @objc func addOverlay(_ notif: Notification) {
        let overlayWinController = self.storyboard!.instantiateController(withIdentifier: "OverlaySheet") as! NSWindowController
        view.window?.beginSheet(overlayWinController.window!)
    }

    @objc func addOverlayDone(_ notif: Notification) {
        let name = notif.userInfo?[Notification.overlayKey.name]! as! String
        let url = notif.userInfo?[Notification.overlayKey.url]! as! OverlayURL
        let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 500))
        addNodeToOverlays(node)
    }
}
