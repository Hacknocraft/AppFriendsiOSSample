//
//  GCDialogSettingViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI

class GCDialogSettingViewController: HCDialogSettingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = leftBarButtonItem()
        self.navigationItem.rightBarButtonItem = rightBarButtonItem()
        self.view.backgroundColor = AppFriendsColor.coolGreyLighter

        self._tableView?.tableHeaderView = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation bar

    override func leftBarButtonItem() -> UIBarButtonItem {

        // close
        let icon = UIImage(named: "ic_clear")
        let closeItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(closeView))
        return closeItem
    }

    func rightBarButtonItem() -> UIBarButtonItem {

        // close
        let icon = UIImage.materialDesignIconWithName(.gmdApps,
                                           textColor: AppFriendsColor.coolGreyLighter ?? UIColor.white,
                                           size: CGSize(width: 40, height: 40))
        let albutItem = UIBarButtonItem(image: icon,
                                        style: .plain,
                                        target: self,
                                        action: #selector(showAlbum))
        return albutItem
    }

    // MARK: - Show Album

    func showAlbum() {

        let dialog = self.currentDialog()
        let albumVC = HCAlbumViewController(dialogID: dialog.id)
        self.navigationController?.pushViewController(albumVC, animated: true)
    }

    // MARK: - Override AppFriends Class

    override func closeView() {

        if let count = self.navigationController?.viewControllers.count, count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismissVC(completion: nil)
        }
    }

    override func didLeaveDialog() {

        super.didLeaveDialog()
    }

    override func membersRowTapped() {

        let dialog = currentDialog()
        if let members = dialog.members, members.count > 0 {
            let membersVC = GCDialogMembersListViewController(dialog: dialog)
            self.navigationController?.pushViewController(membersVC, animated: true)
        }
    }
}
