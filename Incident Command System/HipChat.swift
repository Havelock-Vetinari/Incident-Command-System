//
//  HipChat.swift
//  Incident Command System
//
//  Created by Julian Szulc on 13/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Siesta

class HipChat {
    let hipChatService:HipChatService
    let usersResource:Resource?
    let roomsResource:Resource?
    var userList:[User]?
    var roomList:[Room]?

    init(withApiToken apiKey:String?, andObserver anObserver: (ResourceObserver & AnyObject)?) {
        
        Siesta.LogCategory.enabled = LogCategory.all
        self.hipChatService = HipChatService(apiKey: apiKey)
        self.usersResource = hipChatService.users
        self.roomsResource = hipChatService.rooms
        if let theObserver = anObserver {
            self.usersResource?.addObserver(theObserver)
            self.roomsResource?.addObserver(theObserver)
        }
    }
    
    func requestUsers() {
        self.usersResource?.loadIfNeeded()?.onSuccess() {
            data in self.userList = data.typedContent()
        }
    
    }
    
    func requestRooms() {
        self.roomsResource?.loadIfNeeded()?.onSuccess() {
            data in self.roomList = data.typedContent()
        }
    }
}
