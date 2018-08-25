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

class HistoryViewController: UIViewController, WCSessionDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet var tableView: UITableView!
    var objectToSave = Session()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private let persistentContainer = NSPersistentContainer(name: "Session")
    

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Session> = {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        let creationDateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [creationDateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: "sectionByMonthAndYearUsingCreationDate", cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
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

    func numberOfSections(in tableView: UITableView) -> Int {
        if fetchedResultsController.sections?.count != nil {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = nil
        }
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellReuseIdentifier.HistoryTableViewCell.rawValue) as? HistoryTableViewCell
        cell?.configure(withSession: fetchedResultsController.object(at: indexPath))
        return cell!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex) , with: .right)
            break
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .left)
            break
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        guard let newIndexPath = newIndexPath else { return }
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath], with: .right)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath], with: .left)
            break
        case .update:
            break
        case .move:
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.tableView.insertRows(at: [newIndexPath], with: .right)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
