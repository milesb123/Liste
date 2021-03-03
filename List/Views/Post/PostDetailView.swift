//
//  PostDetailView.swift
//  Liste
//
//  Created by Miles Broomfield on 26/02/2021.
//

import SwiftUI
import PartialSheet
import ImageViewerRemote
import ImageViewer

struct SubmissionPost{
    let message:String
    let links:[InputLink]
    let media:[UIImage]
    let datePosted:Date
    let localeFlag:String
}

struct PostSubmittedView:View{
    @Environment(\.colorScheme) var colorScheme
    
    let post:SubmissionPost
    let horizontalPadding:CGFloat
    
    @State var mediaShown:Bool = false
    @State var mediaImage:Image?
    
    var body : some View{
        VStack(spacing:0){
            ScrollView{
                VStack(alignment: .leading,spacing:20){
                    Text("1. \(post.message)")
                        .font(.title)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal,horizontalPadding)
                        .fixedSize(horizontal: false, vertical: true)
                    if(!post.media.isEmpty){
                        ScrollView(.horizontal,showsIndicators:false){
                            HStack(spacing:10){
                                ForEach(post.media,id: \.self){image in
                                    Button(action:{
                                        self.imageTapped(image: image)
                                    }){
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode:.fill)
                                            .frame(width:0.6*UIScreen.main.bounds.width, height: 0.6*UIScreen.main.bounds.width*0.7)
                                            .clipShape(RoundedRectangle(cornerRadius: 0.4*UIScreen.main.bounds.width*0.08))
                                            .animation(.none)
                                    }
                                }
                            }
                            .padding(.horizontal,horizontalPadding)
                        }
                        .padding(.vertical,10)
                    }
                    if(!post.links.isEmpty){
                        ScrollView(.horizontal,showsIndicators:false){
                            HStack(spacing: 15){
                                Image(systemName: "paperclip")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height:20)
                                ForEach(post.links,id: \.id){ link in
                                    Button(action:{
                                        linkTapped(link: link.link)
                                    }){
                                        Text(link.tag)
                                            .font(.body)
                                            .fontWeight(.regular)
                                            .underline()
                                            .foregroundColor(ThemePresets.accentColor)
                                    }
                                }
                            }
                            .padding(.horizontal,horizontalPadding)
                        }
                    }
                    Text(date())
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.gray)
                        .padding(.horizontal,horizontalPadding)
                        .padding(.bottom,10)
                    
                    Rectangle()
                        .opacity(0.25)
                        .frame(height:0.5)
                        .padding(.trailing,10+horizontalPadding)
                        .padding(.top)
                    
                    Text("Thank You For Your Donation!")
                        .font(.headline)
                        .bold()
                        .padding(.horizontal,horizontalPadding)
                    
                    Spacer()
                }
                .padding(.top,40)
            }
        }
        .navigationBarHidden(false)
        .navigationBarTitle("Post", displayMode: .inline)
        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
        .background((colorScheme == .light ? Color.white : Color.black).edgesIgnoringSafeArea(.all))
        .overlay(ImageViewer(image: $mediaImage, viewerShown: $mediaShown))
    }
    
    func date() -> String{
        let build = "\(post.localeFlag) "
        
        let date = DateHandler.shared.shortForDate(date: post.datePosted)
        if(date == DateHandler.shared.shortForDate(date: Date())){
            return build + "Today @ \(DateHandler.shared.timeForDate(date: post.datePosted))"
        }
        else{
            return build + DateHandler.shared.longForDate(date: post.datePosted)
        }
    }
    
    func linkTapped(link:String){
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    func imageTapped(image:UIImage){
        self.mediaImage = Image(uiImage: image)
        self.mediaShown = true
    }
    
}

struct PostDetail:View{
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewController:GlobalViewController
    
    let horizontalPadding:CGFloat
    
    let post:Post
    let index:Int
    var posts:[Post]
    
