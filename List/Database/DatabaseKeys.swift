//
//  Database.swift
//  List
//
//  Created by Miles Broomfield on 28/01/2021.
//

import Foundation

enum Constants:String{
    case controls
    case status
    
    case rooms
    case title
    case reloadTime
    case postable
    
    case room
    case posts
    
    case value
    case message
    case datePosted
    case roomID
    case links
    case media
    case localeFlag
}

enum RoomStatus{
    case new
    case loaded
    case error
}
