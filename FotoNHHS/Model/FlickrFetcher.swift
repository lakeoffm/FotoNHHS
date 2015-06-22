//
//  FlickrFetcher.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 22.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import Foundation

class FlickrFetcher {
    
    var albums:[Album]=[]
    var photos:[Photo]=[]
    
    
    func getAlbums()->[Album]{
        //TO ADD GETTING THE LIST OF ALBUMS
        
        return self.albums
    }
    
    func createAlbum(id:Int, title:String, numberOfPhotos:Int, dateCreated:NSDate, coverPhoto:Photo){
        let newAlbum: Album = Album(id: id, name: title, photos: numberOfPhotos, dateCreated: dateCreated, cover: coverPhoto)
        
        albums.append(newAlbum)
    }
    
    func getPhotos()->[Photo]{
        return self.photos
    }
    
    func getPhoto(id:Int, size:Photo.Sizes){
        
    }
}