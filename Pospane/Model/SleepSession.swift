//
//  SleepSession.swift
//  Pospane
//
//  Created by Karol Stępień on 05.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation

class SleepSession {
    
    var isInProgress: Bool?
    var name: String?
    var inBed: [Int]?
    var asleep: [Int]?
    var awake: [Int]?
    var outOfBed: [Int]?
    
    convenience init(withSleepSession session: Dictionary<String, AnyObject>) {
        self.init()
        print(session)
        for (key, value) in session {
            switch key {
            case "isInProgress":
                self.isInProgress = value as? Bool
            case "name":
                self.name = value as? String
            case "inBed":
                self.inBed = value as? [Int]
            case "asleep":
                self.asleep = value as? [Int]
            case "awake":
                self.awake = value as? [Int]
            case "outOfBed":
                self.outOfBed = value as? [Int]
            default:
                break;
            }
        }
    }
    
}
