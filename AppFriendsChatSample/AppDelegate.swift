//
//  AppDelegate.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/22/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore

// AppFriends
import AppFriendsUI

// Fabric
import Fabric
import Crashlytics

// push
import Firebase
import FirebaseMessaging
import UserNotifications

enum AppFriendsEnvironment {
    case production, sandbox, testing, staging
}

struct Environment {
    static let current: AppFriendsEnvironment = .production
}

@UIApplicationMain
class AppDelegate: UIResponder,
UIApplicationDelegate,
UISplitViewControllerDelegate,
UITabBarControllerDelegate,
AFEventSubscriber {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        HCSDKCore.sharedInstance.application(application,
                                             didFinishLaunchingWithOptions: launchOptions)

        styleApp ()

        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.enableDebug()

        if Environment.current == .sandbox {
            appFriendsCore.setValue(true, forKey: "useSandbox")
        } else if Environment.current == .staging {
            appFriendsCore.setValue(true, forKey: "staging")
        } else if Environment.current == .testing {
            appFriendsCore.setValue(true, forKey: "stressTest")
        }

        UsersDataBase.sharedInstance.loadUsers()

        Fabric.with([Crashlytics.self])

        // Handle notification
        if launchOptions != nil {

            // For remote Notification
            let remoteNotificationKey = UIApplicationLaunchOptionsKey.remoteNotification
            if let remoteNotification = launchOptions?[remoteNotificationKey] as? [AnyHashable: Any] {
                self.processRemoteNotification(remoteNotification,
                                               application: application)
            }
        }

        // push notification
        initializePushNotification(app: application)
        FirebaseApp.configure()

        // listen to AppFriends Event
        AFEvent.subscribe(subscriber: self)

        NSLog(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])

        return true
    }

    func updateTabBarBadge(_ notification: Notification?) {
        DispatchQueue.main.async(execute: {

            if let count = notification?.object as? Int {

                UIApplication.shared.applicationIconBadgeNumber = count
            } else {

                UIApplication.shared.applicationIconBadgeNumber = AFDialog.totalUnreadMessageCount()
            }
        })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Disconnected from FCM.")

        UIApplication.shared.applicationIconBadgeNumber = AFDialog.totalUnreadMessageCount()
    }

    // example of handling remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        // Print full message.
        print("%@", userInfo)

        processRemoteNotification(userInfo, application: application)
    }

    // MARK: process notification

    func processRemoteNotification(_ userInfo: [AnyHashable: Any], application: UIApplication) {
        // Received remote notification.
        // You can navigate app or process data here
        _ = AFPushNotification.processPushNotification(notificationUserInfo: userInfo)
        if AFSession.isLoggedIn(), let aps = userInfo["aps"] as? [AnyHashable: Any] {
            if let category = aps["category"] as? String,
                category == HCSDKConstants.kAppFriendsPushCategory,
                let dialogID = userInfo["dialog_id"] as? String {

                // push tapped
                AFDialog.getDialog(dialogID: dialogID, completion: { (dialog, _) in
                    if let dialogObject = dialog {
                        NotificationCenter.default
                            .post(name: NSNotification.Name(rawValue: "CHAT_PUSH_TAPPED"),
                                  object: dialogObject)
                    }
                })
            }
        }
    }

    // MARK: style the app

    func styleApp () {

        window?.backgroundColor = .white

        UITabBar.appearance().backgroundColor = UIColor.white

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.shadowImage = UIImage(named: "667c8c")
        navigationBarAppearace.tintColor = AppFriendsColor.ceruLean
        navigationBarAppearace.backgroundColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]

        HCColorPalette.chatBackgroundColor = UIColor.white
        HCColorPalette.emptyTableLabelColor = AppFriendsColor.charcoalGrey!
        HCColorPalette.navigationBarTitleColor = AppFriendsColor.charcoalGrey!
        HCColorPalette.navigationBarIconColor = AppFriendsColor.ceruLean!
        HCColorPalette.chatDialogListTitleColor = AppFriendsColor.charcoalGrey!
        HCColorPalette.chatDialogTimeStampPreviewColor = AppFriendsColor.coolGray!
        HCColorPalette.chatDialogMessagePreviewColor = AppFriendsColor.coolGray!
        HCColorPalette.chatSystemMessageColor = AppFriendsColor.coolGray!
        HCColorPalette.badgeBackgroundColor = AppFriendsColor.ceruLean!

        HCColorPalette.chatOutMessageBubbleColor = AppFriendsColor.ceruLean!
        HCColorPalette.chatInMessageBubbleColor = AppFriendsColor.coolGreyLighter!
        HCColorPalette.chatOutMessageContentTextColor = UIColor.white
        HCColorPalette.chatInMessageContentTextColor = AppFriendsColor.charcoalGrey!
