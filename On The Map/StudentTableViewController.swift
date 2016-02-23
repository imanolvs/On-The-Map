//
//  StudentTableViewController.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit

class StudentTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loadStudents()
        tableView.reloadData()
    }
    
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedInstance().students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell")! as UITableViewCell
        
        cell.textLabel?.text = Students.sharedInstance().students[indexPath.row].firstName + " " + Students.sharedInstance().students[indexPath.row].lastName
        cell.detailTextLabel?.text = Students.sharedInstance().students[indexPath.row].mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let urlString = cell?.detailTextLabel?.text
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: urlString!)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: urlString!)!)
        }
        else {
            self.showAlertMessage("Invalid URL")
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func postNewStudentInfo(sender: UIBarButtonItem) {
        ParseClient.sharedInstance().queryStudentInfo(UdacityClient.UserInfo.UniqueKey!) { (student, error) in
            guard error == nil else {
                print(error)
                return
            }
            
            UdacityClient.sharedInstance().fillUserInfo(student!)
        }
        let username = UdacityClient.UserInfo.FirstName + " " + UdacityClient.UserInfo.LastName
        showOverwriteUserAlert(username)
    }

    @IBAction func refreshStudentList(sender: UIBarButtonItem) {
        loadStudents()
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
       logOutFromUdacityAndFacebook()
    }
}


extension StudentTableViewController {
    
    private func loadStudents() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startActivityIndicator(activityIndicator)
        let limit = 100
        
        ParseClient.sharedInstance().getStudentLocation(limit, skip: nil, order: "-updatedAt") { (results, error) in
            guard error == nil else {
                print("Could not get Students Location")
                performUIUpdatesOnMain{
                    self.showAlertMessage("An error ocurrs loading the Students List. Please, refresh the list!")
                    self.stopActivityIndicator(activityIndicator)
                }
                return
            }
            
            Students.sharedInstance().students = results!
            
            performUIUpdatesOnMain {
                self.tableView.reloadData()
                self.stopActivityIndicator(activityIndicator)
            }
        }
    }
}
