/*
See LICENSE folder for licensing information.
*/

import Foundation
import CEFswift

final class App: CEFApp, CEFRenderProcessHandler {
    var renderProcessHandler: CEFRenderProcessHandler? {
        return self
    }
    
    func onContextCreated(browser: CEFBrowser, frame: CEFFrame, context: CEFV8Context) {
        context.enter()
        let v8Str = CEFV8Value.createString("Hello World!")
        print("\(v8Str!.stringValue)")
        context.exit()
    }
}

