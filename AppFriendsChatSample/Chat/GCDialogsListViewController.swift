//
//  GCDialogsListViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/1/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import CoreStore
import AppFriendsUI

class GCDialogsListViewController: HCDialogsListViewController, GCDialogContactsPickerViewControllerDelegate {
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CHAT_PUSH_TAPPED"), object: nil)
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        
        self.updateTabBarBadge(nil)
        startObservingNewMessagesAndUpdateBadge()

        NotificationCenter.default.addObserver(self, selector: #selector(GCDialogsListViewController.handlePush(notification:)), name: NSNotification.Name(rawValue: "CHAT_PUSH_TAPPED"), object: nil)
        
        return super.awakeAfter(using: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.includeChannels = false
        
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem()
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.tableHeaderView = tableHeaderView()
        self.tableView.tableFooterView = tableFooterView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.title = "Conversations"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }

    func handlePush(notification: Notification) {

        if let dialog = notification.object as? AFDialog {
            DispatchQueue.main.async(execute: {
                self.showChatView(id: dialog.id)
            })
        }
    }
    
    // MARK: Style the view
    
    func tableHeaderView() -> UIView? {
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 25)
        headerView.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)
        
        return headerView
    }
    
    func tableFooterView() -> UIView? {
        
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 75)
        footerView.addBorderTop(size: 1, color: AppFriendsColor.coolGray!)
        
        return footerView
    }
    
    // MARK: - Navigation bar
    
    func rightBarButtonItem() -> UIBarButtonItem {
        
        // create new conversation button
        let icon = UIImage(named: "ic_write")
        let newConversationItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(GCDialogsListViewController.createNewConversation))
        return newConversationItem
    }
    
    
    // MARK: - New Conversation
    
    func createNewConversation() {
        
        let dialogStarterVC = GCDialogContactsPickerViewController(viewTitle:"New Conversation", excludeUsers: nil)
        let nav = UINavigationController(rootViewController: dialogStarterVC)
        dialogStarterVC.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            nav.modalPresentationStyle = .formSheet
            nav.preferredContentSize = CGSize(width: 600, height: 520)
        }
        self.presentVC(nav)
    }

    // MARK: - GCDialogStarterViewControllerDelegate
    
    func usersSelected(_ users: [String]) {

        self.showLoading("")
        if users.count == 1, let userID = users.get(at: 0) {
            AFDialog.createIndividualDialog(withUser: userID, completion: { (id, error) in

                if error != nil {
                    self.showErrorWithMessage(error?.localizedDescription)
                } else if let dialogID = id{
                    self.hideHUD()
                    self.showChatView(id: dialogID, showKeyboard: true)
                }
            })
        } else {
            AFDialog.createGroupDialog(dialogID: nil, members: users, customData: nil, pushData: nil, title: nil, completion: { (id, error) in

                if error != nil {
                    self.showErrorWithMessage(error?.localizedDescription)
                } else if let dialogID = id {
                    self.hideHUD()
                    self.showChatView(id: dialogID, showKeyboard: true)
                }
            })
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            cell.selectionStyle = .gray
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let dialog = self.dialog(atIndexPath: indexPath)
        {
            showChatView(id: dialog.id)
        }
    }
    
    func showChatView(id dialogID: String, showKeyboard show: Bool? = nil)
    {
        AFDialog.getDialog(dialogID: dialogID) { (dialog, error) in
            if let dialogObject = dialog {

                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    let chatView = GCChatViewController(dialog: dialogObject, supportedMessageDataTypes: .all, requireReceipts: true)
                    if let showKeyboard = show {
                        chatView.showKeyboardWhenDisplayed = showKeyboard
                    }
                    let nav = UINavigationController(rootViewController: chatView)
                    self.navigationController?.splitViewController?.showDetailViewController(nav, sender: self)
                }
                else {

                    self.title = ""
                    let chatView = GCChatViewController(dialog: dialogObject, supportedMessageDataTypes: .all, requireReceipts: true)
                    if let showKeyboard = show {
                        chatView.showKeyboardWhenDisplayed = showKeyboard
                    }
                    self.navigationController?.pushViewController(chatView, animated: true)
                }
            }
        }
    }
    
    // MARK: - Badges update for the tabbar
    
    func startObservingNewMessagesAndUpdateBadge()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarBadge), name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
    }
    
    func updateTabBarBadge(_ notification: Notification?)
    {
        DispatchQueue.main.async(execute: {
            
            if let count = notification?.object as? Int {
                
                if count > 0 {
                    self.navigationController?.tabBarItem.badgeValue = "\(count)"
                }
                else {
                    self.navigationController?.tabBarItem.badgeValue = nil
                }
            }
            else if AFDialog.totalUnreadMessageCount() > 0 {
                self.navigationController?.tabBarItem.badgeValue = "\(AFDialog.totalUnreadMessageCount())"
            }
            else {
                self.navigationController?.tabBarItem.badgeValue = nil
            }
        })
    }
    
    // MARK: - override 

    override func removeDialog(dialog: AFDialog, indexPath: IndexPath) {
        super.removeDialog(dialog: dialog, indexPath: indexPath)

        if UIDevice.current.userInterfaceIdiom == .pad
        {
            // clear the detail view on the right side if you are using a split view on iPad
            self.navigationController?.splitViewController?.showDetailViewController(UIViewController(), sender: self)
        }
    }
}
