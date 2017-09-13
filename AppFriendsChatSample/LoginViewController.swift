//
//  LoginViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/29/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

// AppFriends
import AppFriendsUI
import AppFriendsCore

// push
import Firebase
import FirebaseMessaging
import UserNotifications

/// Login view controller. We are simply logging into AppFriends here.
class LoginViewController: BaseViewController {

    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var versionLabel: UILabel?

    var currentUserInfo = [String: String]()

    override func viewWillAppear(_ animated: Bool) {

        if !AFSession.isLoggedIn() {
            self.currentUserInfo[HCSDKConstants.kUserID] = nil
            self.currentUserInfo[HCSDKConstants.kUserName] = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        userAvatarImage.layer.cornerRadius = userAvatarImage.w/2
        userAvatarImage.layer.masksToBounds = true

        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString"),
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion"),
           let versionLabel = self.versionLabel {
            versionLabel.text = "\(version) (\(build))"
        }

        // need to initialize AppFriendsUI first.
        // replace the key and secret to switch to different app
        let key = "t3i23J6cnFUjtZaupVTGowtt"
        let secret = "FIVeZO8ocQD5XJZ1HAyhYgtt"

        AppFriendsUI.sharedInstance.initialize(key, secret: secret) { (success, error) in

            if success {
                if AFSession.isLoggedIn() {
                    self.fetchCurrentUserInfo()
                } else {
                    self.layoutViews()
                }

            } else {
                self.showErrorWithMessage(error?.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchCurrentUserInfo() {

        DispatchQueue.main.async {

            if AFSession.isLoggedIn(), let currentUserID = HCSDKCore.sharedInstance.currentUserID() {

                self.showLoading("loading user info")
                AFUser.getUser(userID: currentUserID, completion: { [weak self] (user, error) in

                    if let err = error {
                        self?.showErrorWithMessage(err.localizedDescription)
                    } else {
                        self?.hideHUD()
                        self?.currentUserInfo[HCSDKConstants.kUserName] = user?.username
                        self?.currentUserInfo[HCSDKConstants.kUserAvatar] = user?.avatarURL
                        self?.currentUserInfo[HCSDKConstants.kUserID] = user?.id
                        self?.layoutViews()
                    }
                })
            }
        }
    }

    func layoutViews() {

        if AFSession.isLoggedIn() {
            self.leftButton.setTitle("Log Out", for: UIControlState())
            self.rightButton.setTitle("Continue", for: UIControlState())
        } else {
            self.leftButton.setTitle("Random User", for: UIControlState())
            self.rightButton.setTitle("Log In", for: UIControlState())
        }

        self.userIDTextField.text = self.currentUserInfo[HCSDKConstants.kUserID]
        self.userNameTextField.text = self.currentUserInfo[HCSDKConstants.kUserName]

        if let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar], let url = URL(string: avatar) {
            let placeholder = UIImage.materialDesignIconWithName(.gmdPerson,
                                                                 textColor: HCColorPalette.avatarColor,
                                                                 size: CGSize(width: 25, height: 25),
                                                                 backgroundColor: HCColorPalette.avatarBackgroundColor!)
            self.userAvatarImage.af_setImage(withURL: url, placeholderImage: placeholder)
        } else {
            self.userAvatarImage.image = nil
        }
    }

    func goToMainView() {

        // load followers and the followings users before going to main view
        UsersDataBase.sharedInstance.loadFollowers()
        UsersDataBase.sharedInstance.loadFollowings()
        UsersDataBase.sharedInstance.loadFriends()

        let storyboardName = UIDevice.current.userInterfaceIdiom == .pad ? "Mainipad" : "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "TabbarController") as? UITabBarController
        let profileNav = mainVC?.viewControllers![0] as? UINavigationController
        let profileVC = ProfileViewController(userID: HCSDKCore.sharedInstance.currentUserID())
        profileNav?.setViewControllers([profileVC], animated: true)

        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {

            mainVC?.delegate = app

            // ipad ChatSplitViewController

            if UIDevice.current.userInterfaceIdiom == .pad {
                let chatSplit = storyboard
                    .instantiateViewController(withIdentifier: "ChatSplitViewController") as? UISplitViewController
                chatSplit?.delegate = app
            }

            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {

                window.rootViewController = mainVC

            }, completion: { (_) in

            })
        }

    }

    // MARK: - Actions

    @IBAction func leftButtonTapped(_ sender: AnyObject) {

        // logout the user
        if AFSession.isLoggedIn() {

            AFPushNotification.unregisterDeviceForPushNotification(completion: { (error) in
                if error == nil {
                    AFSession.logout()
                    // reset the view after logout
                    self.currentUserInfo.removeAll()
                    self.layoutViews()
                } else {
                    self.showErrorWithMessage(error?.localizedDescription)
                }
            })

        } else {

            // generate a random user from randomuser.me
            self.showLoading("Generating random user")

            Alamofire.request("https://randomuser.me/api/",
                              method: .get,
                              parameters: nil,
                              encoding: JSONEncoding.default)
            .responseJSON(completionHandler: { (response) in

                    if let requestError = response.result.error {
                        self.showErrorWithMessage(requestError.localizedDescription)

                    } else if let json = response.result.value as? [String: AnyObject] {
                        self.hideHUD()
                        if let results = json["results"] as? [[String: AnyObject]] {
                            let data = results[0]
                            if let nameInfo = data["name"] as? [String: String],
                                let loginInfo = data["login"] as? [String: String],
                                let pictureInfo = data["picture"] as? [String: String] {

                                let userID = loginInfo["md5"]
                                let userName = "\(nameInfo["first"] ?? "") \(nameInfo["last"] ?? "")"
                                let userAvatar = pictureInfo["medium"]
                                self.currentUserInfo[HCSDKConstants.kUserName] = userName
                                self.currentUserInfo[HCSDKConstants.kUserID] = userID
                                self.currentUserInfo[HCSDKConstants.kUserAvatar] = userAvatar
                            }
                            self.layoutViews()
                        }
                    }
                })
        }
    }

    @IBAction func rightButtonTapped(_ sender: AnyObject) {

        // login
        if AFSession.isLoggedIn() {
            self.goToMainView()
        } else {

            if self.currentUserInfo[HCSDKConstants.kUserID] == nil {
                self.currentUserInfo[HCSDKConstants.kUserID] = self.userIDTextField.text
            }
            if self.currentUserInfo[HCSDKConstants.kUserName] == nil {
                self.currentUserInfo[HCSDKConstants.kUserName] = self.userNameTextField.text
            }

            if Environment.current == .testing {
                self.currentUserInfo[HCSDKConstants.kUserID] = "test"
                self.currentUserInfo[HCSDKConstants.kUserName] = "test"
            }

            if let username = self.currentUserInfo[HCSDKConstants.kUserName],
                let userID = self.currentUserInfo[HCSDKConstants.kUserID] {

                self.showLoading("logging in ...")
                AFSession.login(username: username, userID: userID, completion: { (token, error) in
                    if let err = error {
                        self.showErrorWithMessage(err.localizedDescription)
                    } else {

                        if let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar] {
                            AFUser.updateUserAvatar(avatar: avatar, completion: { (_) in
                                // ignoring error here
                                self.hideHUD()
                                self.goToMainView()
                            })
                        } else {
                            self.hideHUD()
                            self.goToMainView()
                        }

                        // register for push notification
                        if let pushToken = InstanceID.instanceID().token() {
                            AFPushNotification.registerDeviceForPushNotification(pushToken: pushToken)
                        }
                    }
                })
            }
        }
    }
}
