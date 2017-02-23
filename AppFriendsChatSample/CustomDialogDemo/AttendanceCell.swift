//
//  AttendanceCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

import AppFriendsUI

class AttendanceCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var checkMarkView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.checkMarkView.layer.borderColor = HCColorPalette.chatBackgroundColor?.cgColor
        self.checkMarkView.layer.borderWidth = 2
        self.checkMarkView.layer.cornerRadius = self.checkMarkView.w/2
        self.checkMarkView.layer.masksToBounds = true
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.w/2
        self.avatarImageView.layer.masksToBounds = true
    }

}
