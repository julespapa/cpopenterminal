//
//  CPOpenTerminal.swift
//
//  Created by ParkByounghyouk on 3/22/16.
//  Copyright © 2016 ParkByounghyouk. All rights reserved.
//

import AppKit

var sharedPlugin: CPOpenTerminal?

class CPOpenTerminal: NSObject {

    var bundle: Bundle
    lazy var center = NotificationCenter.default

    init(bundle: Bundle) {
        self.bundle = bundle

        super.init()
        print(bundle)
        center.addObserver(self, selector: Selector(("createMenuItems")), name: NSApplication.didFinishLaunchingNotification, object: nil)
    }

    deinit {
        removeObserver()
    }

    func removeObserver() {
        center.removeObserver(self)
    }

    func getXCodeProjectPath() -> String {
        if let anyClass = NSClassFromString("IDEWorkspaceWindowController") as? NSObject.Type {
            let workspaceWindowControllers = anyClass.value(forKey: "workspaceWindowControllers") as! [AnyObject]
            for controller in workspaceWindowControllers {
                if (controller.value(forKey: "window")! as AnyObject).isEqual(NSApp.keyWindow) {
                    if let workSpace = controller.value(forKey: "_workspace"),
                        let filePath = (workSpace as AnyObject).value(forKey: "representingFilePath"),
                        let pathString = (filePath as AnyObject).value(forKey: "_pathString")
                    {
                        return pathString as! String
                    }
                }
            }
        }
        return ""
    }
    
    func createMenuItems() {
        removeObserver()
        let item = NSApp.mainMenu!.item(withTitle: "Window")
        if item != nil {
            
            let actionMenuItem = NSMenuItem(title:"Open Terminal", action:Selector(("doMenuAction")), keyEquivalent:"l")
            actionMenuItem.keyEquivalentModifierMask = [.command, .control]
            actionMenuItem.target = self
            item!.submenu!.addItem(NSMenuItem.separator())
            item!.submenu!.addItem(actionMenuItem)
        }
    }

    func doMenuAction() {
        print(getXCodeProjectPath())
        
        let script =    "tell application \"Terminal\"\n" +
                            "activate\n" +
                            "tell window 1\n" +
                                "do script \"cd \(getXCodeProjectPath())/..\"\n" +
                            "end tell\n" +
                        "end tell\n"
        if let scriptObject = NSAppleScript(source: script) {
            var errorDict: NSDictionary? = nil
            scriptObject.executeAndReturnError(&errorDict)
            if errorDict != nil {
                print(errorDict)
            }
        }
    }
}

