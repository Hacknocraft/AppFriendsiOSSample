//
//  BaseViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 9/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import JGProgressHUD

/// Base view controller, which provides some convenient methods for the other view controllers
class BaseViewController: UIViewController {

    static var HUD: JGProgressHUD?

    // MARK: overlay message
    func hud() -> JGProgressHUD! {

        if BaseViewController.HUD == nil {
            BaseViewController.HUD = JGProgressHUD(style: .dark)
        }

        return BaseViewController.HUD
    }

    func showProgress(_ progress: Float, message: String) {

        let HUD = self.hud()
        HUD?.textLabel.text = message

        HUD?.indicatorView = JGProgressHUDPieIndicatorView(hudStyle: .dark)
        HUD?.setProgress(progress, animated: true)

        if progress >= 1 {

            HUD?.dismiss()
            BaseViewController.HUD = nil
        } else {
            HUD?.show(in: self.view)
        }
    }

    func showLoading (_ message: String?) {
        let HUD = self.hud()
        HUD?.textLabel.text = message
        HUD?.indicatorView = JGProgressHUDIndeterminateIndicatorView(hudStyle: .dark)
        HUD?.show(in: self.view)
    }

    func showErrorWithMessage(_ message: String?) {

        let HUD = self.hud()

        HUD?.textLabel.text = message
        HUD?.indicatorView = JGProgressHUDErrorIndicatorView()

        HUD?.show(in: self.view)
        HUD?.dismiss(afterDelay: 2)
    }

    func showSuccessWithMessage(_ message: String?) {

        let HUD = self.hud()

        HUD?.textLabel.text = message
        HUD?.indicatorView = JGProgressHUDSuccessIndicatorView()

        HUD?.show(in: self.view)
        HUD?.dismiss(afterDelay: 2)
    }

    func hideHUD () {
        let HUD = self.hud()
        HUD?.dismiss()
        BaseViewController.HUD = nil
    }
}
