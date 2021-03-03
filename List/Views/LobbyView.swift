//
//  Lobby.swift
//  List
//
//  Created by Miles Broomfield on 29/01/2021.
//

import SwiftUI
import ImageViewerRemote

struct LobbyView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var controller:LobbyController
    @State var roomController:RoomController?
    
    init(controller:LobbyController){
        self.controller = controller
        roomController = controller.roomController
    }
    
    var body: some View {
        ZStack{
            if(roomController != nil){
                NavigationView{
                    let room = self.roomController!
                    RoomView(controller: room)
                        .navigationBarHidden(true)
                }
                .accentColor(self.colorScheme == .light ? .black : .white)
            }
            else{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing:20){
                    Image("Splash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:UIScreen.main.bounds.width*0.4,height:UIScreen.main.bounds.width*0.4)
                }
                .multilineTextAlignment(.center)
            }
        }
        .foregroundColor(.white)
        .onReceive(self.controller.$roomController, perform: { room in
            DispatchQueue.main.async{
                self.roomController = room
            }
        })
        .onAppear{
            navigationInit(color:self.colorScheme == .light ? .black : .white)
        }
    }
    
    func navigationInit(color:UIColor){
        // this is not the same as manipulating the proxy directly
        let appearance = UINavigationBarAppearance()
        
        // this overrides everything you have set up earlier.
        appearance.configureWithTransparentBackground()
        
        // this only applies to big titles
        
        var color = color
        
        appearance.largeTitleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : color
        ]
        // this only applies to small titles
        appearance.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : color
        ]
        
        //In the following two lines you make sure that you apply the style for good
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
        // This property is not present on the UINavigationBarAppearance
        // object for some reason and you have to leave it til the end
        UINavigationBar.appearance().tintColor = color
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView(controller: .init())
    }
}
