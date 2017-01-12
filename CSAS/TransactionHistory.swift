//
//  TransactionHistory.swift
//  CSAS
//
//  Created by Kuba on 10/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import Foundation
import Alamofire

class TransactionHistory {
	var amount: [String: Any] = [:]
    var type: String?
    var dueDate: String?
    var processingDate: String?
    var sender: [String: Any] = [:]
    
    required init(json: [String: Any]) {
		self.amount = json[TransactionHistoryFields.amount.rawValue] as? [String: Any] ?? [:]
        self.type = json[TransactionHistoryFields.type.rawValue] as? String
        self.dueDate = json[TransactionHistoryFields.dueDate.rawValue] as? String
        self.processingDate = json[TransactionHistoryFields.processingDate.rawValue] as? String
        self.sender = json[TransactionHistoryFields.sender.rawValue] as? [String: Any] ?? [:]
    }
    
    // MARK: Transaction history
    class func transactions(_ accountNumber: String, _ page: String) -> String {
        return "https://api.csas.cz/sandbox/webapi/api/v2/transparentAccounts/\(accountNumber)/transactions?page=\(page)"
    }
    
    fileprivate class func requestTransactionHistory(accountNumber: String, page: String, completionHandler: @escaping (Result<TransactionHistoryWrapper>) -> Void) {
        let path = TransactionHistory.transactions(accountNumber, page)
        print(path)
        guard var urlComponents = URLComponents(string: path) else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        urlComponents.scheme = "https"
        guard let url = try? urlComponents.asURL() else {
            let error = BackendError.urlError(reason: "Tried to load an invalid URL")
            completionHandler(.failure(error))
            return
        }
        
        let headers = [
            "WEB-API-key": WEBAPIkey
        ]
        
        let _ = Alamofire.request(url, headers: headers)
            .responseJSON { response in
                if let error = response.result.error {
                    completionHandler(.failure(error))
                    return
                }
                
                let wrapperResult = TransactionHistory.historyArrayFromResponse(accountNumber: accountNumber, response)
                completionHandler(wrapperResult)
        }
    }
    
    class func getTransactionHistory(accountNumber: String, _ completionHandler: @escaping (Result<TransactionHistoryWrapper>) -> Void) {
        requestTransactionHistory(accountNumber: accountNumber, page: "0", completionHandler: completionHandler)
    }
    
    class func getMoreTransactionHistory(accountNumber: String, _ wrapper: TransactionHistoryWrapper?, completionHandler: @escaping (Result<TransactionHistoryWrapper>) -> Void) {
        guard let nextURL = wrapper?.next else {
            let error = BackendError.objectSerialization(reason: "Did not get wrapper for more transaction history")
            completionHandler(.failure(error))
            return
        }
        requestTransactionHistory(accountNumber: accountNumber, page: nextURL, completionHandler: completionHandler)
    }
    
    private class func historyArrayFromResponse(accountNumber: String, _ response: DataResponse<Any>) -> Result<TransactionHistoryWrapper> {
		if let error = response.result.error {
			print(error)
			return .failure(error)
		}
		
        guard let json = response.result.value as? [String: Any] else {
            return .failure(BackendError.objectSerialization(reason: "Did not get JSON"))
        }
        
        let wrapper = TransactionHistoryWrapper()
        if let nextPageNumber = json["nextPage"] as? Int {
            wrapper.next = String(nextPageNumber)
        }
        wrapper.count = json["recordCount"] as? Int
        
        var allHistoryTransactions: [TransactionHistory] = []
        if let results = json["transactions"] as? [[String: Any]] {
            for jsonHistory in results {
                let history = TransactionHistory(json: jsonHistory)
                allHistoryTransactions.append(history)
            }
        }
        wrapper.transactions = allHistoryTransactions
        return .success(wrapper)
    }
}
