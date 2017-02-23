//
//  UserTransformer.swift
//  Incident Command System
//
//  Created by Julian Szulc on 20/02/2017.
//  Copyright © 2017 Julian Szulc. All rights reserved.
//

import Foundation

class UserTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if let theValue = value as? User {
            print(theValue.description)
            return theValue.description
        }
        return nil
    }
}
