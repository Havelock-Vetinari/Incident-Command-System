//
//  AppDelegate.swift
//  Incident Command System
//
//  Created by Julian Szulc on 29/11/2016.
//  Copyright © 2016 Julian Szulc. All rights reserved.
//

import Cocoa
import LetsMove

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    

    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let popover = NSPopover()
    
    let userDefaults:UserDefaults = UserDefaults.standard
    
    var hipChat:HipChat?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        hipChat = HipChat(
            withApiToken: userDefaults.string(forKey: "api_token"),
            andObserver: nil
        )
        hipChat?.requestUsers()
        userDefaults.addObserver(self, forKeyPath: "api_token", options: .new, context: nil)
        if let button = statusItem.button {
            button.title = "ICS"
            button.action = #selector(togglePopover(sender:))
        }
        popover.contentViewController = ICSViewController(nibName: "ICSView", bundle: nil)
        (popover.contentViewController as! ICSViewController).hipchat = self.hipChat
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "api_token" {
            hipChat?.hipChatService.apiKey = userDefaults.string(forKey: "api_token")
            hipChat?.requestUsers()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

}

