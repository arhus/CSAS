//
//  TransparentAccountsTableViewController.swift
//  CSAS
//
//  Created by Kuba on 09/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import UIKit

class TransparentAccountsTableViewController: UITableViewController {

    var accounts: [Accounts] = []
    var accountsWrapper: AccountWrapper?
    var isLoadingAccounts = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFirstAccounts()
    }
    
    func loadFirstAccounts() {
        isLoadingAccounts = true
        Accounts.getAccounts { result in
            if result.error != nil {
                self.isLoadingAccounts = false
                print("Error while loading first accounts")
            }
            let accountsWrapper = result.value
            self.addAccountsFromWrapper(accountsWrapper)
            self.isLoadingAccounts = false
            self.tableView.reloadData()
        }
    }
    
    func loadMoreAccounts() {
        isLoadingAccounts = true
        guard let wrapper = accountsWrapper,
			  let totalAccountsCount = wrapper.count,
			  accounts.count < totalAccountsCount else { return }
		
		Accounts.getMoreAccounts(accountsWrapper) { result in
			if result.error != nil {
				self.isLoadingAccounts = false
				print("Could not load more accounts")
			}
			let moreWrapper = result.value
			self.addAccountsFromWrapper(moreWrapper)
			self.isLoadingAccounts = false
			self.tableView.reloadData()
		}
    }
    
    func addAccountsFromWrapper(_ wrapper: AccountWrapper?) {
        accountsWrapper = wrapper
		
		if let accountsWrapper = accountsWrapper, let newAccounts = accountsWrapper.accounts {
			accounts += newAccounts
		}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AccountDetailTableViewController
        destinationVC.accountDetail = sender as? Accounts
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if accounts.count >= indexPath.row {
            let account = accounts[indexPath.row]
            cell.textLabel?.text = account.name
            cell.detailTextLabel?.text = String(format:"%.2f", account.balance!)
            
            // Check if we need to load more accounts
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = accounts.count
            if (!isLoadingAccounts && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                let totalRows = accountsWrapper!.count!
                let remainingAccountsToLoad = totalRows - rowsLoaded;
                if (remainingAccountsToLoad > 0) {
                    loadMoreAccounts()
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        
        Accounts.getAccountDetails(accountNumber: account.accountNumber!) { result in
            tableView.deselectRow(at: indexPath, animated: true)
            if result.error != nil {
                self.isLoadingAccounts = false
                print("Error while loading account details")
            }
            let accountDetail = result.value
            self.performSegue(withIdentifier: "showDetail", sender: accountDetail)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Accounts loaded: \(accounts.count)"
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
    }

}
