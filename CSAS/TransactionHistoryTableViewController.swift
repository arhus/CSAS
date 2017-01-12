//
//  TransactionHistoryTableViewController.swift
//  CSAS
//
//  Created by Kuba on 11/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import UIKit

class TransactionHistoryTableViewController: UITableViewController {

    var accountNumber: String!
    var transactions: [TransactionHistory] = []
    var transactionWrapper: TransactionHistoryWrapper?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstTransactions()
    }

    func loadFirstTransactions() {
        isLoading = true
        TransactionHistory.getTransactionHistory(accountNumber: accountNumber) { result in
            if result.error != nil {
                self.isLoading = false
                print("Error while loading first accounts")
            }
            let transactionWrapper = result.value
            self.addTransactionsFromWrapper(transactionWrapper)
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
    
    func loadMoreTransactions() {
        isLoading = true
        if let wrapper = transactionWrapper,
            let totalAccountsCount = wrapper.count,
            transactions.count < totalAccountsCount {
            TransactionHistory.getMoreTransactionHistory(accountNumber: accountNumber, wrapper) { result in
                if result.error != nil {
                    self.isLoading = false
                    print("Could not load more accounts")
                }
                let moreWrapper = result.value
                self.addTransactionsFromWrapper(moreWrapper)
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
    }
    
    func addTransactionsFromWrapper(_ wrapper: TransactionHistoryWrapper?) {
        transactionWrapper = wrapper
		if let transactionWrapper = transactionWrapper, let newTransaction = transactionWrapper.transactions {
			transactions += newTransaction
		}
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionsTableViewCell
		
		let transaction = transactions[indexPath.row]
		
		/*cell.textLabel?.text = transaction.dueDate
		cell.detailTextLabel?.text = transaction.processingDate*/
		cell.amount.text = String(transaction.amount["value"] as? Int ?? 0)
		
//            cell.currency.text = "Currency: \(transaction.amount?[\"currency\"] as! String?)"
		dump(transaction)
		
		// Check if we need to load more accounts
		let rowsToLoadFromBottom = 2;
		let rowsLoaded = transactions.count
		if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
			let totalRows = transactionWrapper!.count!
			let remainingAccountsToLoad = totalRows - rowsLoaded;
			if (remainingAccountsToLoad > 0) {
				loadMoreTransactions()
			}
		}
		
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = transactions[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions for: " + accountNumber
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }

}
