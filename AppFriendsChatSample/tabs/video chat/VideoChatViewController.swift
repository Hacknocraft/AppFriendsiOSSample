//
//  VideoChatViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 10/15/17.
//  Copyright © 2017 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI

class VideoChatViewController: HCChannelChatViewController {

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        let personImage = UIImage
            .materialDesignIconWithName(.gmdPerson,
                                        textColor: UIColor.black,
                                        size: CGSize(width: 30, height: 30))
        self.leftButton.setImage(personImage, for: .normal)
        self.leftButton.isEnabled = false
        self.leftButton.layer.cornerRadius = self.leftButton.frame.size.width/2

        let sendImage = UIImage(named: "send_button")
        self.rightButton.setBackgroundImage(sendImage, for: .normal)
        self.rightButton.setImage(nil, for: .normal)
        self.rightButton.setTitle("", for: .normal)

        self.textInputbar.textView.placeholder = "Write a comment ..."
    }

    override func didPressLeftButton(_ sender: Any?) {
        // do nothing, we do not want users to post any media
    }

    override func didPressRightButton(_ sender: Any?) {
        super.didPressRightButton(sender)

        self.view.endEditing(true)
    }

    override func showUserNameOnOutgoingMessage() -> Bool {
        return true
    }

    override func alternateSideForOutgoingMessage() -> Bool {
        return false
    }

    override func outGoingMessageContentTextColor() -> UIColor {
        return UIColor(hexString: "#494c52")!
    }

    override func incomingMessageContentTextColor() -> UIColor {
        return UIColor(hexString: "#494c52")!
    }

    override func outGoingMessageBubbleColor() -> UIColor {
        return UIColor.clear
    }

    override func incomingMessageBubbleColor() -> UIColor {
        return UIColor.clear
    }

    override func chatUsernameColor() -> UIColor {
        return UIColor(hexString: "#323232")!
    }

    override func usernameLeftMargin() -> CGFloat {
        return 60
    }
}
