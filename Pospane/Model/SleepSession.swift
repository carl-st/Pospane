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
    var name: String = ""
    var inBed: [Date] = []
    var asleep: [Date] = []
    var awake: [Date] = []
    var outOfBed: [Date] = []
    
    convenience init(withSleepSession session: NSDictionary) {
        self.init()
        print(session)
        guard let isInProgress = session.object(forKey: "isInProgress") as? Bool else { return }
        guard let name = session.object(forKey: "name") as? String else { return }
        guard let inBed = session.object(forKey: "inBed") as? [Date] else { return }
        guard let asleep = session.object(forKey: "asleep") as? [Date] else { return }
        guard let awake = session.object(forKey: "awake") as? [Date] else { return }
        guard let outOfBed = session.object(forKey: "outOfBed") as? [Date] else { return }
        
        
            self.isInProgress = isInProgress
            self.name = name
            self.inBed = inBed
            self.asleep = asleep
            self.awake = awake
            self.outOfBed = outOfBed
    }
    
}
