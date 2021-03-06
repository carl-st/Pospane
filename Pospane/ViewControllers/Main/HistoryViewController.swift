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
    var objectToSave: Session?
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var selectedSleep: Session?

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Session> = {
        let request = NSFetchRequest<Session>(entityName: "Session")
        let creationDateSort = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [creationDateSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        print("Session: \(session)")
        print("fetchedResultsCntroller: ", fetchedResultsController.fetchedObjects)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[DEBUG] WatchConnectivity Session state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let request = message["request"] as? String else { return }
        
        print(message)
        var response: [String : Any] = [:]
        if request == "mostRecentSleepSession" {
            // TODO
        } else if request == "sendData" {
           handleWatchData(message: message, managedContext: managedContext, replyHandler: replyHandler)
        } else {
            print("unknown history request")
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
        sleepSessionDictionary["phases"] = mostRecentSleepSession.phases
        print("phases: \(mostRecentSleepSession.phases!)")
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSleep = fetchedResultsController.object(at: indexPath)
        print(fetchedResultsController.object(at: indexPath))
        performSegue(withIdentifier: SegueIdentifier.showResultsViewController.rawValue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showResultsViewController.rawValue {
            let vc = segue.destination as? ResultsViewController
            guard let selectedSleep = selectedSleep, let phases = selectedSleep.phases else { return }
            vc?.resultsText = "Phases \(phases)"
        }
    }
}
