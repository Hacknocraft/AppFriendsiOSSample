//
//  UserSearchViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/28/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsUI

class UserSearchViewController: HCUserSearchViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let tabBarImage = UIImage.materialDesignIconWithName(.gmdSearch, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        let customTabBarItem: UITabBarItem = UITabBarItem(title: "Search",
                                                          image: tabBarImage.withRenderingMode(.alwaysOriginal),
                                                          selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
    }

    override func viewDidLoad() {
        self.title = "Search"
        super.viewDidLoad()

        let searchIcon = UIImageView(image: UIImage(named: "ic_search"))
        searchIcon.contentMode = .center
        searchIcon.alpha = 0.2
        self.tableView.backgroundView = searchIcon
    }

    // MARK: Table 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let user = self.userAtIndexPath(indexPath) {
            let profileVC = ProfileViewController(userID: user.id)
            self.navigationController?.pushViewController(profileVC)
        }
    }
}
