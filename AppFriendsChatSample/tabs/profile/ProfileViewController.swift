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

class ProfileViewController: UITableViewController, UserProfileTableViewCellDelegate {

    var _topChatButton: UIButton?

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

        self.tableView.tableFooterView = UIView()

        self.tableView.separatorColor = .clear
        self.tableView.separatorStyle = .none

        // create chat button
        layoutNavigationBarItem()

        self._topChatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"

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

        self._topChatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Observe Messages

    func updateTabBarBadge(_ notification: Notification?) {
        DispatchQueue.main.async(execute: {

            if let count = notification?.object as? NSNumber {

                self._topChatButton?.badge = "\(count)"
            } else {

                self._topChatButton?.badge = "\(AFDialog.totalUnreadMessageCount())"
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

            _topChatButton = UIButton(type: .custom)
            _topChatButton?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            _topChatButton?.setImage(UIImage(named: "chat"), for: .normal)
            _topChatButton?.addTarget(self, action: #selector(ProfileViewController.chat(_:)), for: .touchUpInside)

            let chatBarItem = UIBarButtonItem(customView: _topChatButton!)
            self.navigationItem.rightBarButtonItem = chatBarItem

            let logoutButton = UIButton(type: .custom)
            logoutButton.contentMode = .center
            let widthConstraint = logoutButton.widthAnchor.constraint(equalToConstant: 30)
            let heightConstraint = logoutButton.heightAnchor.constraint(equalToConstant: 30)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
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
        }
    }

    func chat(_ sender: AnyObject) {

        let chatContainer = HCChatContainerViewController(tabs: [HCStringValues.dialogsTabTitle,
                                                                 HCStringValues.contactsTabTitle])
        let nav = UINavigationController(rootViewController: chatContainer)
        nav.navigationBar.setBackgroundImage(UIImage(named: "0D0F27"), for: .default)
        self.presentVC(nav)
    }

    // MARK: UserProfileTableViewCellDelegate

    func followButtonTapped() {
        if let userID = _userID, !UsersDataBase.sharedInstance.following.contains(userID) {
            AFUser.followUser(userID: userID, completion: { (error) in
                if error != nil {
                    self.showAlert("Error", message: error?.localizedDescription ?? "")
                } else {
                    UsersDataBase.sharedInstance.following.append(userID)
                    self.tableView.reloadData()
                }
            })
        } else if let userID = _userID {
            AFUser.unfollowUser(userID: userID, completion: { (error) in
                if error != nil {
                    self.showAlert("Error", message: error?.localizedDescription ?? "")
                    self.tableView.reloadData()
                } else {
                    UsersDataBase.sharedInstance.following.removeFirst(userID)
                    self.tableView.reloadData()
                }
            })
        }
    }

    func chatButtonTapped() {
        if let userID = _userID {
            self.showChatView(userID)
        }
    }

    func blockButtonTapped() {

        if let user = _user, user.blocked {
            AFUser.unblockUser(userID: user.id, completion: { (error) in
                if let err = error {
                    self.showAlert("Error", message: err.localizedDescription)
                } else {
                    self.showAlert("Success", message: "You have unblocked the user")
                    self.tableView.reloadData()
                }
            })
        } else if let userID = _userID {
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
                guard let dialogVC = HCDialogChatViewController(dialogID: id,
                                                                supportedMessageDataTypes: .all,
                                                                requireReceipts: true,
                                                                shouldAllowTagging: true) else {
                                                                    return
                }
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

            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {

            guard let userProfileCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableViewCell",
                                                                for: indexPath) as? UserProfileTableViewCell
                else {
                    return UserProfileTableViewCell()
            }

            userProfileCell.selectionStyle = .none
            userProfileCell.delegate = self
            userProfileCell.usernameLabel.text = _userName
            if let avatar = _userAvatarUR, let url = URL(string: avatar) {
                userProfileCell.userAvatarView.af_setImage(withURL: url)
            }

            userProfileCell.followButton.isHidden = self.isCurrentUsr()
            userProfileCell.chatButton.isHidden = self.isCurrentUsr()
            userProfileCell.blockButton.isHidden = self.isCurrentUsr()

            if let userID = _userID {
                userProfileCell.followButton.isSelected = UsersDataBase.sharedInstance.following.contains(userID)
            }
            userProfileCell.blockButton.isSelected = _user?.blocked ?? false

            userProfileCell.separatorInset = UIEdgeInsets(top: 0, left: 0,
                                                          bottom: 0, right: .greatestFiniteMagnitude)

            return userProfileCell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (indexPath as NSIndexPath).row == 0 {
            return 240
        }

        return 40
    }
}
