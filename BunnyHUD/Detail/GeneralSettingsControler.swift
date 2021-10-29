/*
See LICENSE folder for licensing information.
*/


import Cocoa

class GeneralSettingsController: NSViewController {

    @IBOutlet private var ipField: NSTextField!
    @IBOutlet private var portField: NSTextField!
    @IBOutlet private var cactbot: NSButton!
    @IBOutlet private var kagerou: NSButton!
    @IBOutlet private var hidden: NSButton!
    
    static let cactbotKey = "showCactbotSettings"
    static let kagerouKey = "showKagerouSettings"
    static let hiddenKey = "hideWinOnStart"
    private let url = OverlayURL()
    
    static func getSetting<T>(settingKey : String, defaultValue: T) -> T {
        let defaults = UserDefaults.standard
        let setting = defaults.object(forKey: settingKey)
        if setting == nil {
            defaults.set(defaultValue, forKey: settingKey)
            return defaultValue
        }
        return setting as! T
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipField.stringValue = url.ipAddress
        portField.stringValue = url.port
        func bGet (key: String) -> Bool {
            type(of: self).getSetting(settingKey: key, defaultValue: false)
        }
        cactbot.state = bGet(key: type(of: self).cactbotKey) ? NSControl.StateValue.on : NSControl.StateValue.off
        kagerou.state = bGet(key: type(of: self).kagerouKey) ? NSControl.StateValue.on : NSControl.StateValue.off
        hidden.state = bGet(key: type(of: self).hiddenKey) ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    @IBAction func update(_ sender: Any) {
        url.ipAddress = ipField.stringValue
        url.port = portField.stringValue
        func bSet (key: String, box: NSButton) {
            UserDefaults.standard.set(box.state == NSControl.StateValue.on ? true : false, forKey: key)
        }
        bSet(key: type(of: self).cactbotKey, box: cactbot)
        bSet(key: type(of: self).kagerouKey, box: kagerou)
        bSet(key: type(of: self).hiddenKey, box: hidden)
    }
}
