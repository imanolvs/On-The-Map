//
//  MapViewController.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 19/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController : UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var studentInfo: [StudentInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
   
        clearMapAnnotations()
        loadStudents()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView
        {
            let urlString = view.annotation?.subtitle!
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: urlString!)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: urlString!)!)
            }
            else {
                showAlertMessage("Invalid URL")
            }
        }
    }
    
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
        clearMapAnnotations()
        loadStudents()
    }
    
    @IBAction func logoutAction(sender: UIBarButtonItem) {
        logOutFromUdacityAndFacebook()
    }
}

extension MapViewController {
    
    private func addStudentsToMap() {
        
        var annotations = [MKPointAnnotation]()
        for student in studentInfo {
            let lat = CLLocationDegrees(student.latitude)
            let lon = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }

        self.mapView.addAnnotations(annotations)
    }

    private func clearMapAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    private func loadStudents() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startActivityIndicator(activityIndicator)
        self.mapView.alpha = 0.4
        let limit = 100
        
        ParseClient.sharedInstance().getStudentLocation(limit, skip: nil, order: "-updatedAt") { (results, error) in
            guard error == nil else {
                print("Could not get Students Location")
                performUIUpdatesOnMain {
                    self.showAlertMessage("An error ocurrs loading the Students List. Please, refresh the list!")
                    self.stopActivityIndicator(activityIndicator)
                }
                return
            }
                
            self.studentInfo = results!
            performUIUpdatesOnMain {
                self.addStudentsToMap()
                self.mapView.alpha = 1
                self.stopActivityIndicator(activityIndicator)
            }
        }
    }
}