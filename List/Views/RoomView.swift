//
//  ContentView.swift
//  List
//
//  Created by Miles Broomfield on 28/01/2021.

//TO DO:
//Show bar that not connected to internet
//Replace textfield with an expandable textfield

import SwiftUI
import PartialSheet
import ImageViewerRemote

struct RoomView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewController:GlobalViewController
    @ObservedObject var partialSheetController = PartialSheetController()
    @EnvironmentObject var partialSheet : PartialSheetManager
    @State var partialSheetView:AnyView?
    
    //Room
    let controller:RoomController
    @State var room:Room?
    @State var postable:Bool = false

    //Validation
    @State var status:RoomStatus = .new
    
    let maxCharacters = 150
    
    //Posts
    @State var posts:[Post] = []
    @State var postCount:Int = 0
    
    //Input
    @State var message:String = ""
    @State var addedLinks:[InputLink] = []
    @State var addedImages:[UIImage] = []
    
    //Image
    @State var inputImage:UIImage?
    
    @State var textfieldFocus:Bool = false
    
    @State var mediaShown:Bool = false
    @State var mediaURL:String = ""
    
    //Modal
    @State var pickerPresented:Bool = false
    @State var submittedShown:Bool = false
    @State var submittedPost:Post?
    
    @State var modalPresented:Bool = false
    @State var modalView:AnyView?
    
    init(controller:RoomController){
        self.controller = controller
    }
    
    var body: some View {
        VStack(spacing:0){
            HStack{
                VStack(alignment:.leading,spacing:10){
                    Text(room?.title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(room?.message ?? "")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                    HStack{
                        Image(systemName: "tag")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:20)
                            .foregroundColor(self.colorScheme == .light ? .white : ThemePresets.accentColor)
                        Text("£\(String(format: "%.2f",CostController.getPricePoundsForPostCount(count: self.postCount)))")
                            .font(.body)
                            .fontWeight(.regular)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.vertical,10)
                }
                .padding(10)
                .padding(.top,10)
                .foregroundColor(.white)
                Spacer()
            }
            Rectangle()
                .foregroundColor(ThemePresets.accentColor)
                .frame(height:1)
            VStack(spacing:0){
                ScrollView{
                    VStack(alignment:.leading,spacing: 20){
                        if(posts.isEmpty && status == .loaded){
                            
                            HStack{
                                Spacer()
                                Text("Be the first to post 🥳")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(10)
                                Spacer()
                            }
                        }
                        else if(posts.isEmpty && status == .error){
                            HStack{
                                Spacer()
                                Text("There was an error loading your posts ⚠️")
                                    .font(.headline)
                                    .fontWeight(.regular)
                                    .padding(10)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        }
                        else{
                            let sorted = HelperMethods.sortPostsHighestValueMostRecent(posts: posts)
                            ForEach((0..<sorted.count), id: \.self){ index in
                                VStack(alignment:.leading){
                                    PostView(post: sorted[index], isLastPost: (index == sorted.count-1), index: index, posts: HelperMethods.subPosts(index: index, posts: self.posts), horizontalPadding: 10,mediaShown:$mediaShown,mediaURL:$mediaURL)
                                }
                            }
                            Spacer()
                                .frame(minHeight:UIScreen.main.bounds.width*0.3)
                        }
                    }
                    .padding(.top,20)
                    .animation(.easeInOut)
                }
                .onTapGesture {
                    onAnyTap()
                }
                if(room != nil && room!.postable){
                    Rectangle()
                        .opacity(0.25)
                        .frame(height:0.5)
                        .padding(.bottom,10)
                    InputBlock(partialSheetController: self.partialSheetController, postCount: $postCount, message: $message, addedLinks: $addedLinks, addedImages: $addedImages, modalPresented: $modalPresented,modalView:$modalView, inputImage: $inputImage, textfieldFocus: $textfieldFocus, maxCharacters: maxCharacters, postMessage: postMessage)
                }
                else{
                    VStack(spacing:10){
                        Rectangle()
                            .frame(height:0.5)
                            Text("Posting has been turned off for this room.")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .padding(.horizontal,10)
                                .padding(.bottom,20)
                                .multilineTextAlignment(.center)
                    }
                }
            }
            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            .accentColor(colorScheme == .light ? Color.black : Color.white)
            .background((colorScheme == .light ? Color.white : Color.black).edgesIgnoringSafeArea(.all))
        }
        .background((colorScheme == .light ? ThemePresets.accentColor : Color.black).edgesIgnoringSafeArea(.all))
        .onTapGesture {
            onAnyTap()
        }
        .onReceive(controller.$room, perform: { room in
            //listens for updates on the room
            self.room = room
        })
        .onReceive(controller.$posts, perform: { posts in
            //listens for new posts
            self.posts = posts
        })
        .onReceive(controller.$status, perform: { status in
            //listens for updates on the status of the room
            self.status = status
            presentAlertOnError()
        })
        .addPartialSheet(style: PartialSheetStyle(background: .solid(self.colorScheme == .light ? .white :.black), handlerBarColor: .white, enableCover: true, coverColor: Color.gray.opacity(0.5), blurEffectStyle: nil, cornerRadius: 10, minTopDistance: 110))
        .onReceive(partialSheetController.$partialSheetIsShown, perform: { bool in
            if(bool){
                self.partialSheet.showPartialSheet({
                    //Dismissed
                }) {
                    self.partialSheetView
                }
            }
            else{
                self.partialSheet.closePartialSheet()
            }
        })
        .onReceive(partialSheetController.$partialSheetView, perform: { view in
            self.partialSheetView = view
        })
        .onReceive(controller.$postCount, perform: { count in
            self.postCount = count
        })
        .overlay(ImageViewerRemote(imageURL: self.$mediaURL, viewerShown: self.$mediaShown))
        .sheet(isPresented: $modalPresented, content: {
            VStack{
                if(self.modalView != nil){
                    self.modalView
                }
                else{
                    Text("loading...")
                        .foregroundColor(self.colorScheme == .light ? .black :.white)
                }
            }
        })
        .navigationBarHidden(true)
    }
    
    func onAnyTap(){
        self.textfieldFocus = false
    }
    
    func postMessage(value:Double){
        let flags:[String] = ["🇯🇲","🇹🇹","🇲🇱","🇬🇧"]
        let message = self.message
        let addedImages = self.addedImages
        let addedLinks = self.addedLinks
        let flag = flags.randomElement() ?? "🌍"
        let date = Date()
        
        
        if(maxCharacters < message.count){
            presentAlert(title: "Maximum Characters Exceeded", message: "Please reduce the number of characters in your post")
            return
        }
        
        if(!(message.isEmpty && addedLinks.isEmpty && addedImages.isEmpty)){
            controller.createPost(value: value, message: message, links: addedLinks, media: addedImages, localeFlag: flag,date:date,onCompletion:{ (id,err) in
                if let _ = id{
                    self.presentSubmittedView(post: SubmissionPost(message: message, links: addedLinks, media: addedImages, datePosted: date, localeFlag: flag))
                    controller.loadPosts()
                    controller.loadPostsEveryNSeconds()
                }
                else{
                    self.viewController.presentGeneralErrorAlert()
                }
                
            })
            self.message.removeAll()
            self.addedLinks.removeAll()
            self.addedImages.removeAll()
        }
    }
    
    func presentSubmittedView(post:SubmissionPost){
        self.modalView = .init(PostSubmittedView(post: post, horizontalPadding: 10))
        self.modalPresented = true
    }
    
    func dismissSubmittedView(){
        self.submittedShown = false
        self.submittedPost = nil
    }
    
    func presentAlert(title:String,message:String){
        //Call global view controller
        self.viewController.presentMessageAlert(model: AlertModel(type: .messageOnly, title: title, message: message, primaryButton: nil, secondaryButton: nil))
    }
    
    func presentAlertOnError(){
        if(status == .error && !self.posts.isEmpty){
            presentAlert(title: "Error", message: "There was an error loading ths room, check your connection and try again")
        }
    }
    
    struct InputBlock:View{
        
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var viewController:GlobalViewController
        @ObservedObject var partialSheetController:PartialSheetController
        
        @Binding var postCount:Int
        
        @Binding var message:String
        @Binding var addedLinks:[InputLink]
        @Binding var addedImages:[UIImage]
        
        @Binding var modalPresented:Bool
        @Binding var modalView:AnyView?
        @Binding var inputImage:UIImage?
        
        @Binding var textfieldFocus:Bool
                
        let maxCharacters:Int
        var postMessage:(Double)->Void
        
        @State var picker:AnyView?
        
        var body : some View{
            
            VStack(alignment:.leading,spacing:10){
                VStack(alignment:.leading,spacing:10){
                    HStack(spacing:20){
                        VStack{
                            OmenTextField(title: "Write a post", text: $message, textColor: self.colorScheme == .light ? .black : .white, isFocused: $textfieldFocus, returnKeyType: .send, onCommit: {presentCheckout()}, onTab:nil)
                            Rectangle()
                                .frame(height:1)
                        }
                        Button(action:{presentCheckout()}){
                            Circle()
                                .frame(width:40,height:40)
                                .overlay(Image(systemName:"paperplane.fill").foregroundColor(colorScheme == .light ? Color.white : Color.black))
                        }
                    }
                    .padding(.horizontal,10)
                    .padding(.top,5)
                }
                if(maxCharacters < message.count){
                    Text("Maximum characters allowed exceeded")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(.red)
                        .padding(.horizontal,10)
                }
                HStack(spacing:30){
                    Button(action:{self.presentLinkBuilder()}){
                        Image(systemName: "paperclip")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:20)
                    }
                    Button(action:{self.presentImagePicker()}){
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:20)
                    }
                    Spacer()
                    Button(action:{onAnyTap();self.message.removeAll()}){
                        Text("Clear Text")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .underline()
                    }
                }
                .padding(.horizontal,10)
                .padding(.top,10)
                
                if(!self.addedLinks.isEmpty){
                    ScrollView(.horizontal,showsIndicators:false){
                        HStack(spacing:15){
                            ForEach(addedLinks, id: \.id){link in
                                HStack(spacing:5){
                                    Text(link.tag)
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .underline()
                                    Button(action:{
                                        self.removeLink(id: link.id)
                                    }){
                                        Image(systemName: "xmark")
                                    }
                                }
                                .foregroundColor(ThemePresets.accentColor)
                            }
                        }
                        .padding(.horizontal,10)
                    }
                    .padding(.top,10)
                    .animation(.easeInOut)
                }
                if(!self.addedImages.isEmpty){
                    ScrollView(.horizontal,showsIndicators:false){
                        HStack(spacing:10){
                            ForEach(addedImages, id: \.self){image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height:0.12*UIScreen.main.bounds.height)
                                    .frame(minWidth:100)
                                    .clipShape(RoundedRectangle(cornerRadius: 0.12*UIScreen.main.bounds.height*0.1))
                                    .overlay(
                                        VStack{
                                            HStack{
                                                Spacer()
                                                Button(action:{removeImage(image: image)}){
                                                    Circle()
                                                        .frame(width:30,height:30)
                                                        .padding(5)
                                                        .overlay(
                                                            Image(systemName:"xmark")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width:15,height:15)
                                                                .foregroundColor(colorScheme == .light ? Color.white : Color.black)

                                                        )
                                                }
                                            }
                                            Spacer()
                                        }
                                    )
                               
                            }
                        }
                        .padding(.horizontal,10)
                    }
                    .padding(.top,10)
                    .animation(.easeInOut)
                }
            }
            .foregroundColor(self.colorScheme == .light ? ThemePresets.accentColor : .white)
            .padding(.bottom,20)
            .onAppear{
                self.picker = .init(ImagePicker(image: $inputImage, onFinishedPicking: self.finishedPickingImage))
            }
        }
        
        func presentCheckout(){
            let amount = CostController.getPricePoundsForPostCount(count: self.postCount)
            self.textfieldFocus = false
            if(!(message.isEmpty && addedLinks.isEmpty && addedImages.isEmpty)){
                self.partialSheetController.presentPartialSheetView(view: .init(MockPaymentView(amount: amount, onSuccess: {postMessage(amount);self.partialSheetController.dimissPartialSheetView()}, dismiss: self.partialSheetController.dimissPartialSheetView)))
            }
            else{
                //Present Alert
                self.viewController.presentGeneralErrorAlert()
            }
        }
        
        func presentLinkBuilder(){
            if(addedLinks.count<3){
                self.partialSheetController.presentPartialSheetView(view: .init(LinkBuilder(partialSheetController: self.partialSheetController, appendLink: {link in
                    DispatchQueue.main.async {
                        self.addedLinks.append(link)
                    }
                })))
            }
            else{
                //Present max links reached
                self.viewController.presentMessageAlert(model: AlertModel(type: .titleOnly, title: "Max Characters"))
            }
        }
        
        func presentImagePicker(){
            self.modalView = picker
            self.modalPresented = true
        }
        
        func removeLink(id:UUID){
            self.addedLinks.removeAll(where: {$0.id == id})
        }
        
        func removeImage(image:UIImage){
            self.addedImages.removeAll(where: {$0 == image})
        }
        
        func finishedPickingImage(){
            if let img = inputImage{
                self.addedImages.append(img)
                self.inputImage = nil
            }
            self.modalPresented = false
        }
        
        func onAnyTap(){
            self.textfieldFocus = false
        }
    }
    
    struct LinkBuilder:View{
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var viewController:GlobalViewController
        @ObservedObject var partialSheetController:PartialSheetController

        @State var tag:String = ""
        @State var link:String = ""
        
        @State var linkInavlid:Bool = false
        let maxTagCharacters = 20
        
        var appendLink:(InputLink)->Void
        
        var body: some View{
            VStack(alignment:.leading,spacing:20){
                VStack(alignment:.leading,spacing:10){
                    Text("Link")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Users will be able to tap your tag to open your link, only the tag text is visible.")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment:.leading,spacing:10){
                    Text("Tag")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    TextField("e.g: @Twitter, My Website, etc...", text: $tag)
                        .font(.subheadline)
                    Rectangle()
                        .foregroundColor(ThemePresets.accentColor)
                        .frame(height:1)
                    if(tag.count > maxTagCharacters){
                        Text("Maximum characters allowed exceeded")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                VStack(alignment:.leading,spacing:10){
                    Text("Link")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    TextField("Copy and paste a valid link in here", text: $link)
                        .font(.subheadline)
                    Rectangle()
                        .foregroundColor(ThemePresets.accentColor)
                        .frame(height:1)
                    if(linkInavlid){
                        Text("Invalid link")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action:{submitLink()}){
                    HStack{
                        Spacer()
                        Text("Add Link")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(self.colorScheme == .light ? .white :.black)
                        Spacer()
                    }
                    .padding()
                    .background(Capsule())
                    .padding(.top,10)
                }
            }
            .foregroundColor(self.colorScheme == .light ? .black :.white)
            .padding(.horizontal,10)
            .padding(.bottom,20)
        }
        
        func submitLink(){
            self.linkInavlid = false
            
            if(tag.isEmpty){
                //Present Error
                self.viewController.presentTitleAlert(model: .init(type: .messageOnly, title: "Link Invalid", message: "You must add a tag for this link", primaryButton: nil, secondaryButton: nil))
                return
            }
            if(tag.count > maxTagCharacters){
                //Present Error
                return
            }
            if(!verifyUrl(urlString: link)){
                self.linkInavlid = true
                //Present Error
                return
            }
            //Link Okay
            self.appendLink(.init(tag: self.tag, link: self.link))
            self.partialSheetController.dimissPartialSheetView()
        }
        
        func verifyUrl (urlString: String) -> Bool {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
            return false
       }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetail(horizontalPadding: 10, post: Post(postID: "", roomID: "", value: 24, message: "Bobs your uncle phannie's your aunt!", links: [InputLink(tag: "Twitter", link: "")], media: ["a","b","c"], datePosted: Date(), localeFlag: "🇬🇧"), index: 28, posts: [])
            .preferredColorScheme(.dark)
            
    }
}
