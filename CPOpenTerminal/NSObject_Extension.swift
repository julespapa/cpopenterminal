//
//  NSObject_Extension.swift
//
//  Created by ParkByounghyouk on 3/22/16.
//  Copyright © 2016 ParkByounghyouk. All rights reserved.
//

import Foundation

extension NSObject {
    class func pluginDidLoad(bundle: Bundle) {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? NSString
        if appName == "Xcode" {
        	if sharedPlugin == nil {
        		sharedPlugin = CPOpenTerminal(bundle: bundle)
        	}
        }
    }
}
