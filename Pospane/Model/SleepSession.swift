//
//  SleepSession.swift
//  Pospane
//
//  Created by Karol Stępień on 05.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation

class SleepSession {
    
    var isInProgress: Bool = false
    var name: String?
    var inBed: [Date]?
    var asleep: [Date]?
    var awake: [Date]?
    var outOfBed: [Date]?
    
    convenience init(withSleepSession session: NSDictionary) {
        self.init()
        print(session)
        guard let isInProgress = session.object(forKey: "isInProgress") as? Bool else { return }
            self.isInProgress = isInProgress
            self.name = session.object(forKey: "name") as? String
            self.inBed = session.object(forKey: "inBed") as? [Date]
            self.asleep = session.object(forKey: "asleep") as? [Date]
            self.awake = session.object(forKey: "awake") as? [Date]
            self.outOfBed = session.object(forKey: "outOfBed") as? [Date]
    }
    
}
