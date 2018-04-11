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
    
    convenience init(withSleepSession session: NSDictionary) {
        self.init()
        print(session)
            self.isInProgress = session.object(forKey: "isInProgress") as? Bool
            self.name = session.object(forKey: "name") as? String
            self.inBed = session.object(forKey: "inBed") as? [Int]
            self.asleep = session.object(forKey: "asleep") as? [Int]
            self.awake = session.object(forKey: "awake") as? [Int]
            self.outOfBed = session.object(forKey: "outOfBed") as? [Int]
    }
    
}
