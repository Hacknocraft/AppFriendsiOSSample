//
//  GCChatViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/3/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit

private let GCInfoBannerViewHeight: CGFloat = 44.0

@objc
protocol GCInfoBannerViewDelegate {
    
    func groupTitleChanged(_ bannerView: GCInfoBannerView, text: String)
}

class GCInfoBannerView: UIView, UITextFieldDelegate {
    
    let textField = UITextField()
    let divider = UIView()
    let closeButton = UIButton(type: .custom)
    
    fileprivate var topLayoutConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!
    weak fileprivate var topViewController: UIViewController?
    
    weak var delegate: GCInfoBannerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.borderStyle = .none
        self.textField.font = UIFont.systemFont(ofSize: 14.0)
        self.textField.textColor = AppFriendsColor.charcoalGrey
        self.textField.placeholder = "Name this group"
        self.textField.returnKeyType = .done
        self.textField.delegate = self
        self.addSubview(self.textField)
        
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        self.closeButton.setGMDIcon(.gmdClose, forState: .normal)
        self.closeButton.setTitleColor(AppFriendsColor.blue, for: .normal)
        self.closeButton.addTarget(self, action: #selector(hideAnimated), for: .touchUpInside)
        self.addSubview(self.closeButton)
        
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        self.divider.backgroundColor = AppFriendsColor.coolGray
        self.addSubview(self.divider)
    }
    
    override func updateConstraints() {
        var topOffset: CGFloat = 0.0
        
        if self.topViewController?.edgesForExtendedLayout == .all || self.topViewController?.edgesForExtendedLayout == .top {
            topOffset += 20.0 // add status bar height
            if let navigationController = self.topViewController?.parent as? UINavigationController {
                if navigationController.isNavigationBarHidden == false {
                    topOffset += navigationController.navigationBar.frame.height
                }
            }
        }
        
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1.0, constant: topOffset),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            self.heightConstraint,
            
            // closeButton
            NSLayoutConstraint(item: self.closeButton, attribute: .centerY, relatedBy: .equal, toItem: self.textField, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.closeButton, attribute: .left, relatedBy: .equal, toItem: self.textField, attribute: .right, multiplier: 1.0, constant: 5.0),
            
            // textField
            NSLayoutConstraint(item: self.textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.textField, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: self.textField, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0.0),
            
            // bottom divider
            NSLayoutConstraint(item: self.divider, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.divider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 1.0),
            NSLayoutConstraint(item: self.divider, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0),
            
        ])
        
        super.updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    /**
    Shows the Info Banner View
    
    - parameter topViewController: the view controller you want to specifically show
    
    - returns: The current Info Banner View
    */
    func show(inController topViewController: UIViewController? = nil) -> Self {
        // get top view controller
        if let topViewController = topViewController {
            self.topViewController = topViewController
        } else {
            self.topViewController = GCInfoBannerView.topViewController()
        }
        
        // add to view
        self.topViewController!.view.addSubview(self)
        self.topViewController!.view.layoutIfNeeded()
        self.topViewController!.view.updateConstraintsIfNeeded()
        // set height of the info banner view
        self.heightConstraint.constant = self.infoBannerViewHeight()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.layoutIfNeeded()
        })
        
        return self
    }
    
    /**
     Hide the Info Banner View
     
     - parameter delay:    the delay before it will dismissed
     - parameter animated: boolean if you want to hide if animated or not
     */
    func hide(afterDelay delay: Double? = nil, animated: Bool = true) {
        if let delay = delay {
            let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.hideInfoBannerView(animated)
            }
        } else {
            self.hideInfoBannerView(animated)
        }
    }
    
    func hideAnimated() {
        self.hide(afterDelay: 0, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let d = self.delegate, let text = textField.text , !text.isBlank {
            d.groupTitleChanged(self, text: text)
        }
        
        textField.resignFirstResponder()
        return false
    }
}

extension GCInfoBannerView {
    // MARK: Private Methods
    func infoBannerViewHeight() -> CGFloat {
        return GCInfoBannerViewHeight
    }
    
    func hideInfoBannerView(_ animated: Bool = true) {
        // if already removed then just return
        guard let _ = self.superview else {
            return
        }
        
        if animated {
            // set height back to 0
            self.heightConstraint.constant = 0.0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.superview!.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
