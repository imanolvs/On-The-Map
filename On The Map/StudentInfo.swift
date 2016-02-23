//
//  StudentInfo.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

struct StudentInfo {
    
    // MARK: Properties
    var firstName : String
    var lastName : String
    var objectID : String?
    var uniqueKey : String!
    var mapString : String
    var mediaURL : String
    var latitude : Double
    var longitude : Double
    var createdAt : NSDate
    var updatedAt : NSDate
    
    // MARK: Init
    init(dictionary: [String : AnyObject]) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        firstName = dictionary[ParseClient.JSONKeys.FirstName] as! String
        lastName = dictionary[ParseClient.JSONKeys.LastName] as! String
        objectID = dictionary[ParseClient.JSONKeys.ObjectID] as? String
        uniqueKey = dictionary[ParseClient.JSONKeys.UniqueKey] as! String
        mapString = dictionary[ParseClient.JSONKeys.MapString] as! String
        mediaURL = dictionary[ParseClient.JSONKeys.MediaURL] as! String
        latitude = dictionary[ParseClient.JSONKeys.Latitude] as! Double
        longitude = dictionary[ParseClient.JSONKeys.Longitude] as! Double
        createdAt = dateFormatter.dateFromString(dictionary[ParseClient.JSONKeys.CreatedAt] as! String)!
        updatedAt = dateFormatter.dateFromString(dictionary[ParseClient.JSONKeys.UpdatedAt] as! String)!
    }
    
    static func StudentFromDictionary(dictionaryArray: [[String:AnyObject]]) -> [StudentInfo] {
        var studentArray = [StudentInfo]()
        
        for value in dictionaryArray {
            studentArray.append(StudentInfo(dictionary: value))
        }
        
        return studentArray
    }
    
}