//
//  UIDevice+types.swift
//  AFChatUISample
//
//  Created by HAO WANG on 3/6/18.
//  Copyright © 2018 hacknocraft. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    static func isIphoneX() -> Bool {
        return UIScreen.main.nativeBounds.height == 2436 && UIDevice.current.userInterfaceIdiom == .phone
    }
}
