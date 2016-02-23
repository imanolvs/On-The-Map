//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import Foundation

// MARK: UdacityClient (Constants)

extension UdacityClient {

    // MARK: Constants
    struct Constants {
        // MARK: Udacity Facebook App ID
        static let FacebookID = "365362206864879"
        
        // MARK: URLs
        static let ApiURL = "https://www.udacity.com/api"
    }
    
    // MARK: Methods
    struct Methods {
        static let SessionMethod = "/session"
        static let UserData = "/users"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let Facebook = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct JSONResponseKeys {
        // MARK: Session
        static let Session = "session"
        static let SessionID = "id"
        static let Expiration = "expiration"
        
        // MARK: Account
        static let Account = "account"
        static let Registered = "registered"
        static let AccountKey = "key"
        
        // MARK: User Data
        static let User = "user"
        static let UserLastName = "last_name"
        static let UserSocialAcc = "social_accounts"
        static let UserMailAddr = "mailing_address"
        static let UserSignature = "_signature"
        static let UserFirstName = "first_name"
        static let UserWebSite = "website_url"
        static let UserLinkedin = "linkedin_url"
        static let UserImage = "_image_url"
    }
}