//        HCColorPalette.chatInMessageLinkColor = UIColor.green
//        HCColorPalette.chatOutMessageLinkColor = UIColor.red

        HCColorPalette.chatUserNamelTextColor = AppFriendsColor.coolGray!
        HCColorPalette.avatarBackgroundColor = AppFriendsColor.coolGray!
        HCColorPalette.tableSeparatorColor = AppFriendsColor.coolGray!
        HCColorPalette.tableSectionSeparatorColor = AppFriendsColor.coolGray!
        HCColorPalette.tableBackgroundColor =  AppFriendsColor.coolGreyLighter!
        HCColorPalette.normalTextColor = AppFriendsColor.charcoalGrey!

        HCColorPalette.navigationBarTitleColor = AppFriendsColor.charcoalGrey!
        //Album
//        HCColorPalette.albumBackgroundColor = UIColor.white
//        HCColorPalette.albumSectionBackgroundColor = UIColor(hexString: "d6d6d6")
//        HCColorPalette.albumSectionTitleColor = UIColor(hexString: "35373d")
//        HCColorPalette.albumItemBackgroundColor = UIColor(hexString: "a6b4bf")
//        HCColorPalette.albumNavigationBarIconColor = AppFriendsColor.ceruLean
//        HCColorPalette.albumNavigationBarTitleColor = UIColor.black
//        HCColorPalette.albumNavigationBackgroundColor = UIColor.white
    }

    // MARK: Push notification

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {

        print("didRegisterUserNotificationSettings")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        // register for push notification
        if AFSession.isLoggedIn(),
            let pushToken = InstanceID.instanceID().token(),
            let currentUserID = HCSDKCore.sharedInstance.currentUserID() {
            HCSDKCore.sharedInstance.registerDeviceForPush(currentUserID, pushToken: pushToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("push notification register failed: \(error.localizedDescription)")
    }

    func initializePushNotification(app application: UIApplication) {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)

        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    @objc func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("GCM InstanceID token: \(refreshedToken)")
        }

        // register for push notification
        if AFSession.isLoggedIn(),
            let pushToken = InstanceID.instanceID().token(),
            let currentUserID = HCSDKCore.sharedInstance.currentUserID() {
            HCSDKCore.sharedInstance.registerDeviceForPush(currentUserID, pushToken: pushToken)
        }
    }

    // MARK: iPad, UISplitViewControllerDelegate

    func splitViewController(_ splitViewController: UISplitViewController,
                             showDetail vc: UIViewController,
                             sender: Any?) -> Bool {

        guard !splitViewController.isCollapsed else { return false }
        guard !(vc is UINavigationController) else { return false }
        guard let detailNavController =
            splitViewController.viewControllers.last! as? UINavigationController,
            detailNavController.viewControllers.count == 1
            else { return false }

        detailNavController.pushViewController(vc, animated: true)
        return true
    }

    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController,
                          animationControllerForTransitionFrom fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        fromVC.dismiss(animated: true, completion: nil)
        return nil
    }

    // MARK: - AFEventSubscriber
    func emitEvent(_ event: AFEvent) {
        if event.name == .eventDuplicateSession {

            let popup = UIAlertController(title: "Duplicate Session",
                                          message: "The same account logged in somewhere else!",
                                          preferredStyle: .alert)
            popup.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in

            }))
            self.window?.rootViewController?.present(popup, animated: true, completion: nil)
        } else if event.name == .eventTotalUnreadCountChange {
            self.updateTabBarBadge(nil)
        }
    }

}
