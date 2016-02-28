//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(enabled: Bool) {
        photoTitleLabel.enabled = enabled
        grabImageButton.enabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        
     
        
        // TODO: Write the network code here!
        
let methodParameters =
    
        
        [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            
        
        ]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters)
        
        print(urlString)
        let url = NSURL(string: urlString)
        
        //check error
        func displayError(error: String){
            print(error)
            print("URL at time of error: \(url)")
            performUIUpdatesOnMain(){
                self.setUIEnabled(true)
            }
        }
        
      
        
        let request = NSURLRequest(URL: url!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){(data, response, error) in
            
            if error == nil{

                
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
                        
                    parseResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    }catch {
                        displayError("Could not parse the data as JSON: \(data)")
                        return
                    }
                
                    if let photoDictionary = parseResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                    photoArry = photoDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
                    
                    {
                        
//                        print(" array \(photoArry)")
//                        
//                        if let title = photoDictionary["title"] as? String {
//                            print("The title is \(title)")
//                        }

//                        
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArry.count)))
                        print("randomPho \((randomPhotoIndex))" )
//
                        let photoDictionary = photoArry[randomPhotoIndex] as? [String:AnyObject]
                        
                      
                        
                        if let imageUrlString = photoDictionary![Constants.FlickrResponseKeys.MediumURL] as? String,
                        
                            let photoTitle = photoDictionary![Constants.FlickrResponseKeys.Title] as? String {
                                
                                
                                let imageURL = NSURL(string: imageUrlString)
                                
                                if let imageData = NSData(contentsOfURL: imageURL!){
                                    performUIUpdatesOnMain(){
                                        self.photoImageView.image = UIImage(data: imageData)
                                        self.photoTitleLabel.text = photoTitle
                                        self.setUIEnabled(true)
                                        
                                    }
                                  
                                    
                                }
                                
                        }
                        
                        
                        
                    }
            

                  
                    
                }
                
            }

        task.resume()
        
        

        
        
    }
    
    
    
    private func escapedParameters(parameters:[String:AnyObject]) -> String {
        
        
        if parameters.isEmpty {
            return ""
        }else{
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                let stringValue = "\(value)"
            
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
    

    
    
}































