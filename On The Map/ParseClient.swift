//
//  ParseClient.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance () -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
 
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (result: [[String:AnyObject]]?, error: String?) -> Void) -> NSURLSessionDataTask {
 
        let components = NSURLComponents(string: ParseClient.Constants.MethodURL)!
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        let request = NSMutableURLRequest(URL: (components.URL)!)
        request.addValue(ParseClient.Constants.ParseApi, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RestApi, forHTTPHeaderField: "X-Parse-REST-API-Key")

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
            
            /* Parse the data and use the data (happens in completion handler) */
            self.convertGETDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(jsonBody: String, completionHandlerForPOST: (result: [String:AnyObject]?, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: ParseClient.Constants.MethodURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue(ParseClient.Constants.ParseApi, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RestApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            self.convertPOSTPUTDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(objectID: String, jsonBody: String, completionHandlerForPUT: (result: [String:AnyObject]?, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: (ParseClient.Constants.MethodURL + objectID))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(ParseClient.Constants.ParseApi, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RestApi, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(error: String) {
                completionHandlerForPUT(result: nil, error: error)
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
            
            /* Parse the data and use the data (happens in completion handler) */
            self.convertPOSTPUTDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    private func convertGETDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: [[String:AnyObject]]?, error: String?) -> Void) {
        
        var parsedResult: [String: AnyObject]!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject]
        } catch {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
        }
        
        guard let response = parsedResult[ParseClient.JSONKeys.Results] as? [[String:AnyObject]] else {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
            return
        }

        completionHandlerForConvertData(result: response, error: nil)
    }

    private func convertPOSTPUTDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: [String:AnyObject]?, error: String?) -> Void) {
        
        var parsedResult: [String: AnyObject]!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject]
        } catch {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
        }
        
        guard let response = parsedResult[ParseClient.JSONKeys.Results] as? [String:AnyObject] else {
            completionHandlerForConvertData(result: nil, error: "Could not parse the data as JSON: '\(data)'")
            return
        }
        
        completionHandlerForConvertData(result: response, error: nil)
    }

}

extension ParseClient {
    
    func getStudentLocation(limit: Int!, skip: Int!, order: String?, complentionHandler: (result: [StudentInfo]?, error: String?) -> Void) {
        var parameters = [String:AnyObject]()
        if limit != nil {
            parameters[ParseClient.ParameterKeys.Limit] = "\(limit)"
            if skip != nil {
                parameters[ParseClient.ParameterKeys.Skip] = "\(skip)"
            }
        }
        if order != nil {
            parameters[ParseClient.ParameterKeys.Order] = order
        }

        taskForGETMethod(parameters) { (results, error) in
            guard error == nil else {
                complentionHandler(result: nil, error: error)
                return
            }
            
            let students = StudentInfo.StudentFromDictionary(results!)
            complentionHandler(result: students, error: nil)
        }
    }
    
    func postStudentLocation(completionHandler: (result: [String:AnyObject]?, error: String?) -> Void) {
        
        let jsonBody = "{\"\(ParseClient.JSONKeys.UniqueKey)\": \"\(UdacityClient.UserInfo.UniqueKey)\", \"\(ParseClient.JSONKeys.FirstName)\": \"\(UdacityClient.UserInfo.FirstName)\", \"\(ParseClient.JSONKeys.LastName)\": \"\(UdacityClient.UserInfo.LastName)\",\"\(ParseClient.JSONKeys.MapString)\": \"\(UdacityClient.UserInfo.MapString)\", \"\(ParseClient.JSONKeys.MediaURL)\": \"\(UdacityClient.UserInfo.MediaURL)\",\"\(ParseClient.JSONKeys.Latitude)\": \(UdacityClient.UserInfo.Latitude), \"\(ParseClient.JSONKeys.Longitude)\": \(UdacityClient.UserInfo.Longitude)}"
        
        taskForPOSTMethod(jsonBody) { (results, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }
            
            completionHandler(result: results, error: nil)
        }
    }
    
    func updateStudentLocation(completionHandler: (result: [String:AnyObject]?, error: String?) -> Void) {
        let jsonBody = "{\"\(ParseClient.JSONKeys.UniqueKey)\": \"\(UdacityClient.UserInfo.UniqueKey)\", \"\(ParseClient.JSONKeys.FirstName)\": \"\(UdacityClient.UserInfo.FirstName)\", \"\(ParseClient.JSONKeys.LastName)\": \"\(UdacityClient.UserInfo.LastName)\",\"\(ParseClient.JSONKeys.MapString)\": \"\(UdacityClient.UserInfo.MapString)\", \"\(ParseClient.JSONKeys.MediaURL)\": \"\(UdacityClient.UserInfo.MediaURL)\",\"\(ParseClient.JSONKeys.Latitude)\": \(UdacityClient.UserInfo.Latitude), \"\(ParseClient.JSONKeys.Longitude)\": \(UdacityClient.UserInfo.Longitude)}"

        let objectID = "/\(UdacityClient.UserInfo.ObjectId)"
        taskForPUTMethod(objectID, jsonBody: jsonBody) { (results, error) in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }

            completionHandler(result: results, error: nil)
        }
    }
    
    func queryStudentInfo(uniqueKey: String, completionHandler: (student: StudentInfo?, error: String?) -> Void) {
        var parameters = [String:AnyObject]()
        
        parameters[ParseClient.ParameterKeys.Where] = "{\"\(ParseClient.JSONKeys.UniqueKey)\":\"\(uniqueKey)\"}"
        
        taskForGETMethod(parameters) { (results, error) in
            guard error == nil else {
                completionHandler(student: nil, error: error)
                return
            }
            
            let students = StudentInfo.StudentFromDictionary(results!)
            completionHandler(student: students[0], error: nil)
        }
    }
}


