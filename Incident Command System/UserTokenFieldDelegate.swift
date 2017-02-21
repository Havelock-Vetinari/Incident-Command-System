//
//  UserTokenFieldDelegate.swift
//  Incident Command System
//
//  Created by Julian Szulc on 16/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Cocoa

class UserTokenFieldDelegate:NSObject, NSTokenFieldDelegate {
    
    var hipchat:HipChat? = nil
    
    init(withHipChat:HipChat) {
        self.hipchat = withHipChat
    }
    
    func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
        return (representedObject as? User)?.displayName
        
        
    }
    
    func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any {
        if let usersList = hipchat?.userList {
            if let found = ((usersList as Array<Any>).first {($0 as? User)?.displayName ?? "" == editingString} as? User) {
                return User(withName: found.userName, andMention: found.mentionName)
            }
        }
        return User(withName: "", andMention: "")
    }
    
    func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        if let returned = hipchat?.userList {
            selectedIndex?.initialize(to: -1)
            return returned.map {
                $0.displayName
                }.filter {
                    ($0.localizedCaseInsensitiveContains(substring))
            }
        }
        return nil
    }
    
    func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
        var validTokens:[Any] = []
        for var token in tokens {
            if let userInputToken:User = token as? User {
                if let inFieldTokens:Array = tokenField.objectValue as? Array<Any> {
                    if (inFieldTokens.filter() {
                        ($0 as? User)?.displayName == userInputToken.displayName
                    }).count > 1 {
                        print("Found in field \(userInputToken.displayName)")
                        print(inFieldTokens.debugDescription)
                        
                        continue
                    }
                }
                if let definedTokens = hipchat?.userList {
                    if !(definedTokens.contains() {$0.displayName == userInputToken.displayName }) {
                        print("Not valid")
                        continue
                    }
                }
            }
            validTokens.append(token)
        }
        
        return validTokens
    }
}
