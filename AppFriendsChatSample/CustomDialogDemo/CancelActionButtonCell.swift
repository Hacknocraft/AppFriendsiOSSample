//
//  ActionButtonCell.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

@objc protocol CancelActionButtonCellDelegate {
    func cancelButtonTapped(_ cell: CancelActionButtonCell)
}

class CancelActionButtonCell: UICollectionViewCell {

    static let identifier = "CancelActionButtonCell"
    
    weak var delegate: CancelActionButtonCellDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cancelButton.layer.cornerRadius = 4
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.borderColor = UIColor.white.cgColor
        self.cancelButton.layer.borderWidth = 2
    }
    
    @IBAction func cancelButtonTapped(withSender sender: AnyObject) {
        self.delegate?.cancelButtonTapped(self)
    }
}
