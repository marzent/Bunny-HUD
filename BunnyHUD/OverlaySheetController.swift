//
//  OverlaySheetController.swift
//  BunnyHUD
//
//  Created by Marc-Aurel Zent on 26.10.21.
//
import Cocoa

private struct OverlaysValue: Codable {
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

private typealias Overlays = [String: OverlaysValue]

class OverlaySheetController: NSViewController {
    @IBOutlet private var okButton: NSButton!
    @IBOutlet private var selector: NSPopUpButton!
    @IBOutlet private var urlField: NSTextField!
    
    private static let jsonURL = Bundle.main.url(forResource: "overlays", withExtension: "json")!
    private static let jsonData = try! Data(contentsOf: jsonURL)
    private static let overlays = try! JSONDecoder().decode(Overlays.self, from: jsonData)
    
    static let systemOverlayURLs = Dictionary(uniqueKeysWithValues: overlays.values
        .filter { $0.system ?? false }
        .map { ($0.name, OverlayURL(modern: $0.modern, path: $0.httpProxy, options: $0.options)) })
    
    fileprivate var selectedOverlay: OverlaysValue? {
        guard let overlayName = selector.titleOfSelectedItem else {
            return nil
        }
        let overlays = OverlaySheetController.overlays.values
        guard let selected = overlays.first(where: { $0.name == overlayName }) else {
            return nil
        }
        return selected
    }
    
    fileprivate func getOverlayURL(from: OverlaysValue) -> OverlayURL {
        OverlayURL(modern: from.modern, path: from.httpProxy, options: from.options)
    }
    
    @IBAction func okAction(_ sender: Any) {
        guard let selectedOverlay = selectedOverlay else {
            return
        }
        let overlayURL = getOverlayURL(from: selectedOverlay)
        NotificationCenter.default.post(name: .addOverlayDone, object: nil,
                                        userInfo: [Notification.overlayKey.name: selectedOverlay.name,
                                                   Notification.overlayKey.url: overlayURL])
        view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        view.window?.close()
    }
    
    @IBAction func updateURL(_ sender: Any) {
        guard let selectedOverlay = selectedOverlay else {
            return
        }
        let overlayURL = getOverlayURL(from: selectedOverlay)
        urlField.stringValue = overlayURL.computeURL.absoluteString
    }
    
    override func viewWillAppear() {
        okButton.isHighlighted = true
        let overlays = OverlaySheetController.overlays.values.filter { !($0.system ?? false) }
        let overlayNames = overlays.map { $0.name }.sorted()
        selector.removeAllItems()
        selector.addItems(withTitles: overlayNames)
        updateURL(self)
    }
}
