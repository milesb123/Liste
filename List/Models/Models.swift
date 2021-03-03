//
//  Models.swift
//  List
//
//  Created by Miles Broomfield on 29/01/2021.
//

import Foundation
import UIKit
import SwiftUI

//Document
struct Post{
    let postID:String
    let roomID:String
    let value:Double
    let message:String
    let links:[InputLink]
    let media:[String]
    let datePosted:Date
    let localeFlag:String
}

struct InputLink{
    let id = UUID()
    let tag:String
    let link:String
}

//Collection
struct Room{
    let roomID:String
    let title:String
    let message:String
    let reloadTime:Int
    let postable:Bool
}
