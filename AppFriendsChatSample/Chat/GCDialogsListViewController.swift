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
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        
        self.updateTabBarBadge(nil)
        startObservingNewMessagesAndUpdateBadge()
        
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
        
        var dialogType = ""
        if users.count == 1 {
            dialogType = HCSDKConstants.kMessageTypeIndividual
        }
        else {
            dialogType = HCSDKConstants.kMessageTypeGroup
        }
        
        self.showLoading("")
        DialogsManager.sharedInstance.initializeDialog(users, dialogType: dialogType, dialogTitle: nil) { (dialogID, error) in
            
            if error != nil {
                self.showErrorWithMessage(error?.localizedDescription)
            }
            else if let id = dialogID{
                self.hideHUD()
                self.showChatView(id: id, showKeyboard: true)
            }
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
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            showChatView(id: dialog.dialogID!)
        }
    }
    
    func showChatView(id dialogID: String, showKeyboard show: Bool? = nil)
    {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            let chatView = GCChatViewController(dialog: dialogID, supportedMessageDataTypes: .All)
            if let showKeyboard = show {
                chatView.showKeyboardWhenDisplayed = showKeyboard
            }
            let nav = UINavigationController(rootViewController: chatView)
            self.navigationController?.splitViewController?.showDetailViewController(nav, sender: self)
        }
        else {
            
            self.title = ""
            let chatView = GCChatViewController(dialog: dialogID, supportedMessageDataTypes: .All)
            if let showKeyboard = show {
                chatView.showKeyboardWhenDisplayed = showKeyboard
            }
            self.navigationController?.pushViewController(chatView, animated: true)
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
            else if DialogsManager.sharedInstance.totalUnreadMessages > 0 {
                self.navigationController?.tabBarItem.badgeValue = "\(DialogsManager.sharedInstance.totalUnreadMessages)"
            }
            else {
                self.navigationController?.tabBarItem.badgeValue = nil
            }
        })
    }
    
    // MARK: - override 
    
    override func listMonitor(_ monitor: ListMonitor<HCChatDialog>, didDeleteObject object: HCChatDialog, fromIndexPath indexPath: IndexPath) {
        
        super.listMonitor(monitor, didDeleteObject: object, fromIndexPath: indexPath)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            // clear the detail view on the right side if you are using a split view on iPad
            self.navigationController?.splitViewController?.showDetailViewController(UIViewController(), sender: self)
        }
    }

}
