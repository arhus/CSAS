//
//  TransactionsTableViewCell.swift
//  CSAS
//
//  Created by Kuba on 11/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var precision: UILabel!
    @IBOutlet weak var currency: UILabel!
    
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var accountNumber: UILabel!
}
