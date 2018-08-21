//
//  HistoryViewController.swift
//  Pospane
//
//  Created by Karol Stępień on 03.04.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class HistoryViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet var tableVIew: UITableView!
    var objectToSave = Session()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[DEBUG] WatchConnectivity Session state: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let request = message["request"] as? String else { return }
        
        print(message)
        var response: [String : Any] = [:]
        if request == "mostRecentSleepSession" {
            // TODO
        } else if request == "sendData" {
            print("[DEBUG] Received sleep session data from Apple Watch app. Saving in progess.");
            //                    self.objectToSave = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:[self managedObjectContext]];
            let entity = NSEntityDescription.entity(forEntityName: "Session", in: managedContext)!
            self.objectToSave = NSManagedObject(entity: entity, insertInto: managedContext) as! Session
            self.objectToSave.name = message["name"] as? String
            self.objectToSave.creationDate = message["creationDate"] as? Date
            self.objectToSave.inBed = message["inBed"] as? Data
            self.objectToSave.asleep = message["asleep"] as? Data
            self.objectToSave.awake = message["awake"] as? Data
            self.objectToSave.outOfBed = message["outOfBed"] as? Data
            
            // notification
            
            do {
                try managedContext.save()
                replyHandler(["success" : true])
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            print("unknown request")
        }
    }
    
    private func populateDictionaryWithSleepSessionData(mostRecentSleepSession: Session) -> [String : Any] {
        var sleepSessionDictionary: [String : Any] = [:]
        sleepSessionDictionary["request"] = "sendData"
        sleepSessionDictionary["name"] = "session"
        sleepSessionDictionary["creationDate"] = Date()
        sleepSessionDictionary["inBed"] = mostRecentSleepSession.inBed
        sleepSessionDictionary["asleep"] = mostRecentSleepSession.asleep
        sleepSessionDictionary["awake"] = mostRecentSleepSession.awake
        sleepSessionDictionary["outOfBed"] = mostRecentSleepSession.outOfBed
        
        return sleepSessionDictionary
    }
    
    
}
