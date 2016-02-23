//
//  PostingViewController.swift
//  On The Map
//
//  Created by Imanol Viana Sánchez on 20/2/16.
//  Copyright © 2016 Imanol Viana Sánchez. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var upLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var search: MKLocalSearch!
    var searchResponse: MKLocalSearchResponse!
    var searchRequest: MKLocalSearchRequest!
    
    var studentInfo: StudentInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        infoTextView.delegate = self
        
        findButton.layer.cornerRadius = 5
        findButton.layer.borderWidth = 1
        findButton.titleLabel?.textAlignment = .Center
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.titleLabel?.textAlignment = .Center

        findButton.hidden = false
        submitButton.hidden = true

        mapView.hidden = true
        mapView.zoomEnabled = false
    }
    
    // MARK: textView Delegate
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
        textView.textAlignment = .Left
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.textAlignment = .Center
        if textView.text == ""
        {
            if findButton.hidden == false {
                textView.text = "Enter Your Location Here"
            } else {
                textView.text = "Enter a Link to Share Here"
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if (text.rangeOfString("\n") != nil) {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func markLocationOnMap(completionHandler: (success: Bool, error: String?) -> Void) {
        searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = locationTextView.text
        search = MKLocalSearch(request: searchRequest)
        
        search.startWithCompletionHandler() { (response, error) in

            guard response != nil else {
                completionHandler(success: false, error: "Could not mark the specified location on map")
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = self.locationTextView.text
            UdacityClient.UserInfo.MapString = self.locationTextView.text
            UdacityClient.UserInfo.Latitude = response!.boundingRegion.center.latitude
            UdacityClient.UserInfo.Longitude = response!.boundingRegion.center.longitude
            annotation.coordinate = CLLocationCoordinate2D(latitude: response!.boundingRegion.center.latitude, longitude: response!.boundingRegion.center.longitude)
            
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            let region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(2, 2))
            
            performUIUpdatesOnMain {
                self.mapView.addAnnotation(annotationView.annotation!)
                self.mapView.centerCoordinate = annotation.coordinate
                self.mapView.setRegion(region, animated: true)
            }

            completionHandler(success: true, error: nil)
        }
    }
    
    //MARK: Button Actions
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitUserInfo(sender: UIButton) {
        
        guard self.infoTextView.text != "Enter a Link to Share Here" else {
            showAlertMessage("Must Enter a Link")
            return
        }
        
        UdacityClient.UserInfo.MediaURL = self.infoTextView.text
        if UdacityClient.UserInfo.ObjectId == nil {
            ParseClient.sharedInstance().postStudentLocation() { (result, error) in
                guard error == nil else {
                    performUIUpdatesOnMain { self.showAlertMessage("It was an error submitting your information. Please, try again") }
                    return
                }
                UdacityClient.UserInfo.CreatedAt = result![ParseClient.JSONKeys.CreatedAt] as! String
                UdacityClient.UserInfo.ObjectId = result![ParseClient.JSONKeys.ObjectID] as? String
            }
        }
        else {
            ParseClient.sharedInstance().updateStudentLocation() {
                (result, error) in
                guard error == nil else {
                    performUIUpdatesOnMain { self.showAlertMessage("It was an error submitting your information. Please, try again") }
                    return
                }
                
                if let updateAt = result![ParseClient.JSONKeys.UpdatedAt] as? String
                {
                    UdacityClient.UserInfo.UpdatedAt = updateAt
                }
            }
        }
        performUIUpdatesOnMain { self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        
        // TODO: Activity Indicator works?
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        startActivityIndicator(activityIndicator)
        self.view.alpha = 0.4
        
        markLocationOnMap() { (success, error) in
            guard success == true else {
                print(error)
                performUIUpdatesOnMain { self.showAlertMessage("Could Not Geocode the String") }
                return
            }
            
            self.locationTextView.hidden = true
            self.infoTextView.hidden = false
            self.upLabel.hidden = true
            self.middleLabel.hidden = true
            self.downLabel.hidden = true
            self.mapView.hidden = false
            self.findButton.hidden = true
            self.submitButton.hidden = false
        }
        stopActivityIndicator(activityIndicator)
        self.view.alpha = 1
    }
}
