//
//  Account.swift
//  CSAS
//
//  Created by Kuba on 09/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import Foundation

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

// MARK: Accounts

enum AccountFields: String {
    case name = "name"
    case accountNumber = "accountNumber"
    case bankCode = "bankCode"
    case transparencyFrom = "transparencyFrom"
    case transparencyTo = "transparencyTo"
    case publicationTo = "publicationTo"
    case actualizationDate = "actualizationDate"
    case balance = "balance"
    case currency = "currency"
    case iban = "iban"
}

class AccountWrapper {
    var accounts: [Accounts]?
    var count: Int?
    var next: String?
}

// MARK: Transaction history

enum TransactionHistoryFields: String {
    case amount = "amount"
    case type = "type"
    case dueDate = "dueDate"
    case processingDate = "processingDate"
    case sender = "sender"
}

class TransactionHistoryWrapper {
    var history: [TransactionHistory]?
    var count: Int?
    var next: String?
}
