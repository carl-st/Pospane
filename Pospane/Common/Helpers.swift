//
//  Helpers.swift
//  Pospane
//
//  Created by Karol Stępień on 10.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation

class Helpers {
    func contentsOfCurrentSleepSession() -> SleepSession {
        let sleepSessionFile: NSDictionary?
        let currentSleepSessionFile: NSDictionary?
        if let path = Bundle.main.path(forResource: "SavedSleepSession", ofType: "plist") { // TODO: Add to constants file
            sleepSessionFile = NSDictionary(contentsOfFile: path)
            currentSleepSessionFile = NSDictionary(dictionary: (sleepSessionFile?.object(forKey: "currentSleepSession") as? NSDictionary)!)
            return SleepSession(withSleepSession: currentSleepSessionFile!)
        }
        return SleepSession()
    }
    
    func getPathToSleepSessionFile() -> String {
        if let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return "\(documentsDirectory)/SavedSleepSession.plist"
        }
        return ""
    }
    
    func dateFormatterForTimeLabels() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
    
    func compare(originalDate: Date, isLaterThanOrEqualTo otherDate: Date) -> Bool {
        return originalDate.compare(otherDate) != .orderedAscending
    }
    
    func compare(originalDate: Date, isEarlierThan otherDate: Date) -> Bool {
        return originalDate.compare(otherDate) == .orderedAscending
    }
}
