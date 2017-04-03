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

class GCMessageReceiptViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var seenByUsers = [AFUser]()
    var unseenByUsers = [AFUser]()
    
    var _message: AFMessage
    var _dialog: AFDialog?
    
    init (message: AFMessage) {
        
        _message = message

        super.init(nibName: "GCMessageReceiptViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Message Receipt"
        
        let cellNib = UINib(nibName: "GCReceiptTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "GCReceiptTableViewCell")
        
        let headerNib = UINib(nibName: "GCReceiptHeader", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "GCReceiptHeader")
        
        self.tableView.backgroundColor = AppFriendsColor.coolGreyLighter
        self.tableView.separatorColor = AppFriendsColor.coolGray
        self.tableView.alpha = 0
        self.tableView.tableFooterView = UIView()

        if let dialogID = _message.dialogID {
            AFDialog.getDialog(dialogID: dialogID, completion: { (dialog, error) in
                if error != nil {
                    self.showErrorWithMessage(error?.localizedDescription)
                } else {
                    self._dialog = dialog
                    if let members = dialog?.members {
                        self.unseenByUsers.append(contentsOf: members)
                        if let currentUser = AFUser.currentUser() {
                            self.unseenByUsers.removeFirst(currentUser)
                        }
                        self.tableView.reloadData()
                    }
                }
            })
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

        _message.getReceipts { [weak self] (receivedUserIDs, readUserIDs, error) in

            UIView.animate(withDuration: 0.2, animations: {

                self?.tableView.alpha = 1
            })

            if let err = error {
                self?.showErrorWithMessage(err.localizedDescription)
            }
            else if let read = readUserIDs {
                self?.hideHUD()
                for userID in read {
                    self?.addSeenUser(byID: userID)
                }
            }
        }
    }

    func addSeenUser(byID userID: String) {
        AFUser.getUser(userID: userID) { (user, error) in
            if let userObject = user {
                self.addSeenUser(userObject)
            }
        }
    }

    func addSeenUser(_ user: AFUser) {
        
        if self.unseenByUsers.contains(user) {
            self.unseenByUsers.removeFirst(user)
        }
        if !self.seenByUsers.contains(user) {
            self.seenByUsers.append(user)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if self.seenByUsers.count > 0 {
            sections += 1
        }
        if self.unseenByUsers.count > 0 {
            sections += 1
        }
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && self.seenByUsers.count > 0 { // seen
            
            return self.seenByUsers.count
        }
        else { // not seen
         
            return self.unseenByUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GCReceiptTableViewCell", for: indexPath) as! GCReceiptTableViewCell
        
        let user = indexPath.section == 0 && self.seenByUsers.count > 0 ? seenByUsers[(indexPath as NSIndexPath).row] : unseenByUsers[(indexPath as NSIndexPath).row]
        cell.userNameLabel.text = UsersDataBase.sharedInstance.findUserName(user.id)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GCReceiptHeader") as? GCReceiptHeader
        {
            header.backgroundView = UIView(x: 0, y: 0, w: tableView.w, h: 47)
            header.backgroundView!.backgroundColor = AppFriendsColor.coolGreyLighter
            header.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)
            
            if section == 0 && self.seenByUsers.count > 0
            {
                header.headerTitle.text = "SEEN"
                header.icon.image = UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate)
                header.icon.tintColor = AppFriendsColor.green!
            } else {
                header.headerTitle.text = "NOT SEEN"
                header.icon.image = UIImage(named: "ic_clear")?.withRenderingMode(.alwaysTemplate)
                header.icon.tintColor = AppFriendsColor.red!
            }
            
            return header
        }
        
        return nil
    }
}
