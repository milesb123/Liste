//
//  GlobalViewController.swift
//  Liste
//
//  Created by Miles Broomfield on 23/02/2021.
//

import SwiftUI
import Foundation
import UIKit

class GlobalViewController:ObservableObject{
    
    @Published var alertIsShown:Bool = false
    @Published var alertContent:AlertModel?
    
    func presentTitleAlert(model:AlertModel){
        self.alertContent = model
        self.alertIsShown = true
    }
    func presentMessageAlert(model:AlertModel){
        self.alertContent = model
        self.alertIsShown = true
    }
    func presentSingleOptionAlert(model:AlertModel){
        self.alertContent = model
        self.alertIsShown = true
    }
    func presentTwoOptionAlert(model:AlertModel){
        self.alertContent = model
        self.alertIsShown = true
    }
    
    func presentGeneralErrorAlert(){
        self.alertContent = .init(type: .messageOnly, title: "Sorry about that", message: "Something went wrong, check your connection and try again", primaryButton: nil, secondaryButton: nil)
        self.alertIsShown = true
    }
    
}

class PartialSheetController:ObservableObject{
    
    @Published var partialSheetIsShown:Bool = false
    @Published var partialSheetView:AnyView?
    
    func presentPartialSheetView(view:AnyView){
        self.partialSheetView = view
        self.partialSheetIsShown = true
    }
    
    func dimissPartialSheetView(){
        self.partialSheetIsShown = false
        self.partialSheetView = AnyView(EmptyView())
    }
    
}
