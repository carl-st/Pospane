//
//  Constants.swift
//  Pospane
//
//  Created by Karol Stępień on 17.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation

public enum dictionaryKeys: NSString {
    case currentSleep = "Current Sleep Session"
    case previousSleep = "Previous Sleep Session"
}

public enum fileNames: String {
    case savedSleepSession = "SavedSleepSession"
    case sleeping = "Sleeping"
}

public enum numbers: Double {
    case removeDeferredOptionTimer = 7200
}
