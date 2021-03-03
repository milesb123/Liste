//
//  Helper.swift
//  Liste
//
//  Created by Miles Broomfield on 02/03/2021.
//

import Foundation

class HelperMethods{
    
    static func sortPostsHighestValueMostRecent(posts:[Post]) -> [Post]{
        return posts.sorted(by: {
            if($0.value == $1.value){
                return $0.datePosted > $1.datePosted
            }
            else{
                return $0.value > $1.value
            }
        })
    }
    
    static func subPosts(index:Int,posts:[Post]) -> [Post]{
        var posts = posts
        posts.removeSubrange(0...index)
        return posts
    }
    
}
