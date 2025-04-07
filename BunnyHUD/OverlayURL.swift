/*
 See LICENSE folder for licensing information.
 */

import Foundation

class OverlayURL: Codable {
    var modern: Bool
    var remote: Bool
    var path: String
    var folder: String
    var options: String

    private let ipAddressKey = "ipAdress"
    private let defaultAddress = "127.0.0.1"
    private let portKey = "port"
    private let defaultPort = "10501"
    private enum CodingKeys: String, CodingKey {
        case modern
        case remote
        case path
        case folder
        case options
    }
    
    init() {
        self.modern = false
        self.remote = false
        self.path = ""
        self.folder = ""
        self.options = ""
    }
    
    convenience init(modern: Bool, path: String) {
        self.init(modern: modern, path: path, folder: "")

    }
    
    init(modern: Bool, path: String, folder: String) {
        self.modern = modern
        self.remote = folder == ""
        let parts = path.components(separatedBy: "?")
        self.path = parts[0]
        self.folder = folder
        self.options = parts.count > 1 ? "&" + parts[1] : ""
    }
    
    var ipAddress: String {
        get {
            return GeneralSettingsController.getSetting(settingKey: ipAddressKey, defaultValue: defaultAddress)
        }
        set(newAddress) {
            UserDefaults.standard.set(newAddress, forKey: ipAddressKey)
        }
    }
    
    var port: String {
        get {
            return GeneralSettingsController.getSetting(settingKey: portKey, defaultValue: defaultPort)
        }
        set(newPort) {
            UserDefaults.standard.set(newPort, forKey: portKey)
        }
    }
    
    private var tail: String {
        return modern ? "?OVERLAY_WS=ws://"+ipAddress+":"+port+"/ws"+options :
            "?HOST_PORT=ws://"+ipAddress+":"+port+options
    }
    
    var computeURL: URL {
        return remote ? URL(string: path+tail)! :
            URL(string: path+tail, relativeTo: URL(fileURLWithPath: folder))!
    }
}
