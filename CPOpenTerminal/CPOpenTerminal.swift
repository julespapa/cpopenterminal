//
//  CPOpenTerminal.swift
//
//  Created by ParkByounghyouk on 3/22/16.
//  Copyright © 2016 ParkByounghyouk. All rights reserved.
//

import AppKit

var sharedPlugin: CPOpenTerminal?

class CPOpenTerminal: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        print(bundle)
        center.addObserver(self, selector: Selector("createMenuItems"), name: NSApplicationDidFinishLaunchingNotification, object: nil)
    }

    deinit {
        removeObserver()
    }

    func removeObserver() {
        center.removeObserver(self)
    }

    func getXCodeProjectPath() -> String {
        if let anyClass = NSClassFromString("IDEWorkspaceWindowController") as? NSObject.Type {
            let workspaceWindowControllers = anyClass.valueForKey("workspaceWindowControllers") as! [AnyObject]
            for controller in workspaceWindowControllers {
                if controller.valueForKey("window")!.isEqual(NSApp.keyWindow) {
                    if let workSpace = controller.valueForKey("_workspace"),
                        let filePath = workSpace.valueForKey("representingFilePath"),
                        let pathString = filePath.valueForKey("_pathString")
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
        let item = NSApp.mainMenu!.itemWithTitle("Window")
        if item != nil {
            let actionMenuItem = NSMenuItem(title:"Open Terminal", action:"doMenuAction", keyEquivalent:"l")
            actionMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ControlKeyMask.rawValue)
            actionMenuItem.target = self
            item!.submenu!.addItem(NSMenuItem.separatorItem())
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

