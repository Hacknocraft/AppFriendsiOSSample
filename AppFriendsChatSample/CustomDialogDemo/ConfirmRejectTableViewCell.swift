//
//  ConfirmRejectTableViewCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/5/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

@objc protocol ConfirmRejectTableViewCellDelegate {
    func acceptButtonTapped(_ cell: ConfirmRejectTableViewCell)
    func rejectButtonTapped(_ cell: ConfirmRejectTableViewCell)
}

class ConfirmRejectTableViewCell: UICollectionViewCell {

    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    weak var delegate: ConfirmRejectTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rejectButton.layer.cornerRadius = 4
        self.rejectButton.layer.masksToBounds = true
        self.rejectButton.layer.borderColor = UIColor.white.cgColor
        self.rejectButton.layer.borderWidth = 2
        
        self.acceptButton.layer.cornerRadius = 4
        self.acceptButton.layer.masksToBounds = true
        self.acceptButton.layer.borderColor = UIColor.white.cgColor
        self.acceptButton.layer.borderWidth = 2
    }

    @IBAction func rejected(_ sender: AnyObject) {
        self.delegate?.rejectButtonTapped(self)
    }
    
    @IBAction func accepted(_ sender: AnyObject) {
        self.delegate?.acceptButtonTapped(self)
    }
    
}
