//
//  ViewController.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var phraseSearchButton: UIButton!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latLonSearchButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phraseTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Constants.Selectors.KeyboardDidHide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Search Actions
    
    @IBAction func searchByPhrase(sender: AnyObject) {

        userDidTapView(self)
        setUIEnabled(false)
        
        if !phraseTextField.text!.isEmpty {
            photoTitleLabel.text = "Searching..."
            // TODO: Set necessary parameters!
            
            
            
            let methodParameters: [String: String!] = [
            
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.Text : phraseTextField.text,
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            
            ]
            
            displayImageFromFlickrBySearch(methodParameters)
        } else {
            setUIEnabled(true)
            photoTitleLabel.text = "Phrase Empty."
        }
    }
    
    @IBAction func searchByLatLon(sender: AnyObject) {
        
        
        
        
        
        
        

        userDidTapView(self)
        setUIEnabled(false)
        
        if isTextFieldValid(latitudeTextField, forRange: Constants.Flickr.SearchLatRange) && isTextFieldValid(longitudeTextField, forRange: Constants.Flickr.SearchLonRange) {
            photoTitleLabel.text = "Searching..."
            // TODO: Set necessary parameters!
//            let methodParameters: [String: String!] = [:]
            
            
            let methodParameters: [String: String!] = [
                
                Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                Constants.FlickrParameterKeys.BoundingBox:bboxString(),
                Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
                
            ]
            
            
            
            
            displayImageFromFlickrBySearch(methodParameters)
        }
        else {
            setUIEnabled(true)
            photoTitleLabel.text = "Lat should be [-90, 90].\nLon should be [-180, 180]."
        }
        
      
    }
    private func bboxString() -> String {
        
        if let latitude = Double(latitudeTextField.text!), let longitude = Double(longitudeTextField.text!){
            
            let minmumLon = max(longitude-(Constants.Flickr.SearchBBoxHalfWidth), Constants.Flickr.SearchLonRange.0)
            
            let minimuLat = max(latitude - (Constants.Flickr.SearchBBoxHalfHeight), Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximuLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            
            return "\(minmumLon),\(minimuLat),\(maximumLon),\(maximuLat)"
            
            
        }else {
            return "0,0,0,0"
        }
        
    }
    
    
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject]) {
        
        func displayError(error: String){
            print(error)
            print("URL at time of error: \(methodParameters)")
            performUIUpdatesOnMain(){
                self.setUIEnabled(true)
            }
        }
        
     
        
        
        
        // TODO: Make request to Flickr!
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        let task = session.dataTaskWithRequest(request){data, response, error in
        

            if error == nil {
                
                //did we get  a sucessful 2xx response
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                    where statusCode >= 200 && statusCode <= 299 else{
                        displayError("Your request returned a status code othter than 2xx!")
                        return
                }
                
                guard let data = data else {
                    
                    displayError("No data was returned by the request")
                    return
                }
                
                let parseResult: AnyObject!
                
                do{
                    parseResult = try NSJSONSerialization.JSONObjectWithData(data
                        , options: NSJSONReadingOptions.AllowFragments)
                    
                    
                }catch{
                    displayError("Could not parse the data as JSON: \(data)")
                    return
                }
                
                
                guard let status = parseResult[Constants.FlickrResponseKeys.Status] as? String where status == Constants.FlickrResponseValues.OKStatus else {
                    
                    displayError("Flickr API returned an erro. See error code and message in \(parseResult)")
                    return
                }
                
                guard let photoDictionary = parseResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    
                    displayError("Cannont find key \(Constants.FlickrResponseKeys.Photos)")
                    return
                }
                
                guard let photoArray = photoDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    displayError("Could not find key \(Constants.FlickrResponseKeys.Photo)")
                    return
                }
                guard let totalPages = photoDictionary[Constants.FlickrResponseKeys.Pages] as?  Int else{
                    
                    displayError("Could not find key \(Constants.FlickrResponseKeys.Pages)")
                    return
                }
                print("Pages \(totalPages)")
                
                if photoArray.count == 0 {
                    displayError("No photos found. Search Again")
                    return
                }else {
                    
//                    if withPageNumber == nil
//                    {
//                    //random pages
//                    let pageLimt = min(totalPages, 40)
//                    let randomPage = Int(arc4random_uniform(UInt32(pageLimt))) + 1
////                    self.displayImageFromFlickrBySearch(methodParameters, withpageNumber: randomPage)
//                    self.displayImageFromFlickrBySearch(methodParameters, withPageNumber:randomPage)
//                        
//                    }
                    
                    
                    let randomIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                    
                    print("random Index \(randomIndex)")
                    let photoDictionary = photoArray[randomIndex] as [String:AnyObject]
                    let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                    
                    guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else{
                        displayError("Could not find key \(Constants.FlickrResponseKeys.MediumURL)")
                        return
                    }
                    
                    let imageURL = NSURL(string: imageUrlString)
                    if let imageData = NSData(contentsOfURL: imageURL!){
                        performUIUpdatesOnMain(){
                            self.setUIEnabled(true)
                            self.photoTitleLabel.text = photoTitle
                            self.photoImageView.image = UIImage(data: imageData)
                            
                        }
                        
                    }else {
                        displayError("Image does not exit at \(imageURL)")
                    }
                    
                    
                    
                }

            }else {
                print(error!.localizedDescription)
            }
        }
        
        task.resume()
        
        
    }
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}

// MARK: - ViewController: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(phraseTextField)
        resignIfFirstResponder(latitudeTextField)
        resignIfFirstResponder(longitudeTextField)
    }
    
    // MARK: TextField Validation
    
    private func isTextFieldValid(textField: UITextField, forRange: (Double, Double)) -> Bool {
        if let value = Double(textField.text!) where !textField.text!.isEmpty {
            return isValueInRange(value, min: forRange.0, max: forRange.1)
        } else {
            return false
        }
    }
    
    private func isValueInRange(value: Double, min: Double, max: Double) -> Bool {
        return !(value < min || value > max)
    }
}

// MARK: - ViewController (Configure UI)

extension ViewController {
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        phraseTextField.enabled = enabled
        latitudeTextField.enabled = enabled
        longitudeTextField.enabled = enabled
        phraseSearchButton.enabled = enabled
        latLonSearchButton.enabled = enabled
        
        // adjust search button alphas
        if enabled {
            phraseSearchButton.alpha = 1.0
            latLonSearchButton.alpha = 1.0
        } else {
            phraseSearchButton.alpha = 0.5
            latLonSearchButton.alpha = 0.5
        }
    }
}

// MARK: - ViewController (Notifications)

extension ViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}