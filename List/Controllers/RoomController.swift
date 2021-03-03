//
//  RoomController.swift
//  Liste
//
//  Created by Miles Broomfield on 03/03/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class RoomController:ObservableObject{
        
    var roomListener:ListenerRegistration?
    var postCountListener:ListenerRegistration?
    let postLimit:Int = 100
    let timeInterval:Int
    var timer:Timer?
    
    let db = Firestore.firestore()
    let imageHandler = ImageHandler()
    
    @Published var room:Room
    @Published var status:RoomStatus = .new
    @Published var posts:[Post] = []
    @Published var postCount:Int = 0
    
    init(room:Room,timeInterval:Int){
        self.room = room
        self.timeInterval = timeInterval
        self.loadPostsOnCollectionUpdate()
        self.activateRoomListener()
        self.activatePostCountListener()
    }
    
    static func getRoomFromDBM(id:String, data:[String:Any]) -> Room{
        let title = data[Constants.title.rawValue] as! String? ?? "Room"
        let message = data[Constants.message.rawValue] as! String? ?? "A list showing some posts"
        let reloadTime = data[Constants.reloadTime.rawValue] as! NSNumber? as! Int? ?? 7
        let postable = data[Constants.postable.rawValue] as! Bool? ?? false
                
        return Room(roomID: id, title: title, message: message,reloadTime: reloadTime, postable: postable)
    }
    
    static func getPostFromDBM(id:String,data:[String:Any]) -> Post?{
        //Create post object, refactor to use JSON decodable
        guard let message = data[Constants.message.rawValue] as? String else {return nil}
        guard let room = data[Constants.roomID.rawValue] as? String else {return nil}
        var links = data[Constants.links.rawValue] as? NSArray as? [NSDictionary] as? [[String:Any]] as? [[String:String]] ?? []
        links = links.filter({link in
            link["tag"] != nil && link["link"] != nil
        })
        let usableLinks = links.map({ InputLink(tag: $0["tag"]!, link: $0["link"]!) })
        let media = data[Constants.media.rawValue] as? NSArray as? [String] ?? []
        let datePosted = data[Constants.datePosted.rawValue] as? NSNumber as? Int ?? 0
        let value = data[Constants.value.rawValue] as? NSNumber as? Double ?? 0
        let localeFlag = data[Constants.localeFlag.rawValue] as? String ?? "🌍"
        return Post(postID: id, roomID: room, value: value, message: message, links: usableLinks, media: media, datePosted: Date(timeIntervalSince1970: TimeInterval(datePosted)), localeFlag: localeFlag)
    }
    
    static func getPostFromApp(post:Post) -> [String:Any]{
        var data:[String:Any] = [:]
        
        data[Constants.roomID.rawValue] = post.roomID
        data[Constants.value.rawValue] = post.value
        data[Constants.message.rawValue] = post.message
        data[Constants.links.rawValue] = post.links.map({link in
            ["tag":link.tag,"link":link.link]
        })
        data[Constants.posts.rawValue] = post.datePosted
        
        return data
    }
    
    func activateRoomListener(){
        self.roomListener = db.collection(Constants.rooms.rawValue).document(room.roomID).addSnapshotListener{ (snapshot, err) in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            
            self.room = RoomController.getRoomFromDBM(id: snapshot.documentID, data: data)
        }
    }
    
    func activatePostCountListener(){
        self.postCountListener = db.collection(Constants.controls.rawValue).document("postCount").addSnapshotListener({ (snapshot, err) in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            
            let count = data["count"] as? NSNumber as? Int ?? 0
            self.postCount = count
        })
    }
    
    func invalidateListener(){
        self.roomListener?.remove()
    }
    
    func loadPostsEveryNSeconds(){
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(self.loadPosts), userInfo: nil, repeats: true)

    }
    
    func endTimer(){
        timer?.invalidate()
    }
    
    func createPost(value:Double,message:String,links:[InputLink],media:[UIImage],localeFlag:String,date:Date,onCompletion:@escaping (String?,Error?)-> Void){
        let links = links.map({link in
            ["tag":link.tag,"link":link.link]
        })
         
        let doc = db.collection(Constants.posts.rawValue).document()
        
        doc.setData([
            Constants.roomID.rawValue:self.room.roomID,
            Constants.value.rawValue:value,
            Constants.message.rawValue:message,
            Constants.datePosted.rawValue:Int(date.timeIntervalSince1970),
            Constants.links.rawValue:links,
            Constants.localeFlag.rawValue:localeFlag
        ],merge: true) { (err) in
            if let err = err{
                onCompletion(nil,err)
            }
            else{
                self.uploadImages(images: media, postID: doc.documentID, onCompletion: onCompletion)
                onCompletion(doc.documentID,nil)
            }
        }
    }
    
    func uploadImages(images:[UIImage],postID:String,onCompletion:@escaping (String?,Error?)-> Void){
        let uploadable = images.map({$0.resizeWithWidth(width: 600)})
                
        for image in uploadable{
            if let image = image{
                self.imageHandler.uploadImageToImgur(image: image) { (url, err) in
                    if let url = url{
                        self.db.collection(Constants.posts.rawValue).document(postID).setData([Constants.media.rawValue:FieldValue.arrayUnion([url])], merge: true)
                    }
                }
            }
        }
        
        //onCompletion let user know there was error, if any
        
    }
    
    @objc
    func loadPosts(){
        db.collection(Constants.posts.rawValue).whereField(Constants.roomID.rawValue, isEqualTo: room.roomID).order(by: Constants.datePosted.rawValue,descending: true).limit(to: postLimit).getDocuments { (snapshot, err) in
            guard let documents = snapshot else {
                print("Error fetching document: \(err!)")
                self.status = .error
                return
            }
            
            var posts:[Post] = []
            
            for document in documents.documents{
                let data = document.data()
                
                if let post = RoomController.getPostFromDBM(id: document.documentID, data: data){
                    posts.append(post)
                }
            }
            
            self.status = .loaded
            self.posts = posts
        }
    }
    
    func loadPostsOnCollectionUpdate(){
        db.collection(Constants.posts.rawValue).whereField(Constants.roomID.rawValue, isEqualTo: room.roomID).order(by: Constants.datePosted.rawValue,descending: true).limit(to: postLimit).addSnapshotListener { (snapshot, err) in
            guard let documents = snapshot else {
                print("Error fetching document: \(err!)")
                self.status = .error
                return
            }
            
            var posts:[Post] = []
            
            for document in documents.documents{
                let data = document.data()
                
                if let post = RoomController.getPostFromDBM(id: document.documentID, data: data){
                    posts.append(post)
                }
            }
            
            self.status = .loaded
            self.posts = posts
        }
    }
}
