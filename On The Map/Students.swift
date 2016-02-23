//
//  Students.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 23/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

class Students {
    
    var students : [StudentInfo] = [StudentInfo]()
    
    class  func sharedInstance() -> Students
    {
        struct Singleton
        {
            static var sharedInstance = Students()
        }
        return Singleton.sharedInstance
    }
}