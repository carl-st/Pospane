//
//  WatchMessageHandlers.swift
//  Pospane
//
//  Created by Karol Stępień on 01/11/2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation
import CoreData

func handleWatchData (message: [String: Any], managedContext: NSManagedObjectContext, replyHandler: @escaping ([String : Any]) -> Void) {
    print("[DEBUG] Received sleep session data from Apple Watch app. Saving in progess.");
    //                    self.objectToSave = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:[self managedObjectContext]];
    // process rrIntervals
    guard let rrIntervals = message["rrIntervals"] as? [Double] else { return }
    var values: [Double] = []
    var resultLabels: [Int64] = []
    for (_, rr) in rrIntervals.enumerated() {
        let result = slidingWindowFeatures(rr: rr, values: values, width: 10)
        resultLabels.append(result.output)
        values = result.values
        print(values)
    }
    
    let entity = NSEntityDescription.entity(forEntityName: "Session", in: managedContext)!
    if let objectToSave = NSManagedObject(entity: entity, insertInto: managedContext) as? Session {
        objectToSave.name = message["name"] as? String
        objectToSave.creationDate = message["creationDate"] as? Date
        objectToSave.inBed = message["inBed"] as? Data
        objectToSave.asleep = message["asleep"] as? Data
        objectToSave.awake = message["awake"] as? Data
        objectToSave.outOfBed = message["outOfBed"] as? Data
        objectToSave.phases = resultLabels
    }
    
    // notification
    do {
        try managedContext.save()
        replyHandler(["success" : true])
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
}
