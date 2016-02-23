//
//  ViewControllerExtension.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 20/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import FBSDKLoginKit

extension UIViewController {

    func showAlertMessage(string: String) {
        let alert = UIAlertController(title: nil, message: string, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.title = ""
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showOverwriteUserAlert(username: String) {
        let title = "User \(username) has already posted a student location. Would you Like to Overwrite their location?"
        let alert = UIAlertController(title: nil, message: title, preferredStyle: .Alert)
        
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { (action) in
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostingViewController") as! PostingViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(overwriteAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.alpha = 0.4
        
    }
    
    func stopActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        view.alpha = 1
    }
    
    func logOutFromUdacityAndFacebook() {
        FBSDKLoginManager().logOut()
        
        UdacityClient.sharedInstance().deleteSession() { (results, error) in
            // MARK: Error trying logging out -> Do nothing
            guard let _ = error else {
                print("error: Could not log out")
                return
            }
            
            // MARK: Session is closed. Go to log in screen
            performUIUpdatesOnMain {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}