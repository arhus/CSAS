//
//  AccountDetailTableViewController.swift
//  CSAS
//
//  Created by Kuba on 10/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import UIKit

class AccountDetailTableViewController: UITableViewController {

    var accountDetail: Accounts!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TransactionHistoryTableViewController
        destinationVC.accountNumber = accountDetail.accountNumber
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = accountDetail.name
        case 1:
            cell.textLabel?.text = "Account number"
            cell.detailTextLabel?.text = accountDetail.accountNumber
        case 2:
            cell.textLabel?.text = "Bank code"
            cell.detailTextLabel?.text = accountDetail.bankCode
        case 3:
            cell.textLabel?.text = "Transparency from"
            cell.detailTextLabel?.text = accountDetail.transparencyFrom
        case 4:
            cell.textLabel?.text = "Transparency to"
            cell.detailTextLabel?.text = accountDetail.transparencyTo
        case 5:
            cell.textLabel?.text = "Publication to"
            cell.detailTextLabel?.text = accountDetail.publicationTo
        case 6:
            cell.textLabel?.text = "Actualization date"
            cell.detailTextLabel?.text = accountDetail.actualizationDate
        case 7:
            cell.textLabel?.text = "Balance"
            if let balance = accountDetail.balance, let currency = accountDetail.currency {
                cell.detailTextLabel?.text = "\(String(format:"%.2f", balance)) \(currency)"
            }
        case 8:
            cell.textLabel?.text = "IBAN"
            cell.detailTextLabel?.text = accountDetail.iban
        default:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Show transaction history"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 9 {
            self.performSegue(withIdentifier: "showTransactionHistory", sender: nil)
        }
    }
}
