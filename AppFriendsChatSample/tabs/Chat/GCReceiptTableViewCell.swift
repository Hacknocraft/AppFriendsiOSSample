//
//  GCReceiptTableViewCell.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

/// Cell to display a user who has read the message
class GCReceiptTableViewCell: UITableViewCell {

    /// label to display the user name
    @IBOutlet weak var userNameLabel: UILabel!

    /// second label to display some additional information of the user
    @IBOutlet weak var subtitleLabel: UILabel!
}
