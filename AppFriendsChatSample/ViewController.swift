//
//  ViewController.swift
//  AppFriendsChatSample
//
//  Created by HAO WANG on 11/5/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let key = "A5de6lwrkIsnRhraNVsSzgtt"
        let secret = "D8EFZB2xtGSYd2vDBzWPyQtt"
        AppFriendsUI.sharedInstance.initialize(key, secret: secret) { (success, error) in
            
            if success {
                let appFriendsCore = HCSDKCore.sharedInstance
                if appFriendsCore.isLogin() {
                }
                else {
                }
            }
            else {
                print(error?.localizedDescription ?? "")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

