//
//  Application.swift
//  Incident Command System
//
//  Created by Julian Szulc on 21/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Foundation
import Cocoa
@objc(Application)
class Application: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        if event.type == NSEventType.keyDown {
            
            if (event.modifierFlags.contains(NSEventModifierFlags.command)) {
                switch event.charactersIgnoringModifiers!.lowercased() {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return }
                case "a":
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to:nil, from:self) { return }
                default:
                    break
                }
            }
        }
        return super.sendEvent(event)
    }
    
}
