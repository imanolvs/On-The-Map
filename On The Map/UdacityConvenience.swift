//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func createSession(username: String, password: String, completionHandler: (success: Bool, error: String?) -> Void) {
        // MARK: Build JSON Body
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(username)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        // MARK: Do the request
        taskForPOSTMethod(jsonBody) { (results, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            // MARK: Get and return the UserID if possible
            if let dictionary = results[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] {
                if let userID = dictionary[UdacityClient.JSONResponseKeys.AccountKey] as? String {
                    self.getUserData(userID) { (result, error) in
                        guard error == nil else {
                            completionHandler(success: false, error: error)
                            return
                        }
                        
                        UserInfo.UniqueKey = userID
                        UserInfo.FirstName = result![UdacityClient.JSONResponseKeys.UserFirstName] as! String
                        UserInfo.LastName = result![UdacityClient.JSONResponseKeys.UserLastName] as! String
                    }
                }
                
                completionHandler(success: true, error: nil)
                
            } else {
                completionHandler(success: false, error: "error: Could not parse the data")
            }
        }
    }
    
    func deleteSession(completionHandler: (result: String?, error: String?) -> Void) {
        
        // MARK: This method don't need parameters. Do the request
        self.taskForDELETEMethod() { (results, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            // MARK: Get and return the SessionID if possible
            if let dictionary = results[UdacityClient.JSONResponseKeys.Session] as? [String:AnyObject] {
                if let sessionID = dictionary[UdacityClient.JSONResponseKeys.SessionID] as? String {
                    completionHandler(result: sessionID, error: nil)
                }
                else {
                    completionHandler(result: nil, error: "error: Could not parse the data")
                }
            } else {
                completionHandler(result: nil, error: "error: Could not parse the data")
            }
        }
    }
    
    func getUserData(userId: String, completionHandler: (result: [String:AnyObject]?, error: String?) -> Void) {
        
        self.taskForGETMethod(userId) { (results, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }

            // MARK: Get and return the User information
            if let dictionary = results[UdacityClient.JSONResponseKeys.User] as? [String:AnyObject] {
                completionHandler(result: dictionary, error: nil)
            }
            else {
                completionHandler(result: nil, error: "error: Could not parse the data")
            }
            
        }
    }
    
    func createSessionWithFacebook(acessToken: String, completionHandler: (success: Bool, error: String?) -> Void ) {
        // MARK: Build JSON Body
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Facebook)\": {\"\(UdacityClient.JSONBodyKeys.AccessToken)\": \"\(acessToken)\"}}"
        
        // MARK: Do the request
        taskForPOSTMethod(jsonBody) { (results, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            
            // MARK: Get and return the UserID if possible
            if let dictionary = results[UdacityClient.JSONResponseKeys.Account] as? [String:AnyObject] {
                if let userID = dictionary[UdacityClient.JSONResponseKeys.AccountKey] as? String {
                    self.getUserData(userID) { (result, error) in
                        guard error == nil else {
                            completionHandler(success: false, error: error)
                            return
                        }
                        
                        UserInfo.UniqueKey = userID
                        UserInfo.FirstName = result![UdacityClient.JSONResponseKeys.UserFirstName] as! String
                        UserInfo.LastName = result![UdacityClient.JSONResponseKeys.UserLastName] as! String
                    }
                }
                
                completionHandler(success: true, error: nil)
                
            } else {
                completionHandler(success: false, error: "error: Could not parse the data")
            }
        }
    }
    
    
}



