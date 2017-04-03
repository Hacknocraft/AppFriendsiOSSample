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

    // MARK: - Table view data source

    override func dialogCell(atIndexPath indexPath: IndexPath) -> HCDialogTableViewCell {

        let cellIdentifier = "Cell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }

        cell!.textLabel?.text = nil

        if let dialog = self.dialog(atIndexPath: indexPath), let customData = dialog.customData {

            if let gameData = HCUtils.dictionaryFromJsonString(customData) {

                if let gameTitle = gameData[Keys.gameTitleKey] as? String,
                    let gameDescription = gameData[Keys.gameDescriptionKey] as? String
                {
                    cell!.textLabel?.text = gameTitle
                    cell!.detailTextLabel?.text = gameDescription
                }
            }
        }
        cell!.accessoryType = .disclosureIndicator
        
        return cell! as! HCDialogTableViewCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
