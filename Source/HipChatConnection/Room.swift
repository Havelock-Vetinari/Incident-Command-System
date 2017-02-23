//
//  Room.swift
//  Incident Command System
//
//  Created by Julian Szulc on 18/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Room: NSCoding, CustomStringConvertible {
    
    let roomId: Int!
    let roomName: String!
    
    init(withJSON json: JSON){
        roomId = json["id"].int
        roomName = json["name"].string
    }
    
    required init(coder aDecoder: NSCoder) {
        roomId = aDecoder.decodeInteger(forKey: "roomId")
        roomName = aDecoder.decodeObject(forKey: "roomName") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.roomId, forKey: "roomId")
        aCoder.encode(self.roomName, forKey: "roomName")
    }
    
    var displayName:String {
        get {
            return roomName
        }
    }
    
    var description:String {
        get {
            return displayName
        }
    }
    
}
