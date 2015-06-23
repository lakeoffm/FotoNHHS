//
//  AlbumsTableViewController.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 10.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {
    
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
    
    
    var albums:[Album]=[] {
        didSet{
            print ("The albums was set")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getAlbums()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("Строк в массиве: \(albums.count)")
        return albums.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Album"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AlbumTableViewCell

        // Configure the cell...
//        cell.albumTitle.text = " " + albumTitles[indexPath.row]
//        cell.albumInfo.text = " " + albumInfo[indexPath.row]
//        cell.thumbnailImage.image = UIImage(named: albumThumbnails[indexPath.row])
        
        let currentAlbum = albums[indexPath.row]
        cell.albumTitle.text = " " + currentAlbum.getAlbumName()
        print ("Album: \(currentAlbum.getAlbumName())")
        cell.albumInfo.text = " " + "\(currentAlbum.getNumberOfPhotos()) photos - Published \(currentAlbum.getDateCreated())"
        print ("Info: \(currentAlbum.getNumberOfPhotos())")
        cell.thumbnailImage.image = UIImage(data: currentAlbum.getCoverPhoto().getImageData())
        
        return cell
    }
    
    
    func getAlbums(){
        //We choose a proper method from the Flickr API
        let METHOD_NAME = "flickr.photosets.getList"
        let EXTRAS = "url_m"
        
        //Prepare arguments to call a method
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "user_id": USER_ID,
            "primary_photo_extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        getDataFromFlickr(methodArguments)
        
    }
    
    
    func createAlbum(id:String, title:String, numberOfPhotos:Int, dateCreated:String, coverPhoto:Photo){
        let newAlbum: Album = Album(id: id, name: title, photos: numberOfPhotos, dateCreated: dateCreated, cover: coverPhoto)
        
        albums.append(newAlbum)
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
                /* 5 - Success! Parse the data */
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
                
                if let albumsDictionary = parsedResult.valueForKey("photosets") as? NSDictionary {
                    
                    if let albumsArray = albumsDictionary.valueForKey("photoset") as? [[String: AnyObject]] {
                        
                        for album in albumsArray {
                            let albumID = album["id"] as! String
                            let albumTitleTemp = album ["title"] as! Dictionary<String, AnyObject>
                            let albumTitle = albumTitleTemp["_content"] as! String
                            let albumPhotos = album["photos"] as! String
                            let dateCreated = album["date_create"] as! String
                            let coverPhotoID = album["primary"] as! String
                            let coverPhotoURL = (album ["primary_photo_extras"] as! Dictionary<String, AnyObject>)["url_m"] as! String
                            
                            
                            if let coverPhotoData = NSData(contentsOfURL: NSURL(string: coverPhotoURL)!) {
                                self.createAlbum(albumID, title: albumTitle, numberOfPhotos: Int(albumPhotos)!, dateCreated: dateCreated, coverPhoto: Photo(id: coverPhotoID, size: Photo.Sizes.Medium, possibleSizes: [Photo.Sizes.Medium], data: coverPhotoData))
                                
                                
                            } else {
                                print("Image does not exist at \(coverPhotoURL)")
                            }
                        }
                        
                        
                    } else {
                        print("Cant find key 'photoset' in \(albumsDictionary)")
                    }
                    
                } else {
                    print("Cant find key 'photosets' in \(parsedResult)")
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


}
