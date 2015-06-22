//
//  AlbumsTableViewController.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 10.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import UIKit

class AlbumsTableViewController: UITableViewController {

    var albumTitles = ["Bachelormiddagen", "Studentregatta", "Debatt om Formueskatt", "Bachelormiddagen", "Studentregatta", "Debatt om Formueskatt"]
    var albumInfo = ["142 photos - Published 21.05.2015", "22 photos - Published 21.04.2015", "12 photos - Published 21.03.2015", "142 photos - Published 21.05.2015", "22 photos - Published 21.04.2015", "12 photos - Published 21.03.2015"]
    var albumThumbnails = ["album1", "album2", "album3","album1", "album2", "album3"]
    
    var albums:[Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albumTitles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Album"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AlbumTableViewCell

        // Configure the cell...
        cell.albumTitle.text = " " + albumTitles[indexPath.row]
        cell.albumInfo.text = " " + albumInfo[indexPath.row]
        cell.thumbnailImage.image = UIImage(named: albumThumbnails[indexPath.row])

        return cell
    }
    

}
