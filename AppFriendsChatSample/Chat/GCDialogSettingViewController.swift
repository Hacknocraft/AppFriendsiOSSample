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
        let closeItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(HCDialogSettingViewController.closeView))
        return closeItem
    }
    
    // MARK: - Override AppFriends Class
    
    override func closeView() {
        
        if let count = self.navigationController?.viewControllers.count, count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismissVC(completion: nil)
        }
    }
    
    override func didLeaveDialog() {
        
        super.didLeaveDialog()
    }
    
    override func membersRowTapped() {
        
        if let dialog = currentDialog(), let dialogID = _dialogID {
            
            let members = dialog.memberIDs()
            let membersVC = GCDialogMembersListViewController(members: members, dialogID: dialogID)
            self.navigationController?.pushViewController(membersVC, animated: true)
        }
    }
}
