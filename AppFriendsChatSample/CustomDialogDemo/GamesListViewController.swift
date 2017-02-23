//
//  GamesListViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import CoreStore
import AppFriendsCore

import AppFriendsUI

class GamesListViewController: HCDialogsListViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Scheduled Games"
        
        self.edgesForExtendedLayout = []
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewDetailCell")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func dialogMonitor() -> ListMonitor<HCChatDialog>
    {
        let monitor = CoreStoreManager.store()!.monitorList(
            From(HCChatDialog.self),
            Where("ANY members.userID == %@", currentUserID!) && Where("customData != nil && customData != %@", ""),
            OrderBy(.descending("lastMessageTime"), .descending("createTime")),
            Tweak { (fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 20
            }
        )
        return monitor
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = self.monitor?.numberOfObjectsInSection(safeSectionIndex: section) else {
            return 0
        }
        
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel?.text = nil
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            if let customData = dialog.customData {
                
                if let gameData = HCUtils.dictionaryFromJsonString(customData) {
                    
                    if let gameTitle = gameData[Keys.gameTitleKey] as? String,
                    let gameDescription = gameData[Keys.gameDescriptionKey] as? String
                    {
                        cell!.textLabel?.text = gameTitle
                        cell!.detailTextLabel?.text = gameDescription
                    }
                }
            }
        }
        
        cell!.accessoryType = .disclosureIndicator
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let dialog = self.monitor?.objectsInSection(safeSectionIndex: indexPath.section)![indexPath.row]
        {
            selectedDialogID = dialog.dialogID
        }
        
        self.performSegue(withIdentifier: "GameAttendanceSegue", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    var selectedDialogID: String?
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "GameAttendanceSegue" {
            
            if let gameAttendanceVC = segue.destination as? GameAttendanceViewController {
                
                gameAttendanceVC.gameAttendanceDialogID = selectedDialogID
            }
            
        }
    }
}
