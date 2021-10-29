/*
See LICENSE folder for licensing information.
*/


import Foundation

class OverlayURL : Codable {
    
    
    var modern : Bool
    var remote: Bool
    var path : String
    var options : String

    
    private let ipAddressKey = "ipAdress"
    private let defaultAddress = "127.0.0.1"
    private let portKey = "port"
    private let defaultPort = "10501"
    private enum CodingKeys: String, CodingKey {
        case modern
        case remote
        case path
        case options
    }
    
    init () {
        self.modern = false
        self.remote = false
        self.path = ""
        self.options = ""
    }
    
    init (modern: Bool, remote : Bool = false, path: String, options : String = "") {
        self.modern = modern
        self.remote = remote
        self.path = path
        self.options = options
    }
    
    var ipAddress : String {
        get {
            return GeneralSettingsController.getSetting(settingKey: ipAddressKey, defaultValue: defaultAddress)
        }
        set(newAddress) {
            UserDefaults.standard.set(newAddress, forKey: ipAddressKey)
        }
    }
    
    var port : String {
        get {
            return GeneralSettingsController.getSetting(settingKey: portKey, defaultValue: defaultPort)
        }
        set(newPort) {
            UserDefaults.standard.set(newPort, forKey: portKey)
        }
    }
    
    private var tail : String {
        return modern ? "?OVERLAY_WS=ws://"+ipAddress+":"+port+"/ws"+options :
                        "?HOST_PORT=ws://"+ipAddress+":"+port+options
    }
    
    var computeURL: URL {
        return remote ? URL(string: path + tail)! :
                        URL(string: path + tail, relativeTo: Bundle.main.url(forResource: "dist/Overlays", withExtension: "")!)!
    }
}
