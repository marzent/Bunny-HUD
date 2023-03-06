/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A custom table row view to draw a separator.
 */

import Cocoa

class SeparatorView: NSTableRowView {
    override func draw(_ dirtyRect: NSRect) {
        // Draw the separator line.
        let lineWidth = dirtyRect.size.width
        let lineY = dirtyRect.size.height / 2 + 0.5

        // Draw the line.
        NSColor(named: "SeparatorLineColor")?.setFill()
        NSRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y + lineY, width: lineWidth, height: 1).fill()

        // Draw the line's shadow.
        NSColor(named: "SeparatorLineColorShadow")?.setFill()
        NSRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y + lineY + 1, width: lineWidth, height: 1).fill()
    }
}
