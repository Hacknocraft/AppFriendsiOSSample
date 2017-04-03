//
//  LocalUsersDatabase.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import Foundation
import AppFriendsCore

import AppFriendsUI

class UsersDataBase
{
    var userInfos: [[String: AnyObject]] = [[String: AnyObject]]()
    
    static let sharedInstance = UsersDataBase()
    
    func loadUsers() {
        
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

        userInfos.sort { (userA, userB) -> Bool in
            if let nameA = userA["name"] as? [String: String],
                let nameB = userB["name"] as? [String: String],
                let firstNameA =  nameA["first"], let firstNameB =  nameB["first"] {
                return firstNameA.compare(firstNameB) == .orderedAscending
            }
            return false
        }
    }
    
    func findUserName(_ userID: String) -> String?{
        
        if userID == HCSDKCore.sharedInstance.currentUserID() {
            
            let user = AFUser.currentUser()
            return user?.username
        }
        
        for userInfo in userInfos {
            let loginInfo = userInfo["login"] as! [String: String]
            if let id = loginInfo["md5"] , id == userID
            {
                let nameInfo = userInfo["name"] as! [String: String]
                let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"
                
                return userName
            }
        }
        
        return nil
    }
    
    func findUserAvatar(_ userID: String) -> String?{
        
        if userID == HCSDKCore.sharedInstance.currentUserID() {
            
            let user = AFUser.currentUser()
            return user?.username
        }
        
        for userInfo in userInfos {
            let loginInfo = userInfo["login"] as! [String: String]
            let pictureInfo = userInfo["picture"] as! [String: String]
            if let avatar = pictureInfo["thumbnail"], let id = loginInfo["md5"] , id == userID
            {
                return avatar
            }
        }
        
        return nil
    }
}
