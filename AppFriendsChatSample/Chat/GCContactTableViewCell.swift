//
//  GCContactTableViewCell.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

class GCContactTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionIndicator: UIImageView?
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userNameLabel.textColor = AppFriendsColor.charcoalGrey
        self.subLabel.textColor = AppFriendsColor.coolGray
    }
    
    func mark(selected isSelected: Bool) {
        
        if isSelected {
            let icon = UIImage(named: "ic_check_circle")?.withRenderingMode(.alwaysTemplate)
            selectionIndicator?.image = icon
            selectionIndicator?.tintColor = AppFriendsColor.ceruLean
        }
        else {
            let icon = UIImage(named: "ic_radio_button_unchecked")?.withRenderingMode(.alwaysTemplate)
            selectionIndicator?.image = icon
            selectionIndicator?.tintColor = AppFriendsColor.greyLight
        }
        
    }
    
}
