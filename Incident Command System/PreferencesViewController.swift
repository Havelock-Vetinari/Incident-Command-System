//
//  PreferencesViewController.swift
//  Incident Command System
//
//  Created by Julian Szulc on 15/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Cocoa
import Siesta

class PreferencesViewController: NSViewController, NSTextFieldDelegate, ResourceObserver {
    
    @IBOutlet var apiTokenField:NSTextField?
    @IBOutlet var hipchatRoomsCombo:NSPopUpButton?
    @IBOutlet var icTokenField:NSTokenField?
    @IBOutlet var lioTokenField:NSTokenField?
    @IBOutlet var progressIndicator:NSProgressIndicator?
    @IBOutlet var saveButton:NSButton?
    
    let apiTokenUserDefaultsKey:String = "api_token"
    let hipchatRoomUserDefaultsKey:String = "hipchat_room"
    
    lazy var preferencesHipChat:HipChat = {
        HipChat(
            withApiToken: UserDefaults().value(
                forKey: self.apiTokenUserDefaultsKey
                ) as? String,
            andObserver: self
        )
    }()
    
    lazy var userFieldTokenDelagate:UserTokenFieldDelegate = {
        UserTokenFieldDelegate(withHipChat: self.preferencesHipChat)
    }()

    lazy var sharedUserDefaultsController = {
        return NSUserDefaultsController.shared()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sharedUserDefaultsController.appliesImmediately = false
        self.icTokenField?.delegate = self.userFieldTokenDelagate
        self.lioTokenField?.delegate = self.userFieldTokenDelagate
        self.progressIndicator?.startAnimation(self)
        self.reloadPanel()
        
    }
    
    private func reloadPanel() {
        self.progressIndicator?.isHidden = true
        self.hipchatRoomsCombo?.isEnabled = false
        self.saveButton?.isEnabled = false
        self.preferencesHipChat.requestRooms()
    }
    
    @IBAction func cancelAction(sender: Any){
        self.sharedUserDefaultsController.revert(sender)
        self.dismissViewController(self)
    }
    
    @IBAction func saveAction(sender: Any) {
        self.sharedUserDefaultsController.save(sender)
        self.dismissViewController(self)
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        preferencesHipChat.hipChatService.apiKey = apiTokenField?.stringValue
        reloadPanel()
    }
    
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        switch event {
        case .requested:
            self.progressIndicator?.isHidden = false;
        case .newData, .notModified:
            self.progressIndicator?.isHidden = true;
            if resource === preferencesHipChat.roomsResource {
                let rooms:[CustomStringConvertible] = (resource.latestData?.typedContent()) ?? []
                self.hipchatRoomsCombo?.removeAllItems()
                self.hipchatRoomsCombo?.addItems(
                    withTitles: rooms.map(){$0.description}.sorted()
                )
                self.hipchatRoomsCombo?.isEnabled = true
                self.saveButton?.isEnabled = true
                self.hipchatRoomsCombo?.selectItem(withTitle:
                    UserDefaults.standard.string(
                        forKey: self.hipchatRoomUserDefaultsKey) ?? ""
                )
            }
        case .error, .requestCancelled, _ :
            self.progressIndicator?.isHidden = true;
            
        }
    }
    
}
