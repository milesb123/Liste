//
//  LobbyController.swift
//  Liste
//
//  Created by Miles Broomfield on 03/03/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class LobbyController:ObservableObject{
    
    let db = Firestore.firestore()
    
    @Published var lobbyStatus:TempLobbyStatus = .initial
    @Published var roomController:RoomController?
    //Check Mission Status
    //Get Beta Room
    
    func activateControlListener() -> Void{
        Auth.auth().signInAnonymously { (result, err) in
            guard let _ = result else {
                print("LOGIN FAILED:",err)
                self.lobbyStatus = .error;
                return
                
            }
            
            self.db.collection(Constants.controls.rawValue).document(Constants.controls.rawValue).addSnapshotListener { (snapshot, err) in
                guard let snapshot = snapshot else { self.lobbyStatus = .error; return }
                guard let data = snapshot.data() else { self.lobbyStatus = .error; return }
                
                guard let betaRoomID = data["stage"] as? String else { self.lobbyStatus = .error; return }
                
                //Get Beta Room
                self.setBetaRoom(roomID: betaRoomID)
            }
        }
    }
    
    func setBetaRoom(roomID:String){
        db.collection(Constants.rooms.rawValue).document(roomID).getDocument { (snapshot, err) in
            guard let snapshot = snapshot else { self.lobbyStatus = .error; return }
            guard let data = snapshot.data() else { self.lobbyStatus = .error; return }
            
            let room = RoomController.getRoomFromDBM(id: snapshot.documentID, data: data)
            self.roomController = .init(room: room, timeInterval: room.reloadTime)
        }
    }
}

enum TempLobbyStatus:String{
    case initial
    case error
}
