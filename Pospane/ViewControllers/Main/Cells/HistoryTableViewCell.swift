//
//  HistoryTableViewCell.swift
//  Pospane
//
//  Created by Karol Stępień on 25.08.2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    

    func configure(withSession session: Session) {
        let timeFormatter = Helpers().dateFormatterForTimeLabels()
        let dateFormatter = Helpers().dateFormatterForCellLabels()
        guard let asleepSession = session.asleep else { return }
        guard let awakeSession = session.awake else { return }
        let asleep = NSKeyedUnarchiver.unarchiveObject(with: asleepSession) as? [Date]
        let awake = NSKeyedUnarchiver.unarchiveObject(with: awakeSession) as? [Date]
        
        guard let firstAsleep = asleep?.first else { return }
        guard let lastAwake = awake?.last else { return }
        
        let unitFlags: Set<Calendar.Component> = [.hour, .minute]
        let components = Calendar.current.dateComponents(unitFlags, from: firstAsleep, to: lastAwake)
        
        if let creationDate = session.creationDate {
            titleLabel.text = dateFormatter.string(from: creationDate)
        }
        
        if components.hour == 0 {
            durationLabel.text = "\(components.minute ?? 0)m"
        } else {
            durationLabel.text = "\(components.hour ?? 0)h \(components.minute ?? 0)m"
        }
        
        fromLabel.text = timeFormatter.string(from: firstAsleep)
        toLabel.text = timeFormatter.string(from: lastAwake)
    }
}
