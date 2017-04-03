//
//  LiveGameViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/30/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsFloatingWidget
import AppFriendsUI

class LiveGameViewController: UIViewController, HCSidePanelViewControllerDelegate, HCFloatingWidgetDelegate {
    
    var sidePanelVC: HCSidePanelViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabBarImage = UIImage.materialDesignIconWithName(.gmdToys, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Game", image: tabBarImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Game"
        
        // present AppFriends Widget
        presentWidget()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentWidget() {
        
        let floatingWidget =
            HCFloatingWidget(widgetImage: UIImage(named: "ic_chat_widget"),
                             screenshotButtonImage: UIImage(named: "ic_camera"),
                             showScreenshotButton: true)
        floatingWidget.present(overVC: self, position: CGPoint(x: 295, y: 60))
        floatingWidget.delegate = self
    }
    
    // MARK: - HCFloatingWidgetDelegate
    
    func widgetButtonTapped(widget: HCFloatingWidget) {
        
        let chatListVC = HCDialogsListViewController()
        chatListVC.automaticallyAdjustsScrollViewInsets = false
        chatListVC.includeChannels = true
        chatListVC.edgesForExtendedLayout = []
        let nav = UINavigationController(rootViewController: chatListVC)
        let sidePanelVC = AppFriendsUI.sharedInstance.presentVCInSidePanel(fromVC: self, showVC: nav)
        sidePanelVC.delegate = self
    }
    
    private func widgetMessagePreviewTapped(dialogID: String, messageID: String, widget: HCFloatingWidget) {
        
    }

    // MARK: - HCSidePanelViewControllerDelegate
    
    func sidePanelWillAppear(panel: HCSidePanelViewController) {
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func sidePanelDidDisappear(panel: HCSidePanelViewController) {
        
        self.tabBarController?.tabBar.isHidden = false
    }
}
