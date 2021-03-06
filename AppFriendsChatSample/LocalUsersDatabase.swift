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

class UsersDataBase {
    var userInfos: [[String: AnyObject]] = [[String: AnyObject]]()

    static let sharedInstance = UsersDataBase()

    /// a list of user ids of the users who the current user is following
    open var following = [String]()

    /// a list of user ids of the users who are following the current user
    open var followers = [String]()

    /// a list of user ids of the users who are friends with the current user
    open var friends = [String]()

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

    func findUserName(_ userID: String) -> String? {

        if userID == HCSDKCore.sharedInstance.currentUserID() {

            let user = AFUser.currentUser()
            return user?.username
        }

        for userInfo in userInfos {
            guard let loginInfo = userInfo["login"] as? [String: String],
            let nameInfo = userInfo["name"] as? [String: String] else {
                continue
            }
            if let id = loginInfo["md5"], id == userID {
                let userName = "\(nameInfo["first"]!) \(nameInfo["last"]!)"

                return userName
            }
        }

        return nil
    }

    func findUserAvatar(_ userID: String) -> String? {

        if userID == HCSDKCore.sharedInstance.currentUserID() {

            let user = AFUser.currentUser()
            return user?.username
        }

        for userInfo in userInfos {
            guard let loginInfo = userInfo["login"] as? [String: String],
                let pictureInfo = userInfo["picture"] as? [String: String] else {
                    continue
            }
            if let avatar = pictureInfo["thumbnail"],
                let id = loginInfo["md5"],
                id == userID {
                return avatar
            }
        }

        return nil
    }

    func loadFollowers() {
        AFUser.getFollowers { (users, error) in
            if error == nil, let userIDs = users {
                self.followers = userIDs
            }
        }
    }

    func loadFollowings() {
        AFUser.getFollowing { (users, error) in
            if error == nil, let userIDs = users {
                self.following = userIDs
            }
        }
    }

    func loadFriends() {
        AFUser.getFriends { (users, error) in
            if error == nil, let userIDs = users {
                self.friends = userIDs
            }
        }
    }
}
