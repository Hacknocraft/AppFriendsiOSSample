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

class GameAttendanceViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InviteUserViewControllerDelegate, ListObjectObserver, CancelActionButtonCellDelegate, ConfirmRejectTableViewCellDelegate, MessagingManagerDelegate
{
    var gameAttendanceDialogID: String?
    var monitor: ListMonitor<HCMessage>?
    var messageMonitor: ListMonitor<HCMessage>?
    
    var gameTitle: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var acceptedUserIDs = [String]()
    var pendingUserIDs = [String]()
    var rejectedUserIDs = [String]()
    
    var isOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // receive message receipt update and more
        MessagingManager.sharedInstance.delegate = self
        
        if let msgMonitor = CoreStoreManager.store()?.monitorList(
            From(HCMessage.self),
            Where("dialogID", isEqualTo: self.gameAttendanceDialogID),
            OrderBy(.descending("receiveTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
            )
        {
            msgMonitor.addObserver(self)
            self.messageMonitor = msgMonitor
            
            self.processMessage(msgMonitor.objectsInAllSections())
        }
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.collectionView.register(UINib(nibName: "AttendanceCell", bundle: nil), forCellWithReuseIdentifier: "AttendanceCell")
        self.collectionView.register(UINib(nibName: "ConfirmRejectTableViewCell", bundle: nil), forCellWithReuseIdentifier: "ConfirmRejectTableViewCell")
        self.collectionView.register(UINib(nibName: "CancelActionButtonCell", bundle: nil), forCellWithReuseIdentifier: "CancelActionButtonCell")
        self.collectionView.register(UINib(nibName: "PlayerSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PlayerSectionHeaderView.identifier)
        
        if let dialogID = self.gameAttendanceDialogID, let gameDialog = CoreStoreManager.store()?.fetchOne(From(HCChatDialog.self), Where("dialogID == %@", dialogID))
        {
            if let customData = gameDialog.customData {
                
                if let gameInfo = HCUtils.dictionaryFromJsonString(customData) {
                    
                    if let ownerID = gameInfo[Keys.gameOwnerKey] as? String {
                        self.acceptedUserIDs.append(ownerID)
                        self.isOwner = HCSDKCore.sharedInstance.currentUserID() == ownerID
                    }
                    
                    self.gameTitle = gameInfo[Keys.gameTitleKey] as? String
                }
            }
        }
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Process messages
    
    func processMessage(_ messages: [HCMessage]) {
        
        for message in messages {
            
            if let senderID = message.senderID, let receiptRequired = message.receiptRequired , receiptRequired == true {
                
                if HCSDKCore.sharedInstance.currentUserID() != senderID, let tempID = message.tempID,
                   let dialogID = message.dialogID
                {
                    // message receipt required by the sender, so we send the receipt here
                    MessagingManager.sharedInstance.postMessageReceipt(tempID: tempID, dialogID: dialogID, senderID: senderID, receiptStatus: .read)
                }
            }
            
            if let customData = message.customData {
                
                if let messageInfo = HCUtils.dictionaryFromJsonString(customData), let action = messageInfo["action"] as? String
                {
                    if action == Actions.Invite {
                        if let userIDs = messageInfo["invites"] as? [String] {
                            self.addPendingUsers(userIDs)
                        }
                    }
                    else if action == Actions.Decision {
                        if let accepted = messageInfo["accept"] as? Bool, let senderID = message.senderID {
                            if accepted {
                                if !self.acceptedUserIDs.contains(senderID) {
                                    self.acceptedUserIDs.append(senderID)
                                }
                                if self.rejectedUserIDs.contains(senderID) {
                                    self.rejectedUserIDs.removeObject(senderID)
                                }
                                if self.pendingUserIDs.contains(senderID) {
                                    self.pendingUserIDs.removeObject(senderID)
                                }
                            }
                            else {
                                if self.acceptedUserIDs.contains(senderID) {
                                    self.acceptedUserIDs.removeObject(senderID)
                                }
                                if !self.rejectedUserIDs.contains(senderID) {
                                    self.rejectedUserIDs.append(senderID)
                                }
                                if self.pendingUserIDs.contains(senderID) {
                                    self.pendingUserIDs.removeObject(senderID)
                                }
                            }
                        }
                    }
                    else if action == Actions.Cancel {
                        // TODO: handle cancel
                    }
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK: ListObserver
    
    func listMonitorWillChange(_ monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<HCMessage>) {
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<HCMessage>) {
    }
    
    // MARK: ListObjectObserver
    
    func listMonitor(_ monitor: ListMonitor<HCMessage>, didInsertObject object: HCMessage, toIndexPath indexPath: IndexPath)
    {
        
        // new accept, reject response received
        self.processMessage([object])
    }
    
    func listMonitor(_ monitor: ListMonitor<HCMessage>, didDeleteObject object: HCMessage, fromIndexPath indexPath: IndexPath) {
    }
    
    func listMonitor(_ monitor: ListMonitor<HCMessage>, didUpdateObject object: HCMessage, atIndexPath indexPath: IndexPath) {
    }
    
    func listMonitor(_ monitor: ListMonitor<HCMessage>, didMoveObject object: HCMessage, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
    }
    
    // MARK: - Actions
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return acceptedUserIDs.count
        }
        if section == 1 {
            return rejectedUserIDs.count
        }
        if section == 2 {
            return pendingUserIDs.count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.isOwner && (indexPath as NSIndexPath).section == 3 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CancelActionButtonCell", for: indexPath) as? CancelActionButtonCell
            cell?.delegate = self
            
            return cell!
        }
        else if !self.isOwner && (indexPath as NSIndexPath).section == 3 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConfirmRejectTableViewCell", for: indexPath) as? ConfirmRejectTableViewCell
            cell?.delegate = self
            
            return cell!
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttendanceCell", for: indexPath) as? AttendanceCell
            
            var userID: String? = nil
            
            if (indexPath as NSIndexPath).section == 0 {
                userID = self.acceptedUserIDs[(indexPath as NSIndexPath).row]
                cell?.checkMarkView.image = UIImage(named: "ic_check_mark")
                cell?.checkMarkView.isHidden = false
            }
            else if (indexPath as NSIndexPath).section == 1 {
                userID = self.rejectedUserIDs[(indexPath as NSIndexPath).row]
                cell?.checkMarkView.image = UIImage(named: "ic_stop_mark")
                cell?.checkMarkView.isHidden = false
            }
            else if (indexPath as NSIndexPath).section == 2{
                userID = self.pendingUserIDs[(indexPath as NSIndexPath).row]
                cell?.checkMarkView.isHidden = true
            }
            
            if let id = userID, let user = CoreStoreManager.store()?.fetchOne(From(HCUser.self), Where("userID == %@", id)), let avatar = user.avatar, let url = URL(string: avatar)
            {
                cell?.avatarImageView.af_setImage(withURL: url)
            }
            
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader
        {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                                   withReuseIdentifier:PlayerSectionHeaderView.identifier, for: indexPath) as! PlayerSectionHeaderView
            if (indexPath as NSIndexPath).section == 0 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Accepted
            }
            if (indexPath as NSIndexPath).section == 1 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Rejected
            }
            if (indexPath as NSIndexPath).section == 2 {
                headerView.sectionHeaderLabel.text = AttendeesCategory.Pending
            }
            
            return headerView
        }else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if self.isOwner && (indexPath as NSIndexPath).section == 3 {
            return CGSize(width: collectionView.w - 40, height: 50)
        }
        if !self.isOwner && (indexPath as NSIndexPath).section == 3 {
            return CGSize(width: collectionView.w - 40, height: 50)
        }
        else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(10, 20, 10, 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        if section == 0 {
            return CGSize(width: collectionView.w, height: 30)
        }
        if section == 1 {
            return CGSize(width: collectionView.w, height: 30)
        }
        if section == 2 {
            return CGSize(width: collectionView.w, height: 30)
        }
        
        return CGSize.zero
    }
    
    // MARK: Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "inviteUserSegue" {
            
            if let inviteUserVC = segue.destination as? InviteUserViewController {
                
                inviteUserVC.delegate = self
            }
            
        }
    }
    
    // MARK: InviteUserViewControllerDelegate
    
    func usersSelected(_ users: [String]) {
        
        var newUsers = [String]()
        
        for userID in users {
            if !self.pendingUserIDs.contains(userID) && !self.acceptedUserIDs.contains(userID) && !self.rejectedUserIDs.contains(userID)
            {
                newUsers.append(userID)
            }
        }
        
        // add invited users to the dialog
        if let dialogID = self.gameAttendanceDialogID {
            
            DialogsManager.sharedInstance.addMembersToDialog(dialogID, members: newUsers, completion: { (error) in
                
                if let err = error {
                    
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    
                    let inviteUsersJSON = self.inviteUsersJSON(newUsers)
                    
                    MessagingManager.sharedInstance.sendMessageWithCustomJSON("Invite to game\(self.gameTitle!)", customJSON: inviteUsersJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, requireReceipt: true, completion: { (success, error) in
                        
                        if let err = error {
                            self.showErrorWithMessage(err.localizedDescription)
                        }
                        else {
                            self.addPendingUsers(newUsers)
                            self.collectionView.reloadData()
                        }
                    })
                }
            })
            
        }
    }
    
    // MARK: add pending user
    
    func addPendingUsers(_ newUsers: [String]) {
        
        var addedUsers = [String]()
        for userID in newUsers {
            if !self.pendingUserIDs.contains(userID) && !self.acceptedUserIDs.contains(userID) && !self.rejectedUserIDs.contains(userID)
            {
                addedUsers.append(userID)
            }
        }
        self.pendingUserIDs.append(contentsOf: addedUsers)
        self.collectionView.reloadData()
    }
    
    // MARK: custom message jsons
    
    func inviteUsersJSON(_ userIDs: [String]) -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Invite
        json["invites"] = userIDs
        return json
    }
    
    func decisionJSON(_ accept: Bool) -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Decision
        json["accept"] = accept
        return json
    }
    
