//
//  MotherView.swift
//  Liste
//
//  Created by Miles Broomfield on 23/02/2021.
//

import SwiftUI
import PartialSheet

struct MotherView: View {
    @EnvironmentObject var viewController:GlobalViewController
    @Environment(\.colorScheme) var colorScheme
    let lobbyController = LobbyController()
    
    @State var alertShown:Bool = false
    @State var alertContent:AlertModel?
    
    var body: some View {
        VStack{
            LobbyView(controller: lobbyController)
        }
        .onReceive(self.viewController.$alertIsShown, perform: { bool in
            self.alertShown = bool
        })
        .alert(isPresented: self.$alertShown, content: {
            //ASSUMPTION: If an alert has been shown, the corresponding alert content has been loaded into the viewController
            if let content = self.viewController.alertContent{
                switch(content.type){
                    case .titleOnly:
                        return .init(title: Text(content.title ))
                    case.messageOnly:
                        return .init(title: Text(content.title ), message: Text("\n\(content.message  ?? "Alert")\n"), dismissButton: .default(Text("Okay")))
                    case .oneOptionSpecified:
                        return .init(title: Text(content.title ), message: Text("\n\(content.message  ?? "Alert")\n"), dismissButton: .cancel(Text(content.primaryButton?.0 ?? "Okay"), action: content.primaryButton?.1 ?? {}))
                    case .twoOptionsSpecified:
                        return .init(title: Text(content.title ), message: Text("\n\(content.message  ?? "Alert")\n"), primaryButton: .cancel(Text(content.primaryButton?.0 ?? "Okay"), action: content.primaryButton?.1 ?? {}), secondaryButton: .destructive(Text(content.secondaryButton?.0 ?? "Okay"), action: content.secondaryButton?.1 ?? {}))
                }
            }
            else{
                return .init(title: Text("You are appreciated."))
            }
        })
    }
    
    init(){
        self.lobbyController.activateControlListener()
    }
    
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(GlobalViewController())
    }
}

class AlertModel{
    var type:AlertType
    var title:String
    var message:String?
    var primaryButton:(String,()->Void)?
    var secondaryButton:(String,()->Void)?
    
    init(type: AlertModel.AlertType, title: String, message: String? = nil, primaryButton: (String, () -> Void)? = nil, secondaryButton: (String, () -> Void)? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    enum AlertType{
        case titleOnly
        case messageOnly
        case oneOptionSpecified
        case twoOptionsSpecified
    }
    
}
