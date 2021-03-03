//
//  URLImage.swift
//  Giftd
//
//  Created by Miles Broomfield on 03/02/2021.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct URLImage: View {
    
    @ObservedObject var urlImageModel:URLImageModel
    var width:CGFloat?
    var height:CGFloat?
    var contentMode:ContentMode
    
    
    init(urlString: String, width:CGFloat?=nil, height:CGFloat?=nil, contentMode:ContentMode = .fill){
        self.width = width
        self.height = height
        self.contentMode = contentMode
        urlImageModel = URLImageModel(urlString: urlString)
    }
    
    var body: some View {
        VStack(spacing:0){
            Image(uiImage: urlImageModel.image ?? URLImage.defaultImage!)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width:width,height: height)
                .clipped()
            HStack{
                Spacer()
            }
            .frame(height:0)
        }
    }
    
    
    
    static var defaultImage = UIImage(named: "default")
}

class URLImageModel:ObservableObject{
    
    @Published var image:UIImage?
    var urlString: String?
    var imageCache = ImageCache.getImageCache()
    
    init(urlString:String){
        self.urlString = urlString
        if (self.loadImageFromCache()){
            return
        }
        else{
            loadImageFromURL()
        }
    }
    
    func loadImageFromCache() ->Bool{
        guard let urlString = urlString else{
            return false
        }
        
        guard let cacheImage = imageCache.get(forKey: urlString) else {return false}
        
        image = cacheImage
        return true
        
    }
    
    func loadImageFromURL(){
        guard let urlString = urlString else{return}
        
        if let url = URL(string: urlString){
            let task = URLSession.shared.dataTask(with: url, completionHandler: getImageFromResponse(data:respone:error:))
            task.resume()
        }
    }
    
    func getImageFromResponse(data:Data?, respone:URLResponse?, error:Error?){
        guard error == nil else{
            print("Error:\(error!)")
            return
        }
        
        guard let data = data else{
            print("not data found")
            return
        }
        
        DispatchQueue.main.async {
            guard let loadedImage = UIImage(data: data) else{
                return
            }
            self.imageCache.set(forKey: self.urlString!, image: loadedImage)
            self.image = loadedImage
        }
        
    }
    
}

class ImageCache{
    var cache = NSCache<NSString,UIImage>()
    
    func get(forKey:String) -> UIImage?{
        return cache.object(forKey: NSString(string:forKey))
    }
    
    func set(forKey:String, image: UIImage){
        cache.setObject(image, forKey: NSString(string: forKey))
    }
    
    
}

extension ImageCache{
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache{
        return imageCache
    }
}