    @State var mediaShown:Bool = false
    @State var mediaURL:String = ""
    
    var body : some View{
        VStack(spacing:0){
            Rectangle()
                .foregroundColor(ThemePresets.accentColor)
                .frame(height:1)
            ScrollView{
                VStack(alignment: .leading,spacing:20){
                    Text("\(index+1). \(post.message)")
                        .font(.title)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal,horizontalPadding)
                        .fixedSize(horizontal: false, vertical: true)
                    if(!post.media.isEmpty){
                        ScrollView(.horizontal,showsIndicators:false){
                            HStack(spacing:10){
                                ForEach(post.media,id: \.self){link in
                                    Button(action:{
                                        self.imageTapped(url: link)
                                    }){
                                        URLImage(urlString: link, width: 0.6*UIScreen.main.bounds.width, height: 0.6*UIScreen.main.bounds.width*0.7, contentMode: .fill)
                                            .clipShape(RoundedRectangle(cornerRadius: 0.4*UIScreen.main.bounds.width*0.08))
                                            .animation(.none)
                                    }
                                }
                            }
                            .padding(.horizontal,horizontalPadding)
                        }
                        .padding(.vertical,10)
                    }
                    if(!post.links.isEmpty){
                        ScrollView(.horizontal,showsIndicators:false){
                            HStack(spacing: 15){
                                Image(systemName: "paperclip")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height:20)
                                ForEach(post.links,id: \.id){ link in
                                    Button(action:{linkTapped(link: link.link)}){
                                        Text(link.tag)
                                            .font(.body)
                                            .fontWeight(.regular)
                                            .underline()
                                            .foregroundColor(ThemePresets.accentColor)
                                    }
                                }
                            }
                            .padding(.horizontal,horizontalPadding)
                        }
                    }
                    
                    Text(date())
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundColor(.gray)
                        .padding(.horizontal,horizontalPadding)
                    
                    Rectangle()
                        .opacity(0.25)
                        .frame(height:0.5)
                        .padding(.trailing,10+horizontalPadding)
                        .padding(.top)
                    
                    if(self.posts.count > 0){
                        Text("More Posts")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal,horizontalPadding)
                        let sorted = HelperMethods.sortPostsHighestValueMostRecent(posts: posts)
                        ForEach((0..<sorted.count), id: \.self){ index in
                            if #available(iOS 14.0, *) {
                                LazyVStack(alignment:.leading){
                                    PostView(post: sorted[index], isLastPost: (index == sorted.count-1), index: self.index + index + 1, posts: HelperMethods.subPosts(index: index, posts: self.posts), horizontalPadding: 10,mediaShown:$mediaShown,mediaURL:$mediaURL)
                                }
                            } else {
                                // Fallback on earlier versions
                                VStack(alignment:.leading){
                                    PostView(post: sorted[index], isLastPost: (index == sorted.count-1), index: self.index + index + 1, posts: HelperMethods.subPosts(index: index, posts: self.posts), horizontalPadding: 10,mediaShown:$mediaShown,mediaURL:$mediaURL)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top,30)
            }
            .navigationBarHidden(false)
            .navigationBarTitle("Post", displayMode: .inline)
        }
        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
        .overlay(ImageViewerRemote(imageURL: self.$mediaURL, viewerShown: self.$mediaShown))
    }
    
    func date() -> String{
        let build = "\(post.localeFlag) "
        
        let date = DateHandler.shared.shortForDate(date: post.datePosted)
        if(date == DateHandler.shared.shortForDate(date: Date())){
            return build + "Today @ \(DateHandler.shared.timeForDate(date: post.datePosted))"
        }
        else{
            return build + DateHandler.shared.longForDate(date: post.datePosted)
        }
    }
    
    func linkTapped(link:String){
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    func imageTapped(url:String){
        self.mediaURL = url
        self.mediaShown = true
    }
}
