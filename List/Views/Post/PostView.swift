//
//  PostView.swift
//  Liste
//
//  Created by Miles Broomfield on 26/02/2021.
//

import SwiftUI
import PartialSheet
import ImageViewerRemote

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewController:GlobalViewController

    var post:Post
    var isLastPost:Bool
    let index:Int
    var posts:[Post]
    
    let horizontalPadding:CGFloat
    
    @Binding var mediaShown:Bool
    @Binding var mediaURL:String
    
    var body: some View {
        NavigationLink(
            destination: PostDetail(horizontalPadding: 10, post: post, index: index, posts: posts),
            label: {
            VStack(alignment:.leading,spacing:10){
                HStack{
                    Text("\(index+1). \(post.message)")
                        .font(.headline)
                        .fontWeight(.regular)
                        .padding(.horizontal,horizontalPadding)
                        .padding(.trailing,10+horizontalPadding)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                if(!post.media.isEmpty){
                    ScrollView(.horizontal,showsIndicators:false){
                        HStack(spacing:10){
                            ForEach(post.media,id: \.self){link in
                                Button(action:{self.imageTapped(url: link)}){
                                    URLImage(urlString: link, width: 0.4*UIScreen.main.bounds.width, height: 0.4*UIScreen.main.bounds.width*0.7, contentMode: .fill)
                                        .clipShape(RoundedRectangle(cornerRadius: 0.4*UIScreen.main.bounds.width*0.08))
                                        .animation(.none)
                                }
                            }
                        }
                        .padding(.horizontal,horizontalPadding)
                        .padding(.vertical,5)
                    }
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
                                        .font(.subheadline)
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
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                    .padding(.horizontal,horizontalPadding)
                
                if(!isLastPost){
                    Rectangle()
                        .opacity(0.25)
                        .frame(height:0.5)
                        .padding(.top,10)
                        .padding(.trailing,10+horizontalPadding)
                }
            }
            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
        })
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
