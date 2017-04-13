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

import AlamofireImage

class ProfileViewController: UITableViewController {

    var _chatButton: UIButton?
    var _followButton: UIButton?

    var _userAvatarUR: String?
    var _userName: String?

    var _userID: String?
    var _user: AFUser?

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

        let tabBarImage = UIImage.materialDesignIconWithName(.gmdPerson,
                                                             textColor: UIColor.black,
                                                             size: CGSize(width: 30, height: 30))
        let customTabBarItem: UITabBarItem = UITabBarItem(title: "Profile",
                                                          image: tabBarImage.withRenderingMode(.alwaysOriginal),
                                                          selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem

        self.tableView.separatorColor = HCColorPalette.tableSeparatorColor

        self.view.backgroundColor = UIColor(r: 13, g: 14, b: 40)

        self.tableView.register(UINib(nibName: "UserProfileTableViewCell", bundle: nil),
                                forCellReuseIdentifier: "UserProfileTableViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")

        // create chat button
        layoutNavigationBarItem()

        // observe new message
        startObservingNewMessagesAndUpdateBadge()

        self._chatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"

        if _userID == nil {
            _userID = HCSDKCore.sharedInstance.currentUserID()
        }

        if let currentUserID = _userID {
            AFUser.getUser(userID: currentUserID, completion: { (user, _) in

                if let avatar = user?.avatarURL {
                    self._userAvatarUR = avatar
                }

                if let userName = user?.username {
                    self._userName = userName
                }

                self._user = user
                self.tableView.reloadData()
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self._chatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {

        let notificationName = AppFriendsUI.kTotalUnreadMessageCountChangedNotification
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: notificationName),
                                                  object: nil)
    }

    // MARK: - Observe Messages

    func startObservingNewMessagesAndUpdateBadge() {
        let notificationName = AppFriendsUI.kTotalUnreadMessageCountChangedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTabBarBadge),
                                               name: NSNotification.Name(rawValue: notificationName),
                                               object: nil)
    }

    func updateTabBarBadge(_ notification: Notification?) {
        DispatchQueue.main.async(execute: {

            if let count = notification?.object as? NSNumber {

                self._chatButton?.badge = "\(count)"
            } else {

                self._chatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"
            }
        })
    }

    func isCurrentUsr() -> Bool {
        return _userID == HCSDKCore.sharedInstance.currentUserID()
    }

    // MARK: - UI

    func layoutNavigationBarItem() {

        if isCurrentUsr() {
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
    }

    // MARK: - Actions

    func logout(_ sender: AnyObject) {

        AFPushNotification.unregisterDeviceForPushNotification { (error) in
            if error == nil {

                AFSession.logout { (error) in
                    if error != nil {
                        self.showAlert("Log Out Error", message: error?.localizedDescription ?? "")
                    } else {

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

                        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {

                            UIView.transition(with: window,
                                              duration: 0.3,
                                              options: .transitionFlipFromLeft,
                                              animations: {

                                window.rootViewController = loginVC

                            }, completion: { (_) in
                                NSLog("Registered device of push notification")
                            })
                        }
                    }
                }
            } else {
                self.showAlert("unregister device failed!", message: error?.localizedDescription ?? "")
            }
        }
    }

    func chat(_ sender: AnyObject) {

        let chatContainer = HCChatContainerViewController(tabs: [HCStringValues.dialogsTabTitle,
                                                                 HCStringValues.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.setBackgroundImage(UIImage(named: "0D0F27"), for: .default)
        self.presentVC(nav)
    }

    // MARK: show alert

    func showAlert(_ title: String, message: String) {
        let popup = UIAlertController(title: title, message: message, preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in

        }))
        self.presentVC(popup)
    }

    // MARK: go to chat

    func showChatView(_ userID: String) {

        AFDialog.createIndividualDialog(withUser: userID) { (dialogID, error) in

            if let err = error {
                NSLog("\(err.localizedDescription)")
            } else if let id = dialogID {
                self.title = ""
                let dialogVC = HCDialogChatViewController(dialogID: id,
                                                          supportedMessageDataTypes: .all,
                                                          requireReceipts: true,
                                                          shouldAllowTagging: true)
                self.navigationController?.pushViewController(dialogVC, animated: true)
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if AFSession.isLoggedIn() {

            if self.isCurrentUsr() {
                return 1
            } else {
                return 3
            }
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // start a chat with this user
        if (indexPath as NSIndexPath).row == 1, let userID = _userID {

            AFDialog.createIndividualDialog(withUser: userID) { (dialogID, error) in

                if let err = error, let description = error?.localizedDescription {
                    NSLog("\(err.localizedDescription)")
                    self.showAlert("Error", message: description)
                } else if let id = dialogID {
                    self.showChatView(id)
                }
            }

        } else if (indexPath as NSIndexPath).row == 2, let userID = _userID {

            if let user = _user, user.blocked {

                AFUser.unblockUser(userID: userID, completion: { (error) in

                    if let err = error {
                        self.showAlert("Error", message: err.localizedDescription)
                    } else {
                        self.showAlert("Success", message: "You have unblocked the user")
                        self.tableView.reloadData()
                    }
                })
            } else {

                AFUser.blockUser(userID: userID, completion: { (error) in

                    if let err = error {
                        self.showAlert("Error", message: err.localizedDescription)
                    } else {
                        self.showAlert("Success", message: "You have blocked the user")
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {

            guard let userProfileCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableViewCell",
                                                                for: indexPath) as? UserProfileTableViewCell
                else {
                    return UserProfileTableViewCell()
            }

            userProfileCell.selectionStyle = .none
            userProfileCell.usernameLabel.text = _userName
            if let avatar = _userAvatarUR, let url = URL(string: avatar) {
                userProfileCell.userAvatarView.af_setImage(withURL: url)
            }

            return userProfileCell
        } else if (indexPath as NSIndexPath).row == 1 {
            let chatCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            chatCell.accessoryType = .disclosureIndicator
            chatCell.textLabel!.text = "Chat"
            return chatCell
        } else {
            let blockCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
            blockCell.accessoryType = .none

            if let user = _user, user.blocked {
                blockCell.textLabel?.text = "Unblock"
            } else {
                blockCell.textLabel!.text = "Block"
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
