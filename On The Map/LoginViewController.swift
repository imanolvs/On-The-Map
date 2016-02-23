//
//  ViewController.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        let x = self.view.center.x
        let y = CGFloat(self.view.frame.height - 100)
        fbLoginButton.center = CGPoint(x: x, y: y)
        self.view.addSubview(fbLoginButton)
        
        //If user is already login with facebook...
        tryToLogInWithFacebook()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Facebook Login Button Delegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else {
            print("Facebook Log In Error")
            return
        }
        tryToLogInWithFacebook()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        else
        {
            textField.resignFirstResponder()
        }
        
        return true
    }

    // MARK: Log in Functions
    
    @IBAction func loginAction(sender: UIButton) {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startActivityIndicator(activityIndicator)
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            showAlertMessage("Empty Email and/or Password")
            stopActivityIndicator(activityIndicator)
        }
        else {
            UdacityClient.sharedInstance().createSession(usernameTextField.text!, password: passwordTextField.text!) {
                (success, error) in
                guard success == true else {
                    if error == "There was an error with your request" {
                        performUIUpdatesOnMain {
                            self.stopActivityIndicator(activityIndicator)
                            self.showAlertMessage("Connection Error. Please, check your connection and try later")
                        }
                        
                    }
                    else {
                        performUIUpdatesOnMain {
                            self.stopActivityIndicator(activityIndicator)
                            self.showAlertMessage("Invalid Email and/or Password")
                        }
                    }
                    return
                }
                
                print("Succesfully logged in")
                performUIUpdatesOnMain {
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MapTabController") as! UITabBarController
                                
                    self.stopActivityIndicator(activityIndicator)
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func accountSignUp(sender: UIButton) {
        let url = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func tryToLogInWithFacebook() {
        guard FBSDKAccessToken.currentAccessToken() != nil else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startActivityIndicator(activityIndicator)
        
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        UdacityClient.sharedInstance().createSessionWithFacebook(accessToken) { (success, error) in
            guard success == true else {
                print(error)
                performUIUpdatesOnMain {
                    self.showAlertMessage("Could not log in. Please, try again.")
                    self.stopActivityIndicator(activityIndicator)
                }
                return
            }
            
            print("Succesfully logged in")
            performUIUpdatesOnMain {
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MapTabController") as! UITabBarController
                
                self.stopActivityIndicator(activityIndicator)
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }

    }
    
}

