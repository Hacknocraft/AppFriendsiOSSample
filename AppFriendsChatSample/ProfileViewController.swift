//
//  MasterViewController.swift
//  AppFriendsUIDev
//
//  Created by HAO WANG on 8/18/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

import AppFriendsUI

import AppFriendsCore
import CoreStore
import AlamofireImage

class ProfileViewController: UITableViewController {
    
    var _chatButton: UIButton?
    var _followButton: UIButton?
    
    var _userAvatarUR: String?
    var _userName: String?
    
    var _userID: String?
    
    init(userID: String?) {
        
        super.init(style: .plain)
        
        _userID = userID
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Profile"
        
        let tabBarImage = UIImage.GMDIconWithName(.gmdPerson, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Profile", image: tabBarImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
        self.tableView.separatorColor = HCColorPalette.tableSeparatorColor
        
        self.view.backgroundColor = UIColor(r: 13, g: 14, b: 40)
        
        self.tableView.register(UINib(nibName: "UserProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "UserProfileTableViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
            
        // create chat button
        layoutNavigationBarItem()
        
        // observe new message
        startObservingNewMessagesAndUpdateBadge()
        
        DialogsManager.sharedInstance.getTotalUnreadMessageCount({ (count) in
            self._chatButton?.badge = "\(count)"
        })
        
        if _userID == nil
        {
            _userID = HCSDKCore.sharedInstance.currentUserID()
        }
        
        if let currentUserID = _userID
        {
            AppFriendsUserManager.sharedInstance.fetchUserInfo(currentUserID) { (response, error) in
                
                if let json = response as? [String: AnyObject] {
                    
                    if let avatar = json[HCSDKConstants.kUserAvatar] as? String {
                        self._userAvatarUR = avatar
                    }
                    
                    if let userName = json[HCSDKConstants.kUserName] as? String {
                        self._userName = userName
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            if _userID == HCSDKCore.sharedInstance.currentUserID()
            {
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DialogsManager.sharedInstance.getTotalUnreadMessageCount({ (count) in
            self._chatButton?.badge = "\(count)"
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
    }
    
    // MARK: - Observe Messages
    
    func startObservingNewMessagesAndUpdateBadge()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarBadge), name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
    }
    
    func updateTabBarBadge(_ notification: Notification?)
    {
        DispatchQueue.main.async(execute: {
            
            if let count = notification?.object as? NSNumber {
                
                self._chatButton?.badge = "\(count)"
            }
            else {
                
                self._chatButton?.badge = "\(DialogsManager.sharedInstance.totalUnreadMessages)"
            }
        })
    }
    
    func isCurrentUsr() -> Bool {
        return _userID == HCSDKCore.sharedInstance.currentUserID()
    }
    
    // MARK: - UI
    
    func layoutNavigationBarItem() {
        
        if isCurrentUsr()
        {
            // if it's the current user, we show the chat button
            
            _chatButton = UIButton(type: .custom)
            _chatButton?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            _chatButton?.setImage(UIImage(named: "chat"), for: .normal)
            _chatButton?.addTarget(self, action: #selector(ProfileViewController.chat(_:)), for: .touchUpInside)
            
            let chatBarItem = UIBarButtonItem(customView: _chatButton!)
            self.navigationItem.rightBarButtonItem = chatBarItem
            
            
            let logoutButton = UIButton(type: .custom)
            logoutButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            logoutButton.setImage(UIImage(named: "ic_logout"), for: .normal)
            logoutButton.addTarget(self, action: #selector(ProfileViewController.logout(_:)), for: .touchUpInside)
            
            let logoutItem = UIBarButtonItem(customView: logoutButton)
            self.navigationItem.leftBarButtonItem = logoutItem
        }
        else
        {
            // if it's not the current user, we show the follow button
            
            if let currentUser = HCUser.currentUser() {
                
                _followButton = UIButton(type: .custom)
                _followButton?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                _followButton?.addTarget(self, action: #selector(ProfileViewController.followButtonTapped(_:)), for: .touchUpInside)
                
                if let followingUsers = currentUser.following as? [String], let userID = _userID
                {
                    if followingUsers.contains(userID)
                    {
                        _followButton?.setImage(UIImage(named: "unfollow"), for: .normal)
                        
                    }
                    else {
                        
                        _followButton?.setImage(UIImage(named: "follow"), for: .normal)
                        
                    }
                }
                else {
                    
                    _followButton?.setImage(UIImage(named: "follow"), for: .normal)
                }
                let followBarItem = UIBarButtonItem(customView: _followButton!)
                self.navigationItem.rightBarButtonItem = followBarItem
            }
        }
    }
    
    // MARK: - Actions
    
    func logout(_ sender: AnyObject) {
        
        AppFriendsUI.sharedInstance.logout { (error) in
            if error != nil {
                
                self.showAlert("Log Out Error", message: error.debugDescription)
            }
            else {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                
                if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
                    
                    UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                        
                        window.rootViewController = loginVC
                        
                    },completion: { (finished) in
                        
                    })
                }
            }
        }
    }
    
    func chat(_ sender: AnyObject) {
        
        let chatContainer = HCChatContainerViewController(tabs: [HCTitles.dialogsTabTitle, HCTitles.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.setBackgroundImage(UIImage(named: "0D0F27"), for: .default)
        self.presentVC(nav)
    }
    
    func followButtonTapped(_ sender: AnyObject) {
        
        if let currentUser = HCUser.currentUser() {
            
            if let followingUsers = currentUser.following as? [String], let userID = _userID
            {
                if followingUsers.contains(userID)
                {
                    self.unfollow(sender)
                }
                else {
                    self.follow(sender)
                }
            }
            else {
                
                self.follow(sender)
            }
        }
    }
    
    func follow(_ sender: AnyObject) {
        
        if let userID = _userID {
            
            AppFriendsUserManager.sharedInstance.followUser(userID, completion: { (response, error) in
                
                if let err = error
                {
                    self.showAlert("follow user failed", message: err.localizedDescription)
                }
                else {
                    self.showAlert("", message: "You are now following this user")
                    self._followButton?.setImage(UIImage(named: "unfollow"), for: .normal)
                }
            })
        }
    }
    
    func unfollow(_ sender: AnyObject) {
        
        if let userID = _userID {
            
            AppFriendsUserManager.sharedInstance.unfollowUser(userID, completion: { (response, error) in
                
                if let err = error
                {
                    self.showAlert("Unfollow user failed", message: err.localizedDescription)
                }
                else {
                    self.showAlert("", message: "You unfollowed this user")
                    self._followButton?.setImage(UIImage(named: "follow"), for: .normal)
                }
            })
        }
    }
    
    // MARK: show alert
    
    func showAlert(_ title: String, message: String)
    {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
            
        }))
        self.presentVC(popup)
    }
    
    // MARK: go to chat
    
    func showChatView(_ userID: String) {
        
        DialogsManager.sharedInstance.initializeDialog([userID], dialogType: HCSDKConstants.kMessageTypeIndividual, dialogTitle: nil) { (dialogID, error) in
            
            if error != nil {
                NSLog("\(error?.localizedDescription)")
            }
            else {
                self.title = ""
                let dialogVC = HCDialogChatViewController(dialog: userID)
                self.navigationController?.pushViewController(dialogVC, animated: true)
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if HCSDKCore.sharedInstance.isLogin() {
            
            if self.isCurrentUsr() {
                return 1
            }
            else {
                return 3
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // start a chat with this user
        if (indexPath as NSIndexPath).row == 1, let userID = _userID {
            
            // find the existing or create an individual chat dialog
            CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
                
                if HCChatDialog.findDialog(userID, transaction: transaction) != nil
                {
                    DispatchQueue.main.async {
                        self.showChatView(userID)
                    }
                }
                else {
                    
                    let _ = HCChatDialog.findOrCreateDialog(userID, members: [userID], dialogTitle: self._userName, dialogType: HCSDKConstants.kMessageTypeIndividual, transaction: transaction)
                    
                    transaction.commit({ (result) in
                        
                        if result.boolValue
                        {
                            self.showChatView(userID)
                        }
                    })
                }
                
            })

        }
        else if (indexPath as NSIndexPath).row == 2, let userID = _userID {
            
            if let user = CoreStoreManager.store()?.fetchOne(From(HCUser.self), Where("userID == %@", userID))
            {
                if let blocked = user.blocked?.boolValue , blocked == true {
                    
                    AppFriendsUserManager.sharedInstance.unblockUser(userID, completion: { (response, error) in
                        if let err = error {
                            self.showAlert("Error", message: err.localizedDescription)
                        }
                        else {
                            self.showAlert("Success", message: "You have unblocked the user")
                            self.tableView.reloadData()
                        }
                    })
                }
                else {
                    
                    AppFriendsUserManager.sharedInstance.blockUser(userID, completion: { (response, error) in
                        if let err = error {
                            self.showAlert("Error", message: err.localizedDescription)
                        }
                        else {
                            self.showAlert("Success", message: "You have blocked the user")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath as NSIndexPath).row == 0 {
            
            let userProfileCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableViewCell", for: indexPath) as! UserProfileTableViewCell
            
            userProfileCell.selectionStyle = .none
            userProfileCell.usernameLabel.text = _userName
            if let avatar = _userAvatarUR, let url = URL(string: avatar) {
                userProfileCell.userAvatarView.af_setImage(withURL: url)
            }
            
            return userProfileCell
        }
        else if (indexPath as NSIndexPath).row == 1
        {
            let chatCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            chatCell.accessoryType = .disclosureIndicator
            chatCell.textLabel!.text = "Chat"
            return chatCell
        }
        else
        {
            let blockCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            blockCell.accessoryType = .none
            
            if let userID = _userID, let user = CoreStoreManager.store()?.fetchOne(From(HCUser.self), Where("userID == %@", userID))
            {
                if let blocked = user.blocked?.boolValue , blocked == true {
                    
                    blockCell.textLabel!.text = "Unblock"
                }
                else {
                    
                    blockCell.textLabel!.text = "Block"
                }
            }
            
            return blockCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).row == 0 {
            return 170
        }
        
        return 40
    }
}

