//
//  MediaModalView.swift
//  Liste
//
//  Created by Miles Broomfield on 25/02/2021.
//

import SwiftUI
import UIKit
import Foundation
import Combine

struct MediaModalView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var imageURL:String
    
    @Binding var mediaShown:Bool
    @State var scale: CGFloat = 1.0
    @State var offset = CGSize.zero

    var body: some View {
        ZStack{
            VStack{
                URLImage(urlString: imageURL, width: nil, height: nil, contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                self.scale = value.magnitude
                                if(scale < 1){
                                    self.scale = 1
                                }
                            }
                    )
                    .animation(.easeInOut)
            }
            VStack{
                HStack{
                    Spacer()
                    Button(action:{dismiss()}){
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:20)
                    }
                }
                Spacer()
            }
            .padding(20)
        }
        .foregroundColor(self.colorScheme == .light ? .black : .white)
    }
    
    func dismiss(){
        self.mediaShown = false
    }
    
}

struct MediaModalView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Media")
    }
}
