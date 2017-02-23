//
//  GCChatViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsUI

class GCChatViewController: HCDialogChatViewController, GCInfoBannerViewDelegate {
    
    private lazy var __once: () = {[weak self] in
                self?.textInputbar.textView.becomeFirstResponder()
            }()
    
    var showKeyboardWhenDisplayed = false
    
    deinit {
        print("")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        _requireReceipt = true
        
        if let dialog = self.currentDialog(), let title = dialog.title , dialog.type == HCSDKConstants.kMessageTypeGroup && title.isBlank
        {
            // show update dialog title banner
            
            let dialogNameBanner = GCInfoBannerView(frame: CGRect.zero)
            dialogNameBanner.delegate = self
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime)
            {[weak self] in
                _ = dialogNameBanner.show(inController: self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if showKeyboardWhenDisplayed {
            
            // show keyboard
            _ = self.__once
        }
    }
    
    // MARK: - navigation bar
    
    override func rightNavigationItem() -> UIBarButtonItem? {
        
        if self._dialogType != HCSDKConstants.kMessageTypeChannel {
            
            // setting button
            let moreItem = UIBarButtonItem(image: UIImage(named: "tabbarInfo"), style: .plain, target: self, action: #selector(GCChatViewController.settingButtonTapped))
            
            return moreItem
        }
        else {
            return nil
        }
    }
    
    override func settingButtonTapped()
    {
        let dialogSetting = GCDialogSettingViewController(dialog: _dialogID)
        let nav = UINavigationController(rootViewController: dialogSetting)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            nav.modalPresentationStyle = .formSheet
            nav.preferredContentSize = CGSize(width: 600, height: 520)
        }
        
        self.presentVC(nav)
    }
    
    // MARK: - Handle Message Receipt
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // only display receipt if it's a message sent by the current user
        
        if tableView.isEqual(self.tableView) {
            
            if isSentMessage(atIndexPath: indexPath), let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
            {
                // no need to check receipt on system message
                
                if message.messageType != HCSDKConstants.kMessageTypeSystem, let requireReceipt = _requireReceipt , requireReceipt == true, let tempID = message.tempID, let messageID = message.messageID, let dialogID = message.dialogID, let senderID = message.senderID
                {
                    let receiptVC = GCMessageReceiptViewController(messageTempID: tempID, messageID: messageID, senderID: senderID, dialogID: dialogID)
                    self.navigationController?.pushViewController(receiptVC, animated: true)
                }
            }
        }
        else {
            
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    // MARK: - GCInfoBannerViewDelegate
    
    func groupTitleChanged(_ bannerView: GCInfoBannerView, text: String) {
        
        DialogsManager.sharedInstance.updateDialogName(_dialogID, dialogName: text, completion: { [weak self] (error) in
            
            if let err = error {
                self?.showErrorWithMessage(err.localizedDescription)
            }
            else {
                self?.updateTitle()
                bannerView.hideAnimated()
            }
        })
    }
    
    // MARK: - HCChatTableViewCellDelegate
    
    override func avatarTapped(_ cell: HCChatTableViewCell) {
        
        super.avatarTapped(cell)
        
        if let indexPath = self.tableView.indexPath(for: cell)
        {
            let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
            
            if let senderID = message?.senderID {
                let profileVC = ProfileViewController(userID: senderID)
                self.pushVC(profileVC)
            }
        }
    }
    
    override func linkTapped(_ cell: HCChatTableViewCell, url: URL) {
        
        // respond to link click
        super.linkTapped(cell, url: url)
    }
    
    // MARK: - override chat UI
    
    override func messagingCell(atIndexPath indexPath:IndexPath) -> HCChatTableViewCell {
        
        let cell = super.messagingCell(atIndexPath: indexPath)
        
        if let userAvatarImageView = cell.userAvatarImageView {
            
            let isOutMessage = isSentMessage(atIndexPath: indexPath)
            if let message = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row], !isOutMessage, let senderName = message.senderName {
                
                // add user initial on top of the user avatar image
                if let initialLabel = userAvatarImageView.viewWithTag(999) as? UILabel {
                    
                    // replace this to get user initial
                    let index = senderName.index(senderName.startIndex, offsetBy: 2)
                    initialLabel.text = senderName.uppercased().substring(to: index)
                    
                }
                else {
                    let initialLabel = UILabel(frame: CGRect(x: 0, y: 0, width: userAvatarImageView.w, height: userAvatarImageView.h))
                    initialLabel.tag = 999 // a tag
                    initialLabel.textAlignment = .center
                    // replace this to get user initial
                    if senderName.length > 4 {
                        let index = senderName.index(senderName.startIndex, offsetBy: 2)
                        initialLabel.text = senderName.uppercased().substring(to: index)
                        initialLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                        initialLabel.textColor = UIColor.white
                        initialLabel.font = UIFont.boldSystemFont(ofSize: 13)
                        userAvatarImageView.addSubview(initialLabel)
                    }
                }
            }
            
        }
        
        return cell
    }
}
