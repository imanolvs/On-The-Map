//
//  UdacityClient.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient
    {
        struct Singleton
        {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    // shared session
    var session: NSURLSession
        
    // MARK: Initializers

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    func taskForGETMethod(userId: String, completionHandlerForGET: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
    
        /* Build the URL. Configure the request */
        let urlString = Constants.ApiURL + Methods.UserData + "/\(userId)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                completionHandlerForGET(result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* Take the first 5 characters of data out */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            /* Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }

    func taskForPOSTMethod(jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        /* Build the URL. Configure the request */
        let urlString = Constants.ApiURL + Methods.SessionMethod
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
                
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                completionHandlerForPOST(result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            /* Take the first 5 characters of data out */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            /* Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }

    func taskForDELETEMethod(completionHandlerForDELETE: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        /* Build the URL. Configure the request */
        let urlString = Constants.ApiURL + Methods.SessionMethod
        let request = NSMutableURLRequest(URL: NSURL(fileURLWithPath: urlString))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                completionHandlerForDELETE(result: nil, error: error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* Take the first 5 characters of data out */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            /* Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: String?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject]
        } catch {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
        }
    
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
}


