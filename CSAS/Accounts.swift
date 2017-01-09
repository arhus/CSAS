//
//  Accounts.swift
//  CSAS
//
//  Created by Kuba on 09/01/2017.
//  Copyright © 2017 Kuba. All rights reserved.
//

import Foundation
import Alamofire

class Accounts {
  var name: String?
  var accountNumber: String?
  var bankCode: Int?
  var transparencyFrom: String?
  var transparencyTo: String?
  var publicationTo: String?
  var actualizationDate: String?
  var balance: Double?
  var currency: String?
  var iban: String?
  
  required init(json: [String: Any]) {
    self.name = json[AccountFields.name.rawValue] as? String
    self.accountNumber = json[AccountFields.accountNumber.rawValue] as? String
    self.balance = json[AccountFields.balance.rawValue] as? Double
  }
  
  // MARK: Accounts
  class func accounts() -> String {
    return "https://api.csas.cz/sandbox/webapi/api/v2/transparentAccounts"
  }
  
  fileprivate class func getAccountAtPath(_ path: String, completionHandler: @escaping (Result<AccountWrapper>) -> Void) {
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
        "WEB-API-key": "35bd5a35-5909-460e-b3c2-20073d9c4c2e"
    ]
    
    let _ = Alamofire.request(url, headers: headers)
      .responseJSON { response in
        if let error = response.result.error {
          completionHandler(.failure(error))
          return
        }
        let accountsWrapperResult = Accounts.accountArrayFromResponse(response)
        completionHandler(accountsWrapperResult)
    }
  }
  
  class func getAccounts(_ completionHandler: @escaping (Result<AccountWrapper>) -> Void) {
    getAccountAtPath(Accounts.accounts(), completionHandler: completionHandler)
  }
  
  class func getMoreAccounts(_ wrapper: AccountWrapper?, completionHandler: @escaping (Result<AccountWrapper>) -> Void) {
    guard let nextURL = wrapper?.next else {
      let error = BackendError.objectSerialization(reason: "Did not get wrapper for more accounts")
      completionHandler(.failure(error))
      return
    }
    getAccountAtPath(nextURL, completionHandler: completionHandler)
  }
  
  private class func accountArrayFromResponse(_ response: DataResponse<Any>) -> Result<AccountWrapper> {
    guard response.result.error == nil else {
      print(response.result.error!)
      return .failure(response.result.error!)
    }
    
    guard let json = response.result.value as? [String: Any] else {
      return .failure(BackendError.objectSerialization(reason: "Did not get JSON"))
    }
    
    let wrapper = AccountWrapper()
    if let nextPageNumber = json["nextPage"] as? Int{
        let url = "https://api.csas.cz/sandbox/webapi/api/v2/transparentAccounts?page=\(nextPageNumber)"
        wrapper.next = url
        print(url)
    }
    wrapper.count = json["recordCount"] as? Int
    
    var allAccounts: [Accounts] = []
    if let results = json["accounts"] as? [[String: Any]] {
      for jsonAccounts in results {
        let accounts = Accounts(json: jsonAccounts)
        allAccounts.append(accounts)
      }
    }
    wrapper.accounts = allAccounts
    return .success(wrapper)
  }
}
