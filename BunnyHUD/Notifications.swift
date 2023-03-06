/*
 See LICENSE folder for licensing information.
 */

import Foundation

extension Notification.Name {
    static let addFolder = Notification.Name("AddFolderNotification")
    static let addOverlay = Notification.Name("AddOverlayNotification")
    static let addOverlayDone = Notification.Name("AddOverlayDoneNotification")
    static let removeItem = Notification.Name("RemoveItemNotification")
    static let selectionChanged = Notification.Name("SelectionChangedNotification")
    static let nodeChanged = Notification.Name("NodeChangedNotification")
    static let layoutChanged = Notification.Name("LayoutChangedNotification")
}

extension Notification {
    enum overlayKey: String {
        case name
        case url
    }
}
