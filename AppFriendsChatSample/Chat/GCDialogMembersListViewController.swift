//
//  GCDialogMembersListViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 10/19/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

import AppFriendsUI

class GCDialogMembersListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, GCDialogContactsPickerViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var userInfos: [[String: AnyObject]] = [[String: AnyObject]]()
    var _members: [String]?
    var _dialogID: String
    
    init(members: [String], dialogID: String) {
        
        _members = members
        _dialogID = dialogID
        
        super.init(nibName: "GCDialogMembersListViewController", bundle: nil)
        
        let users = UsersDataBase.sharedInstance.userInfos
        for userInfo in users {
            let loginInfo = userInfo["login"] as! [String: String]
            if let userID = loginInfo["md5"] , members.contains(userID)
            {
                userInfos.append(userInfo)
            }
        }
        
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "GCContactTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GCContactTableViewCell")
        self.tableView.backgroundColor = AppFriendsColor.coolGreyLighter
        self.tableView.tableFooterView = tableFooterView()
        self.tableView.tableHeaderView = tableHeaderView()
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem()
        self.navigationItem.rightBarButtonItem = rightBarButtonItem()
        
        self.title = "Group Members"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableFooterView() -> UIView? {
        
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 75)
        footerView.addBorderTop(size: 1, color: AppFriendsColor.coolGray!)
        
        return footerView
    }
    
    func tableHeaderView() -> UIView? {
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 25)
        headerView.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)
        
        return headerView
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GCContactTableViewCell", for: indexPath) as! GCContactTableViewCell
        
        let userInfo = self.userInfos[(indexPath as NSIndexPath).row]
        let nameInfo = userInfo["name"] as! [String: String]
        let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
        cell.userNameLabel.text = userName
        cell.userNameLabel.textColor = AppFriendsColor.charcoalGrey!
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    // MARK: - navigation items
    
    func rightBarButtonItem() -> UIBarButtonItem {
        
        // add more members
        
        let newConversationItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(GCDialogMembersListViewController.addMember))
        return newConversationItem
    }
    
    func leftBarButtonItem() -> UIBarButtonItem? {
        
        let icon = UIImage(named: "ic_left_arrow")
        let closeItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(GCDialogMembersListViewController.close))
        return closeItem
    }
    
    func close() {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func addMember() {
        
        let contactSelectionVC = GCDialogContactsPickerViewController(viewTitle:"Add Members" ,excludeUsers: _members)
        contactSelectionVC.delegate = self
        self.navigationController?.pushViewController(contactSelectionVC, animated: true)
    }
    
    // MARK: - GCDialogContactsPickerViewControllerDelegate
    
    func usersSelected(_ users: [String]) {
        
        DialogsManager.sharedInstance.addMembersToDialog(_dialogID, members: users, completion: { (error) in
            
            if error != nil {
                self.showErrorWithMessage(error?.localizedDescription)
            }
            else if users.count > 0 {
                self.showSuccessWithMessage("Added \(users.count) members.")
                
                let allUsers = UsersDataBase.sharedInstance.userInfos
                for userInfo in allUsers {
                    let loginInfo = userInfo["login"] as! [String: String]
                    if let userID = loginInfo["md5"] , users.contains(userID)
                    {
                        self.userInfos.append(userInfo)
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppFriendsUI.kDialogUpdateNotification), object: self._dialogID, userInfo: nil)
                
                self.tableView?.reloadData()
            }
        })
    }
}
