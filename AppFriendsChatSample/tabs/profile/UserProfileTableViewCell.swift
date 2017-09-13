//
//  UserProfileTableViewCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 8/23/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

@objc
protocol UserProfileTableViewCellDelegate {

    func followButtonTapped()
    func chatButtonTapped()
    func blockButtonTapped()
}

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!

    weak var delegate: UserProfileTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.userAvatarView.clipsToBounds = true
        self.userAvatarView.layer.borderColor = UIColor.white.cgColor
        self.userAvatarView.layer.borderWidth = 1
        self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.size.width/2

        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func followButtonTapped(_ sender: Any) {
        delegate?.followButtonTapped()
    }

    @IBAction func chatButtonTapped(_ sender: Any) {
        delegate?.chatButtonTapped()
    }

    @IBAction func blockButtonTapped(_ sender: Any) {
        delegate?.blockButtonTapped()
    }
}
