//
//  OverlaySheetController.swift
//  BunnyHUD
//
//  Created by Marc-Aurel Zent on 26.10.21.
//
import Cocoa

private struct OverlaysContainer: Codable {
    let version: Int
    let overlays: [Overlay]
}

private struct Overlay: Codable {
    let name: String
    let uri: String
    let plaintextUri: String
    let features: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case uri
        case plaintextUri = "plaintext_uri"
        case features
    }
}

class OverlaySheetController: NSViewController {
    @IBOutlet private var okButton: NSButton!
    @IBOutlet private var selector: NSPopUpButton!
    @IBOutlet private var urlField: NSTextField!
    
    private static let jsonURL = Bundle.main.url(forResource: "overlays", withExtension: "json")!
    private static let jsonData = try! Data(contentsOf: jsonURL)
    private static let overlayContainer = try! JSONDecoder().decode(OverlaysContainer.self, from: jsonData)
    private static let overlays = Dictionary(uniqueKeysWithValues: overlayContainer.overlays.map { ($0.name, $0) })
    
    static let systemOverlayURLs = Dictionary(uniqueKeysWithValues: overlays.values
        .filter { $0.features.contains("system") }
        .map { ($0.name, OverlayURL(modern: $0.features.contains("overlay_ws"), path: $0.uri)) })
    
    fileprivate var selectedOverlay: Overlay? {
        guard let overlayName = selector.titleOfSelectedItem else {
            return nil
        }
        let overlays = OverlaySheetController.overlays.values
        guard let selected = overlays.first(where: { $0.name == overlayName }) else {
            return nil
        }
        return selected
    }
    
    fileprivate func getOverlayURL(from: Overlay) -> OverlayURL {
        OverlayURL(modern: from.features.contains("overlay_ws"), path: from.uri)
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
        let overlays = OverlaySheetController.overlays.values.filter { !($0.features.contains("system")) }
        let overlayNames = overlays.map { $0.name }.sorted()
        selector.removeAllItems()
        selector.addItems(withTitles: overlayNames)
        updateURL(self)
    }
}
