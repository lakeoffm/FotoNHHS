//
//  SinglePhotoViewController.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 11.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import UIKit

class SinglePhotoViewController: UIViewController, UIScrollViewDelegate {

    //
    // API Constants
    //
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let API_KEY = "66958729b53eef7d5a51930bac3b2889"
    let USER_ID = "51031042@N07"
    
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    //
    // End of API Constants
    //
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photoID:String = ""
    
    var photoURLS = [String: NSURL](){
        didSet{
            if (photoURLS["Large 1600"] != nil){
                fetchImage(photoURLS["Large 1600"])
            }
        }
    }
    
    var isLoadingData:Bool = false {
        didSet{
            if (isLoadingData == true) {
                self.activityIndicator.startAnimating()
            }
            else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func fetchImage(imageURL: NSURL?){
        if let url = imageURL{
            print ("Image URL is: \(url)")
            
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0), {
            
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()){
                    if imageData != nil{
                        self.image = UIImage(data: imageData!)
                    }
                    else
                    {
                        self.image = nil
                    }
                    
                }
            })
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 2
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    private var image:UIImage?{
        get{ return imageView.image}
        set{
            print("New image value assigned")
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            isLoadingData = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //GET URLS FOR THE SIZES AVAILABLE, DOWNLOAD THE LARGE 1600 IF AVAILABLE
        self.getSizes()
    }
    
    func getSizes(){
        //We choose a proper method from the Flickr API
        let METHOD_NAME = "flickr.photos.getSizes"
        
        //Prepare arguments to call a method
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "photo_id": self.photoID,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        if (!isLoadingData){
            isLoadingData = true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.getDataFromFlickr(methodArguments)
            }
        }
    }
    
    func getDataFromFlickr(arguments:Dictionary<String, String>) {
        
        /* Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(arguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                /* Parse the data */
                var parsingError: NSError? = nil
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                } catch var error as NSError {
                    parsingError = error
                    parsedResult = nil
                } catch {
                    fatalError()
                }
                
                if let sizesDictionary = parsedResult.valueForKey("sizes") as? NSDictionary {
                    
                    if let sizesArray = sizesDictionary.valueForKey("size") as? [[String: AnyObject]] {
                        
                        for size in sizesArray {
                            let sizeName = size["label"] as! String
                            let sizeURL = size["source"] as! String
                            
                            self.photoURLS[sizeName] = NSURL(string: sizeURL)
                        }
                        
                        
                    } else {
                        print("Cant find key 'size' in \(sizesDictionary)")
                    }
                    
                } else {
                    print("Cant find key 'sizes' in \(parsedResult)")
                }
            }
        }
        
        task!.resume()
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + "&".join(urlVars)
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        if image == nil{ fetchImage()
//        }
    }
    
}
