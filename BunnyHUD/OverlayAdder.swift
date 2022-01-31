/*
See LICENSE folder for licensing information.
*/


import Cocoa

extension OutlineViewController {
    @objc
    func addOverlay(_ notif: Notification) {
        let overlayWinController = self.storyboard!.instantiateController(withIdentifier: "OverlaySheet") as! NSWindowController
        view.window?.beginSheet(overlayWinController.window!)
    }
    
    @objc
    func addOverlayDone(_ notif: Notification) {
        let selector = notif.userInfo?[Notification.overlayKey.selector]! as! String
        let name = selector
        switch selector {
        case "Kagerou":
            let url = OverlayURL(modern: false, path: "https://idyllshi.re/kagerou/overlay/")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 500))
            addNodeToOverlays(node)
        case "MopiMopi":
            let url = OverlayURL(modern: false, path: "https://haeruhaeru.github.io/mopimopi/")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 500))
            addNodeToOverlays(node)
        case "Ember Overlay":
            let url = OverlayURL(modern: false, path: "https://goldenchrysus.github.io/ffxiv/ember-overlay/")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 400))
            addNodeToOverlays(node)
        case "Ember Spell Timers":
            let url = OverlayURL(modern: false, path: "https://goldenchrysus.github.io/ffxiv/ember-overlay/", options: "&mode=spells")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 400))
            addNodeToOverlays(node)
        case "Horizoverlay":
            let url = OverlayURL(modern: false, path: "https://bsides.github.io/horizoverlay/")
            let node = Node(title: name, url: url, pos: NSRect(x: screenWidth(percent: 5), y: 0, width: screenWidth(percent: 90), height: 300))
            addNodeToOverlays(node)
        case "Ikegami":
            let url = OverlayURL(modern: false, path: "https://idyllshi.re/ikegami/")
            let node = Node(title: name, url: url, pos: NSRect(x: screenWidth(percent: 5), y: 0, width: screenWidth(percent: 90), height: 500))
            addNodeToOverlays(node)
        case "Skyline":
            let url = OverlayURL(modern: true, path: "https://skyline.dsrkafuu.su")
            let node = Node(title: name, url: url, pos: NSRect(x: screenWidth(percent: 5), y: 0, width: screenWidth(percent: 90), height: 500))
            addNodeToOverlays(node)
        case "Cactbot Raidboss (Combined Alerts & Timeline)":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/raidboss/raidboss.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 1100, height: 300))
            addNodeToOverlays(node)
        case "Cactbot Raidboss Alerts only":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/raidboss/raidboss.html", options: "&alerts=1&timeline=0")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 1100, height: 300))
            addNodeToOverlays(node)
        case "Cactbot Raidboss Timeline only":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/raidboss/raidboss.html", options: "&alerts=0&timeline=1")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 320, height: 220))
            addNodeToOverlays(node)
        case "Cactbot Jobs":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/jobs/jobs.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 300))
            addNodeToOverlays(node)
        case "Cactbot Eureka":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/eureka/eureka.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 400, height: 400))
            addNodeToOverlays(node)
        case "Cactbot Fisher":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/fisher/fisher.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 500, height: 500))
            addNodeToOverlays(node)
        case "Cactbot OopsyRaidsy":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/oopsyraidsy/oopsyraidsy.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 400, height: 400))
            addNodeToOverlays(node)
        case "Cactbot PullCounter":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/pullcounter/pullcounter.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 200, height: 200))
            addNodeToOverlays(node)
        case "Cactbot Radar":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/radar/radar.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 300, height: 400))
            addNodeToOverlays(node)
        case "Cactbot Test":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/test/test.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 300, height: 300))
            addNodeToOverlays(node)
        case "Cactbot DPS Xephero":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/dps/xephero/xephero-cactbot.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 400))
            addNodeToOverlays(node)
        case "Cactbot DPS Rdmty":
            let url = OverlayURL(modern: true, path: "https://quisquous.github.io/cactbot/ui/dps/rdmty/dps.html")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: 600, height: 400))
            addNodeToOverlays(node)
        case "NextUI":
            let url = OverlayURL(modern: true, path: "https://kaminaris.github.io/Next-UI/")
            let node = Node(title: name, url: url, pos: NSRect(x: 0, y: 0, width: screenWidth(percent: 100.0), height: 500))
            addNodeToOverlays(node)
        default:
            let alert = NSAlert()
            alert.messageText = "Overlay \(selector) is not implemented yet"
            alert.informativeText = "Bunny HUD will not change your configuration."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func screenWidth(percent: CGFloat) -> Int{
        if let screen = NSScreen.main {
            let rect = screen.frame
            let width = rect.size.width
            return Int(width * (percent / 100))
        }
        else {
            return 1000
        }
    }
    
}
