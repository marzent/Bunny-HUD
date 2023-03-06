//
//  OverlaySheetController.swift
//  BunnyHUD
//
//  Created by Marc-Aurel Zent on 26.10.21.
//
import Cocoa

fileprivate struct OverlaysValue: Codable {
    let name: String
    let url: String
    let httpProxy: String
    let options: String?
    let modern, cactbot: Bool
    let system: Bool?

    enum CodingKeys: String, CodingKey {
        case name, url
        case httpProxy = "http_proxy"
        case options, modern, cactbot, system
    }
}

fileprivate typealias Overlays = [String: OverlaysValue]

class OverlaySheetController: NSViewController {
    @IBOutlet private var okButton: NSButton!
    @IBOutlet private var selector: NSPopUpButton!
    @IBOutlet private var nameField: NSTextField!
    
    private static let jsonURL = Bundle.main.url(forResource: "overlays", withExtension: "json")!
    private static let jsonData = try! Data(contentsOf: jsonURL)
    private static let overlays = try! JSONDecoder().decode(Overlays.self, from: jsonData)
    
    @IBAction func okAction(_ sender: Any) {
        guard let overlayName = selector.titleOfSelectedItem else {
            return
        }
        let overlays = OverlaySheetController.overlays.values
        guard let selectedOverlay = overlays.first(where: {$0.name == overlayName}) else {
            return
        }
        let overlayURL = OverlayURL(modern: selectedOverlay.modern,
                                    path: selectedOverlay.httpProxy,
                                    options: selectedOverlay.options)
        NotificationCenter.default.post(name: .addOverlayDone, object: nil,
                                        userInfo: [Notification.overlayKey.name: overlayName,
                                                   Notification.overlayKey.url: overlayURL])
        view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        view.window?.close()
    }
    
    override func viewWillAppear() {
        okButton.isHighlighted = true
        let overlays = OverlaySheetController.overlays.values.filter {!($0.system ?? false)}
        let overlayNames = overlays.map {$0.name}.sorted()
        selector.removeAllItems()
        selector.addItems(withTitles: overlayNames)
    }
}