    func cancelJSON() -> NSDictionary {
        let json = NSMutableDictionary()
        json["action"] = Actions.Decision
        return json
    }
    
    // MARK: CancelActionButtonCellDelegate, ConfirmRejectTableViewCellDelegate
    
    func cancelButtonTapped(_ cell: CancelActionButtonCell) {
        // TODO: implement cancel
    }
    
    func rejectButtonTapped(_ cell: ConfirmRejectTableViewCell) {
        
        self.showLoading("")
        if let dialogID = self.gameAttendanceDialogID {
            
            let acceptedJSON = self.decisionJSON(false)
            MessagingManager.sharedInstance.sendMessageWithCustomJSON("Rejected to join game\(self.gameTitle)", customJSON: acceptedJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, completion: { (success, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                self.hideHUD()
            })
        }
    }
    
    func acceptButtonTapped(_ cell: ConfirmRejectTableViewCell) {
        
        if let dialogID = self.gameAttendanceDialogID {
            
            self.showLoading("")
            let acceptedJSON = self.decisionJSON(true)
            MessagingManager.sharedInstance.sendMessageWithCustomJSON("Accepted to join game\(self.gameTitle)", customJSON: acceptedJSON, dialogID: dialogID, dialogType: HCSDKConstants.kMessageTypeGroup, completion: { (success, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                self.hideHUD()
            })
        }
    }
    
    // MARK: MessagingManagerDelegate
    
    func didUpdateMessageReceiptStatus(_ dialogID: String, messageID: String, status: MessageReceiptStatus) {
        
        if status == .received {
            
            NSLog("message is received: %@, %@", messageID, dialogID)
        }
        else if status == .read {
            
            NSLog("message is read: %@, %@", messageID, dialogID)
        }
    }
    
}
