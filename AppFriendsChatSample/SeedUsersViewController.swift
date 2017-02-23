//
//  SeedUsersViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/25/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AlamofireImage
import AppFriendsCore

import AppFriendsUI

// push
import Firebase
import FirebaseMessaging
import UserNotifications

class SeedUsersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userInfos: [[String: AnyObject]] = [[String: AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()

        self.tableView.tableHeaderView = createHeaderView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        loadData()
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
        // load seed users from a json
        if let url = Bundle.main.url(forResource: "user_seeds", withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                do {
                    let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let dictionary = object as? [String: AnyObject] {
                        
                        if let users = dictionary["results"] as? [[String: AnyObject]] {
                            
                            userInfos.append(contentsOf: users)
                        }
                    }
                } catch {
                    print("Error!! Unable to parse: user_seeds.json")
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userInfos.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row < userInfos.count
        {
            let data = userInfos[(indexPath as NSIndexPath).row]
            let nameInfo = data["name"] as! [String: String]
            let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
            let loginInfo = data["login"] as! [String: String]
            let userID = loginInfo["md5"]
            let pictureInfo = data["picture"] as! [String: String]
            let userAvatar = pictureInfo["medium"]
            
            
            var currentUserInfo = [String: String]()
            currentUserInfo[HCSDKConstants.kUserName] = userName
            currentUserInfo[HCSDKConstants.kUserID] = userID
            currentUserInfo[HCSDKConstants.kUserAvatar] = userAvatar
            
            self.login(currentUserInfo)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        
        if (indexPath as NSIndexPath).row < userInfos.count
        {
            let data = userInfos[(indexPath as NSIndexPath).row]
            let nameInfo = data["name"] as! [String: String]
            let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
            let pictureInfo = data["picture"] as! [String: String]
            let placeholder = UIImage.GMDIconWithName(.gmdPerson, textColor: HCColorPalette.avatarColor, size: CGSize(width: 25, height: 25), backgroundColor: HCColorPalette.avatarBackgroundColor!)
            
            if let userAvatar = pictureInfo["thumbnail"], let url = URL(string: userAvatar) {
                cell.imageView?.af_setImage(withURL: url, placeholderImage: placeholder)
            }
            
            cell.textLabel?.text = userName
        }
        
        return cell
    }
    
    func createHeaderView() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 90))
        
        let leaveConversationButton = UIButton(type: .custom)
        leaveConversationButton.frame = CGRect(x: 30, y: 40, width: 240, height: 40)
        leaveConversationButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        footerView.addSubview(leaveConversationButton)
        
        leaveConversationButton.backgroundColor = UIColor.clear
        leaveConversationButton.layer.borderColor = HCColorPalette.chatLeaveConversationColor?.cgColor
        leaveConversationButton.layer.cornerRadius = 4
        leaveConversationButton.layer.masksToBounds = true
        leaveConversationButton.layer.borderWidth = 1
        leaveConversationButton.setTitleColor(HCColorPalette.chatLeaveConversationColor, for: .normal)
        leaveConversationButton.setTitle("Cancel", for: UIControlState())
        leaveConversationButton.titleLabel?.font = HCFont.BoldButtonFontName
        leaveConversationButton.addTarget(self, action: #selector(SeedUsersViewController.cancel), for: .touchUpInside)
        
        return footerView
    }
    
    func cancel() {
        
        self.dismissVC(completion: nil)
    }
    
    // MARK: Login
    
    func login(_ userInfo: [String: String]) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        if appFriendsCore.isLogin() {
            self.showErrorWithMessage("You are already logged in, please log out first")
        }
        else {
            self.showLoading("logging in ...")
            appFriendsCore.loginWithUserInfo(userInfo as [String : AnyObject]?)
            { (response, error) in
                
                if let err = error {
                    self.showErrorWithMessage(err.localizedDescription)
                }
                else {
                    
                    if let currentUserID = HCSDKCore.sharedInstance.currentUserID(),
                        let avatar = userInfo[HCSDKConstants.kUserAvatar]
                    {
                        AppFriendsUserManager.sharedInstance.updateUserInfo(currentUserID, userInfo: [HCSDKConstants.kUserAvatar: avatar as AnyObject], completion: { (response, error) in
                            
                            self.hideHUD()
                            self.goToMainView()
                        })
                        
                        // register for push notification
                        if let pushToken = FIRInstanceID.instanceID().token()
                        {
                            HCSDKCore.sharedInstance.registerDeviceForPush(currentUserID, pushToken: pushToken)
                        }
                    }
                    else {
                        self.hideHUD()
                        self.goToMainView()
                    }
                }
            }
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
            
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                
                window.rootViewController = mainVC
                
                },completion: { (finished) in
                    
                    
            })
        }
    }
}
