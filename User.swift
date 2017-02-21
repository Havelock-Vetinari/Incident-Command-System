//
//  User.swift
//  Incident Command System
//
//  Created by Julian Szulc on 14/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSCoding, CustomStringConvertible {
    
    public let userName:String!
    public let mentionName:String!
    
    init(withJSON json:JSON){
        if let theName = json["name"].string {
            userName = theName
        } else {
            userName = ""
        }
        if let theMention = json["mention_name"].string {
            mentionName = "@\(theMention)"
        } else {
            mentionName = ""
        }
    }
    
    init(withName name:String, andMention mention:String){
        self.userName = name
        self.mentionName = mention
    }
    
    required init(coder aDecoder: NSCoder) {
        self.userName = aDecoder.decodeObject(forKey: "userName") as? String
        self.mentionName = aDecoder.decodeObject(forKey: "mentionName") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mentionName, forKey: "mentionName")
        aCoder.encode(self.userName, forKey: "userName")
    }
    
    public var displayName:String {
        get {
            return "\(self.mentionName!) (\(self.userName!))"
        }
    }
    
    var description:String {
        get {
            return displayName
        }
    }
    
}
