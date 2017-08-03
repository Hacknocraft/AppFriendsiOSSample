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

/// A demo view simulating a situation where you need to display the chat as a slide in over lay
class LiveGameViewController: UIViewController, HCSidePanelViewControllerDelegate, HCFloatingWidgetDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let tabBarImage = UIImage.materialDesignIconWithName(.gmdToys,
                                                             textColor: UIColor.black,
                                                             size: CGSize(width: 30, height: 30))
        let customTabBarItem: UITabBarItem = UITabBarItem(title: "Game",
                                                          image: tabBarImage.withRenderingMode(.alwaysOriginal),
                                                          selectedImage: tabBarImage)
        self.tabBarItem = customTabBarItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Game"
        presentWidget()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Present the AppFriends Widget. The AppFriends widget has these features:
    /// 1. show message preview button
    /// 2. show badge
    /// 3. draggable
    /// 4. you can use it share screenshots to chat
    func presentWidget() {

        let floatingWidget =
            HCFloatingWidget(widgetImage: UIImage(named: "ic_chat_widget"),
                             screenshotButtonImage: UIImage(named: "ic_camera"),
                             showScreenshotButton: true)
        floatingWidget.present(overVC: self, position: CGPoint(x: 295, y: 60))
        floatingWidget.delegate = self
    }

    // MARK: - HCFloatingWidgetDelegate

    /// The callback when AppFriends widget button is tapped. 
    /// In this sample app, we simply show the overlay slide-in chat view
    ///
    /// - Parameter widget: The floating widget object
    func widgetButtonTapped(widget: HCFloatingWidget) {

        let chatListVC = HCDialogsListViewController()
        chatListVC.automaticallyAdjustsScrollViewInsets = false
        chatListVC.includeChannels = true
        chatListVC.edgesForExtendedLayout = []
        let nav = UINavigationController(rootViewController: chatListVC)
        let sidePanelVC = AppFriendsUI.sharedInstance.presentVCInSidePanel(fromVC: self,
                                                                           showVC: nav,
                                                                           backgroundMode: .darken)
        sidePanelVC.delegate = self
    }

    private func widgetMessagePreviewTapped(dialogID: String, messageID: String, widget: HCFloatingWidget) {

    }

    // MARK: - HCSidePanelViewControllerDelegate

    /// Callback when the slide in chat view is presented
    ///
    /// - Parameter panel: the slide in panel
    func sidePanelWillAppear(panel: HCSidePanelViewController) {

        self.tabBarController?.tabBar.isHidden = true
    }

    /// Callback when the slide in chat view is dismissed
    ///
    /// - Parameter panel: the slide in panel
    func sidePanelDidDisappear(panel: HCSidePanelViewController) {

        self.tabBarController?.tabBar.isHidden = false
    }
}
