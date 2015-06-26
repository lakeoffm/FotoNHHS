//
//  PhotosCollectionViewController.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 10.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Photo"

class PhotosCollectionViewController: UICollectionViewController {

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
    
    var album:Album = Album()
    var photos:[Photo] = []{
        didSet{
            dispatch_async(dispatch_get_main_queue()){
                self.photostreamCollectionView.reloadData()
                self.isLoadingData = false
            }
        }
    }
    
    var isLoadingData:Bool = false
    
    @IBOutlet var photostreamCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (album.getAlbumId() != ""){
            self.getPhotos()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close (segue:UIStoryboardSegue){
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        photostreamCollectionView.performBatchUpdates(nil , completion: nil)
    }
    
    
    
    // MARK: UICollectionViewFlowLayoutDelegate
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let photoWidth = screenSize.width/4.5
            
            let size=CGSizeMake(photoWidth, photoWidth)
            return size
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        // Configure the cell
        cell.imageThumbnail.image = UIImage(data: photos[indexPath.row].getImageData())
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPhoto"{
            if let indexPath = photostreamCollectionView.indexPathForCell(sender as! PhotoCollectionViewCell){
                let destinationController = segue.destinationViewController as! SinglePhotoViewController
                destinationController.photoID = self.photos[indexPath.row].getPhotoID()
            }
        }
    }
    
    
    func getPhotos() {
        //We choose a proper method from the Flickr API
        let METHOD_NAME = "flickr.photosets.getPhotos"
        let EXTRAS = "url_sq"
        let currentPageNumber:Int=Int(photos.count/32)
        
        //Prepare arguments to call a method
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "photoset_id": self.album.getAlbumId(),
            "page": "\(currentPageNumber + 1)",
            "per_page": "32",
            "user_id": USER_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        if (!isLoadingData && photos.count%32==0){
            
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
                
                if let photosDictionary = parsedResult.valueForKey("photoset") as? NSDictionary {
                    
                    if let photosArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        
                        //
                        
                        for photo in photosArray {
                            let photoID = photo["id"] as! String
                            
                            //Additional information to make a URL
                            //Scheme for url is: https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_q.jpg
                            
                            let farmID = photo["farm"] as! Int
                            let serverID = photo["server"] as! String
                            let secretID = photo["secret"] as! String
                            
                            let photoURL = "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(secretID)_q.jpg"
                            
                            if let photoData = NSData(contentsOfURL: NSURL(string: photoURL)!) {
                                self.createPhoto(photoID, photoData: photoData)
                                
                            } else {
                                print("Image does not exist at \(photoURL)")
                            }
                        }
                        
                        
                    } else {
                        print("Cant find key 'photo' in \(photosDictionary)")
                    }
                    
                } else {
                    print("Cant find key 'photosets' in \(parsedResult)")
                }
            }
        }
        
        task!.resume()
    }
    
    func createPhoto(id:String, photoData:NSData){
        let newPhoto: Photo = Photo(id: id, size: Photo.Sizes.LargeSquare, possibleSizes: [Photo.Sizes.LargeSquare], data: photoData)
        
        photos.append(newPhoto)
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
    
    //
    // Scroll to refresh
    //
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maximumOffset>0 && currentOffset>0 && currentOffset - maximumOffset >= 100){
            if (!isLoadingData){
                getPhotos()
                isLoadingData = true
            }
        }
    }

}
