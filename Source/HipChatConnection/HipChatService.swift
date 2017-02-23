//
//  HipChatConnector.swift
//  Incident Command System
//
//  Created by Julian Szulc on 10/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Siesta
import SwiftyJSON

class HipChatService: Service {
    var apiKey:String? {
        didSet {
            wipeResources()
            invalidateConfiguration()
        }
    }
    
    private var authHeader: String? {
        return "Bearer \(self.apiKey ?? "")"
    }
    
    init(apiKey:String?){
        self.apiKey = apiKey ?? ""
        super.init(baseURL: "https://api.hipchat.com/v2")
        
        self.configure {
            $0.pipeline[.parsing].add(self.SwiftyJSONTransformer, contentTypes: ["*/json"])
            $0.headers["Authorization"] = self.authHeader
            
        }
        self.configureTransformer("/user") {
            ($0.content as JSON)["items"].arrayValue.map {User(withJSON: $0)}
        }
        self.configureTransformer("/room") {
            ($0.content as JSON)["items"].arrayValue.map {Room(withJSON: $0)}
        }
    }
    
    var users: Resource { return resource("/user").withParam("max-results", "1000") }
    var rooms: Resource { return resource("/room").withParam("max-results", "1000") }
    
    @discardableResult
    func  send(message theMessage:String, toRoom aRoom:String) -> Request {
        let sendResource:Resource = resource("/room")
            .child(aRoom)
            .child("message")
        return sendResource.request(
            .post,
            json: ["message": theMessage]
        )
    }
    
    @discardableResult
    func send(htmlNotification notification:String, toRoom aRoom:String, withColor color: HipChatColor, andNotifyUsers notify:Bool = false) -> Request {
        let notifyResource:Resource = resource("/room")
            .child(aRoom)
            .child("notification")
        let parameters:[String : String] = [
            "message_format": HipChatMessageFormat.html.rawValue,
            "color": color.rawValue,
            "message": notification,
            "notify": notify.description
        ]
        print(parameters)
        return notifyResource.request(
            .post, json: parameters
        )
        
    }
    
    @discardableResult
    func setTopic(_ topic: String, forRoom aRoom:String) -> Request {
        let setTopicResource:Resource = resource("/room")
            .child(aRoom)
            .child("topic")
        return setTopicResource.request(.put, json: ["topic": topic])
    }
    
    @discardableResult
    func setAlias(_ alias:String, forUsers users:[User], inRoom aRoom:String) -> Request {
        let usersAliases:String = users.map(){ $0.mentionName }.joined(separator: " ")
        let aliasMessage:String = "/alias set @\(alias) \(usersAliases)"
        return send(message: aliasMessage, toRoom: aRoom)
    }
    
    @discardableResult
    func deleteAlias(_ alias:String, inRoom aRoom:String) -> Request {
        return send(message: "/alias remove @\(alias)", toRoom: aRoom)
    }
    
    private let SwiftyJSONTransformer =
        ResponseContentTransformer
            { JSON($0.content as AnyObject) }
    
}

enum HipChatColor: String {
    case yellow, green, red, purple, gray, random
}

enum HipChatMessageFormat: String {
    case text, html
}
