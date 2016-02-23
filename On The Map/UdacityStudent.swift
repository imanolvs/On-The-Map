//
//  UdacityStudent.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 21/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct UserInfo
    {
        static var UniqueKey : String!
        static var LastName : String!
        static var FirstName : String!
        static var MediaURL : String!
        static var MapString : String!
        static var Latitude : Double!
        static var Longitude : Double!
        static var UpdatedAt : String!
        static var ObjectId : String!
        static var CreatedAt : String!
    }
    
    func fillUserInfo(student: StudentInfo)
    {
        UserInfo.FirstName = student.firstName
        UserInfo.LastName = student.lastName
        UserInfo.MediaURL = student.mediaURL
        UserInfo.MapString = student.mapString
        UserInfo.Latitude = student.latitude
        UserInfo.Longitude = student.longitude
        UserInfo.UpdatedAt = String(student.updatedAt)
        UserInfo.CreatedAt = String(student.createdAt)
        UserInfo.ObjectId = student.objectID
        UserInfo.UniqueKey = student.uniqueKey
    }
}