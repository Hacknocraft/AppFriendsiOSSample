//
//  GCMessageReceiptViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore

import AppFriendsUI

class GCMessageReceiptViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MessagingManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var seenByUsers: [String] = [String]()
    var unseenByUsers: [String] = [String]()
    
    var _messageTempID: String
    var _messageID: String
    var _messageSenderID: String
    var _dialogID: String
    
    init (messageTempID: String, messageID: String, senderID: String, dialogID: String) {
        
        _messageTempID = messageTempID
        _messageID = messageID
        _messageSenderID = senderID
        _dialogID = dialogID

        super.init(nibName: "GCMessageReceiptViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessagingManager.sharedInstance.delegate = self

        self.title = "Message Receipt"
        
        let cellNib = UINib(nibName: "GCReceiptTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "GCReceiptTableViewCell")
        
        let headerNib = UINib(nibName: "GCReceiptHeader", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "GCReceiptHeader")
        
        self.tableView.backgroundColor = AppFriendsColor.coolGreyLighter
        self.tableView.separatorColor = AppFriendsColor.coolGray
        self.tableView.alpha = 0
        self.tableView.tableFooterView = UIView()
        
        if var members = DialogsManager.sharedInstance.memberIDsInDialog(_dialogID), let currentUserID = HCSDKCore.sharedInstance.currentUserID()
        {
            // exclude the current user
            members.removeObject(currentUserID)
            self.unseenByUsers.append(contentsOf: members)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.loadReceipts()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Load data
    
    func loadReceipts() {
        
        self.showLoading("Loading receipts")
        HCSDKCore.sharedInstance.startRequest(httpMethod: "GET", path: "/messages/\(_messageTempID)/receipts", parameters: nil, completion: { [weak self](response, error) in
            
            UIView.animate(withDuration: 0.2, animations: { 
                
                self?.tableView.alpha = 1
            })
            
            if let err = error {
                self?.showErrorWithMessage(err.localizedDescription)
            }
            else if let json = response as? [[String: AnyObject]] {
                self?.hideHUD()
                for userInfo in json {
                    
                    if let userID = userInfo["user_id"] as? String, let status = userInfo["status"] as? String {
                        
                        if MessageReceiptStatus.status(status) == .read {
                            
                            self?.addSeenUser(userID)
                        }
                    }
                }
            }
            
            self?.tableView.reloadData()
            })
    }

    func addSeenUser(_ userID: String) {
        
        if self.unseenByUsers.contains(userID) {
            self.unseenByUsers.removeObject(userID)
        }
        if !self.seenByUsers.contains(userID) {
            self.seenByUsers.append(userID)
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 { // seen
            
            return self.seenByUsers.count
        }
        else { // not seen
         
            return self.unseenByUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GCReceiptTableViewCell", for: indexPath) as! GCReceiptTableViewCell
        
        let userID = (indexPath as NSIndexPath).section == 0 ? seenByUsers[(indexPath as NSIndexPath).row] : unseenByUsers[(indexPath as NSIndexPath).row]
        cell.userNameLabel.text = UsersDataBase.sharedInstance.findUserName(userID)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && self.seenByUsers.count <= 0 {
            return 0
        }
        
        return 47
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 && self.seenByUsers.count <= 0 {
            return nil
        }
        
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GCReceiptHeader") as? GCReceiptHeader
        {
            header.backgroundView = UIView(x: 0, y: 0, w: tableView.w, h: 47)
            header.backgroundView!.backgroundColor = AppFriendsColor.coolGreyLighter
            header.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)
            
            if section == 0
            {
                header.headerTitle.text = "SEEN"
                header.icon.image = UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate)
                header.icon.tintColor = AppFriendsColor.green!
            }
            else {
                header.headerTitle.text = "NOT SEEN"
                header.icon.image = UIImage(named: "ic_clear")?.withRenderingMode(.alwaysTemplate)
                header.icon.tintColor = AppFriendsColor.red!
            }
            
            return header
        }
        
        return nil
    }
    
    // MARK: - MessagingManagerDelegate
    
    func didUpdateMessageReceiptStatus(_ dialogID: String, messageID: String, byUserID: String, status: MessageReceiptStatus) {
        
        if messageID == _messageID && status == .read{
            
            // a message is read by a user
            DispatchQueue.main.async(execute: {
                self.addSeenUser(byUserID)
                // can improve here to have animation
                self.tableView.reloadData()
            })
        }
    }
    
}
