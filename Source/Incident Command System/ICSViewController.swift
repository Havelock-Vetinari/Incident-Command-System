//
//  ICSView.swift
//  Incident Command System
//
//  Created by Julian Szulc on 10/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Cocoa
import SwiftyJSON


class ICSViewController: NSViewController {
    
    public var hipchat:HipChat? = nil
    
    let startImageUrl = "https://s3-eu-west-1.amazonaws.com/uploads-eu.hipchat.com/26322/1475364/Qsn9TH15ymqJkIc/start.gif"
    let endImageUrl = "https://s3-eu-west-1.amazonaws.com/uploads-eu.hipchat.com/26322/1475364/M6dQRSSxbITYKCU/end.gif"
    
    @IBOutlet var icToken:NSTokenField?
    @IBOutlet var lioToken:NSTokenField?
    @IBOutlet var taskRecord:NSTextField?
    @IBOutlet var messageField:NSTextField?
    
    lazy var userTokenFieldDelegate:UserTokenFieldDelegate = {
        UserTokenFieldDelegate(withHipChat: self.hipchat!)
    }()
    
    lazy var preferencesSheet:NSViewController = {
        return PreferencesViewController(nibName: "PreferencesView", bundle: nil)! as NSViewController
    }()
    
    var destinationRoom:String! {
        get {
            return UserDefaults.standard.string(forKey: "hipchat_room")
        }
    }
    
    var getPrettyNow: String {
        get {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .long
            return formatter.string(from: Date())
        }
    }
    
    
    @IBAction func lauchICS(sender: NSButton) {        
        let icUsers:[User] = icToken?.objectValue as? [User] ?? []
        let lioUsers:[User] = lioToken?.objectValue as? [User] ?? icUsers
        
        if icUsers.isEmpty {
            print("No IC, no ICS")
            return
        }
        
        hipchat?.hipChatService.send(
            htmlNotification: buildNotification(
                withImage: startImageUrl,
                andText: "🚨🚨🚨 ICS Start! 🚨🚨🚨<br>\(taskRecord?.stringValue ?? "")"),
            toRoom: destinationRoom,
            withColor: .red,
            andNotifyUsers:true
        )
        
        hipchat?.hipChatService.setAlias(
            "ic", forUsers: icUsers, inRoom: destinationRoom
        )
        hipchat?.hipChatService.setAlias(
            "lio", forUsers: lioUsers, inRoom: destinationRoom)
        
        let topic:String = buildTopic(fromICUsers: icUsers, andFromLIOUsers: lioUsers, andTaskRecord: taskRecord?.stringValue)
        hipchat?.hipChatService.setTopic(topic, forRoom: destinationRoom)
        if !(messageField?.stringValue.isEmpty)! {
            hipchat?.hipChatService.send(message: (messageField?.stringValue)!, toRoom: destinationRoom)
        }
        
        hipchat?.hipChatService.send(
            message: buildWelcomeMessage(withICUsers: icUsers, andWithLIOUsers: lioUsers, andTaskRecord: taskRecord?.stringValue),
            toRoom: destinationRoom
        )
    }
    
    @IBAction func stopICS(sender: NSButton) {
        hipchat?.hipChatService.send(
            htmlNotification: buildNotification(
                withImage: endImageUrl,
                andText: "🏁🏁🏁 ICS Stop! 🏁🏁🏁<br>\(taskRecord?.stringValue ?? "")<br>So Long, and Thanks for All the Fish"),
            toRoom: destinationRoom,
            withColor: .green,
            andNotifyUsers:true
        )
        hipchat?.hipChatService.deleteAlias("ic", inRoom: destinationRoom)
        hipchat?.hipChatService.deleteAlias("lio", inRoom: destinationRoom)
        hipchat?.hipChatService.setTopic("IDLE... | last ICS ended on \(getPrettyNow)", forRoom: destinationRoom)
        
    }
    
    private func buildTopic(fromICUsers icUsers:[User]?, andFromLIOUsers lioUsers:[User]?, andTaskRecord taskRecord:String?) -> String {
        let ic:String = (icUsers?.map(){$0.description}.joined(separator: ", ")) ?? ""
        let lio:String = (lioUsers?.map(){$0.description}.joined(separator: ", ")) ?? ""
        var topic:String = "👨‍🚒 Incident Command: \(ic) | 📡 Information Office: \(lio)"
        if let record = taskRecord {
            topic += " 📼 \(record)"
        }
        return topic
    }
    
    private func buildWelcomeMessage(withICUsers icUsers:[User]?, andWithLIOUsers lioUsers:[User]?, andTaskRecord taskRecord:String?) -> String {
        let ic:String = (icUsers?.map(){$0.description}.joined(separator: ", ")) ?? ""
        let lio:String = (lioUsers?.map(){$0.description}.joined(separator: ", ")) ?? ""
        var message:String = "Rozpoczynam proces Incydent Command System!\n\n👨‍🚒 Dowództwo: \(ic)\n📡 Łączność i Komunikacja: \(lio)"
        if let record = taskRecord {
            message += "\n Powiązane z zadaniem \(record)"
        }
        return message
    }
    
    private func buildNotification(withImage imageUrl:String, andText text:String) -> String {
        return "<table><tr><td><img src=\"\(imageUrl)\" height=\"150\"></td><td>\(text)</td></tr></table>"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        icToken?.delegate = self.userTokenFieldDelegate
        lioToken?.delegate = self.userTokenFieldDelegate
    }
    
    override func viewDidAppear() {
        if (hipchat?.hipChatService.apiKey?.isEmpty) ?? false {
            showPreferences(sender: self)
        }
    }
    
    @IBAction func showPreferences(sender:Any) {
        self.presentViewControllerAsSheet(self.preferencesSheet)
    }

    
    
}
