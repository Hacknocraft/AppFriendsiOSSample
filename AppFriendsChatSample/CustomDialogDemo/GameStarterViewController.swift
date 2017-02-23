//
//  GameStarterViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

class GameStarterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabBarImage = UIImage.GMDIconWithName(.gmdToys, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Game", image: tabBarImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
        self.hidesBottomBarWhenPushed = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // start a chat with this user
        if (indexPath as NSIndexPath).row == 0 {
            
            self.performSegue(withIdentifier: "WatchLiveGameSegue", sender: self)
        }
        else if (indexPath as NSIndexPath).row == 1 {
            
            let storyboard = UIStoryboard(name: "ScheduleGame", bundle: nil)
            let scheduleGameVC = storyboard.instantiateViewController(withIdentifier: "ScheduledGamesList")
            self.navigationController?.pushViewController(scheduleGameVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        if (indexPath as NSIndexPath).row == 0 {
            cell.accessoryType = .disclosureIndicator
            cell.textLabel!.text = "Watch Live Game"
        }
        else if (indexPath as NSIndexPath).row == 1 {
            cell.accessoryType = .disclosureIndicator
            cell.textLabel!.text = "Games"
        }
        return cell
    }

}
