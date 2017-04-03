//
//  GameAttendanceViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import AppFriendsCore
import AlamofireImage

import AppFriendsUI

struct AttendeesCategory {
    static let Pending = "Pending", Accepted = "Accepted", Rejected = "Rejected"
}

struct Actions {
    static let Invite = "invite", Decision = "decision", Cancel = "cancel"
}

class GameAttendanceViewController: BaseViewController
{
    var gameAttendanceDialogID: String?

    var gameTitle: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var acceptedUserIDs = [String]()
    var pendingUserIDs = [String]()
    var rejectedUserIDs = [String]()
    
    var isOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
