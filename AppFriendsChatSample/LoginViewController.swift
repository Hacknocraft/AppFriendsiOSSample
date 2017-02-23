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

import AppFriendsUI
import AppFriendsCore

// jeff.cohen+af@gc.com
// 123456

// push
import Firebase
import FirebaseMessaging
import UserNotifications

class LoginViewController: BaseViewController {

    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel?
    
    var currentUserInfo = [String: String]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if !appFriendsCore.isLogin() {
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
           let versionLabel = self.versionLabel
        {
            versionLabel.text = "\(version) (\(build))"
        }
        
        // need to initialize Coredata for AppFriendsUI first
        var key = ""
        var secret = ""
        
        if Environment.current == .sandbox
        {
            key = "c3ZsINZMGHdGmbY3S6pcVgtt"
            secret = "FhsajDeh6XXBF143m82sKwtt"
        }
        else if (Environment.current == .testing)
        {
            key = "A5de6lwrkIsnRhraNVsSzgtt"
            secret = "D8EFZB2xtGSYd2vDBzWPyQtt"
        }
        else if (Environment.current == .staging)
        {
            key = "t3i23J6cnFUjtZaupVTGowtt"
            secret = "FIVeZO8ocQD5XJZ1HAyhYgtt"
        }
        else {
//            key = "QVdG4xshxzgb7EWouxMfowtt"
//            secret = "Ii5vfrjl98ln7gUhR1hWQgtt"
            key = "t3i23J6cnFUjtZaupVTGowtt"
            secret = "FIVeZO8ocQD5XJZ1HAyhYgtt"
        }
        
        AppFriendsUI.sharedInstance.initialize(key, secret: secret) { (success, error) in
            
            if success {
                let appFriendsCore = HCSDKCore.sharedInstance
                if appFriendsCore.isLogin() {
                    self.fetchCurrentUserInfo()
                }
                else {
                    self.layoutViews()
                }
                
            }
            else {
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
            
            let appFriendsCore = HCSDKCore.sharedInstance
            if appFriendsCore.isLogin(), let currentUserID = appFriendsCore.currentUserID() {
                
                self.showLoading("loading user info")
                AppFriendsUserManager.sharedInstance.fetchUserInfo(currentUserID, completion: { [weak self](response, error) in
                    
                    if let err = error {
                        self?.showErrorWithMessage(err.localizedDescription)
                    }
                    else
                    {
                        self?.hideHUD()
                        if let json = response as? [String: AnyObject]
                        {
                            self?.currentUserInfo[HCSDKConstants.kUserName] = json[HCSDKConstants.kUserName] as? String
                            self?.currentUserInfo[HCSDKConstants.kUserAvatar] = json[HCSDKConstants.kUserAvatar] as? String
                            self?.currentUserInfo[HCSDKConstants.kUserID] = json[HCSDKConstants.kUserID] as? String
                            self?.layoutViews()
                        }
                    }
                })
            }
        }
    }
    
    func layoutViews() {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            self.leftButton.setTitle("Log Out", for: UIControlState())
            self.rightButton.setTitle("Continue", for: UIControlState())
        }
        else {
            self.leftButton.setTitle("Random User", for: UIControlState())
            self.rightButton.setTitle("Log In", for: UIControlState())
        }
        
        self.userIDTextField.text = self.currentUserInfo[HCSDKConstants.kUserID]
        self.userNameTextField.text = self.currentUserInfo[HCSDKConstants.kUserName]
        
        if let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar], let url = URL(string: avatar)
        {
            let placeholder = UIImage.GMDIconWithName(.gmdPerson, textColor: HCColorPalette.avatarColor, size: CGSize(width: 25, height: 25), backgroundColor: HCColorPalette.avatarBackgroundColor!)
            self.userAvatarImage.af_setImage(withURL: url, placeholderImage: placeholder)
        }
        else {
            self.userAvatarImage.image = nil
        }
    }

    func goToMainView() {
        
        let storyboardName = UIDevice.current.userInterfaceIdiom == .pad ? "Mainipad" : "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "TabbarController") as? UITabBarController
        let profileNav = mainVC?.viewControllers![0] as? UINavigationController
        let profileVC = ProfileViewController(userID: HCSDKCore.sharedInstance.currentUserID())
        profileNav?.setViewControllers([profileVC], animated: true)
        
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            
            mainVC?.delegate = app
            
            // ipad ChatSplitViewController
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                let chatSplit = storyboard.instantiateViewController(withIdentifier: "ChatSplitViewController") as? UISplitViewController
                chatSplit?.delegate = app
            }
            
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {

                window.rootViewController = mainVC
                
            },completion: { (finished) in
                                        
                                        
            })
        }
        
    }
    
    // MARK: - Actions

    @IBAction func leftButtonTapped(_ sender: AnyObject) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            
            AppFriendsUI.sharedInstance.logout()
            
            // reset the view after logout
            currentUserInfo.removeAll()
            self.layoutViews()
        }
        else {
            
            // generate a random user from randomuser.me
            self.showLoading("Generating random user")
            
            
            Alamofire.request("https://randomuser.me/api/", method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON(completionHandler: { (response) in
                    
                    if let requestError = response.result.error {
                        self.showErrorWithMessage(requestError.localizedDescription)
                        
                    }
                    else if let json = response.result.value as? [String: AnyObject]
                    {
                        self.hideHUD()
                        if let results = json["results"] as? [[String: AnyObject]]
                        {
                            let data = results[0]
                            let nameInfo = data["name"] as! [String: String]
                            let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
                            let loginInfo = data["login"] as! [String: String]
                            let userID = loginInfo["md5"]
                            let pictureInfo = data["picture"] as! [String: String]
                            let userAvatar = pictureInfo["medium"]
                            
                            self.currentUserInfo[HCSDKConstants.kUserName] = userName
                            self.currentUserInfo[HCSDKConstants.kUserID] = userID
                            self.currentUserInfo[HCSDKConstants.kUserAvatar] = userAvatar
                            
                            self.layoutViews()
                        }
                    }
                })
        }
    }
    
    @IBAction func rightButtonTapped(_ sender: AnyObject) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            self.goToMainView()
        }
        else {
            
            if self.currentUserInfo[HCSDKConstants.kUserID] == nil {
                self.currentUserInfo[HCSDKConstants.kUserID] = self.userIDTextField.text
            }
            if self.currentUserInfo[HCSDKConstants.kUserName] == nil {
                self.currentUserInfo[HCSDKConstants.kUserName] = self.userNameTextField.text
            }
            
            if (Environment.current == .testing)
            {
                self.currentUserInfo[HCSDKConstants.kUserID] = "test"
                self.currentUserInfo[HCSDKConstants.kUserName] = "test"
            }
            
            self.showLoading("logging in ...")
            appFriendsCore.loginWithUserInfo(self.currentUserInfo as [String : AnyObject]?)
            { (response, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID(),
                        let avatar = self.currentUserInfo[HCSDKConstants.kUserAvatar]
                    {
                        AppFriendsUserManager.sharedInstance.updateUserInfo(currentUserID, userInfo: [HCSDKConstants.kUserAvatar: avatar as AnyObject], completion: { (response, error) in
                            
                            self.hideHUD()
                            self.goToMainView()
                        })
                    }
                    else {
                        self.hideHUD()
                        self.goToMainView()
                    }
                    
                    // register for push notification
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID(), let pushToken = FIRInstanceID.instanceID().token()
                    {
                        HCSDKCore.sharedInstance.registerDeviceForPush(currentUserID, pushToken: pushToken)
                    }
                }
            }
        }
    }
}
