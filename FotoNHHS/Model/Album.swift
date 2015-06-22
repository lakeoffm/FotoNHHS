//
//  Album.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 22.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import Foundation

class Album {
    
    private let albumID:Int
    private let albumName:String
    private let numberOfPhotos:Int
    private let dateCreated:NSDate //TO BE CHANGED TO NSDate
    private let coverPhoto:Photo
    
    init(id:Int, name:String, photos:Int, dateCreated:NSDate, cover:Photo){
        self.albumID = id
        self.albumName = name
        self.numberOfPhotos = photos
        self.dateCreated = dateCreated
        self.coverPhoto = cover
    }
    
    func getAlbumId()->Int{
        return self.albumID
    }
    
    func getAlbumName()-> String{
        return self.albumName
    }
    
    func getNumberOfPhotos()->Int{
        return self.numberOfPhotos
    }
    
    func getDateCreated()->NSDate{
        return self.dateCreated
    }
    
}