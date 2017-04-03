//
//  InviteUserViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore

import AppFriendsUI

@objc protocol InviteUserViewControllerDelegate {
    
    func usersSelected(_ users: [String])
}

class InviteUserViewController: HCUserSearchViewController {

    weak var delegate: InviteUserViewControllerDelegate? = nil
    
    var selectedUserIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InviteUserViewController.doneButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.delegate?.usersSelected(selectedUserIDs)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = self.view.backgroundColor
        
        if let user = self.userAtIndexPath(indexPath)
        {
            if selectedUserIDs.contains(user.id) {
                
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let user = self.userAtIndexPath(indexPath)
        {
            if selectedUserIDs.contains(user.id) {
                selectedUserIDs.removeFirst(user.id)
            }
            else {
                selectedUserIDs.append(user.id)
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
