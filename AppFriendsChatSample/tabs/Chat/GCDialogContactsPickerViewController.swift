//
//  GCDialogStarterViewController.swift
//  GCAFDemo
//
//  Created by HAO WANG on 10/2/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsCore
import AppFriendsUI

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

@objc
public protocol GCDialogContactsPickerViewControllerDelegate {

    func usersSelected(_ users: [String])
}

class GCDialogContactsPickerViewController: BaseViewController,
UITableViewDelegate, UITableViewDataSource, AFTokenInputViewDelegate {

    @IBOutlet weak var receipientBar: GCReceipientBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var receipientBarHeightConstraint: NSLayoutConstraint!

    var userInfos: [[String: AnyObject]] = [[String: AnyObject]]()
    var sectionedUserInfos: [String: [[String: AnyObject]]] = [String: [[String: AnyObject]]]()
    var sectionKeys: [String] = [String]()
    var filteredSectionedUserInfos: [String: [[String: AnyObject]]]?
    var filteredSectionKeys: [String]?

    var userSelectedIDs: [String] = [String]()
    var excludeIDs: [String] = [String]()

    let sectionTitles = ["A", "B", "C", "D", "E", "F",
                         "G", "H", "I", "J", "K", "L",
                         "M", "N", "O", "P", "Q", "R",
                         "S", "T", "U", "V", "W", "X", "Y", "Z"]

    weak var delegate: GCDialogContactsPickerViewControllerDelegate?

    init(viewTitle title: String?, excludeUsers: [String]?) {

        super.init(nibName: "GCDialogContactsPickerViewController", bundle: nil)

        if let excludes = excludeUsers {
            self.excludeIDs.append(contentsOf: excludes)
        }

        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = leftBarButtonItem()
        self.navigationItem.rightBarButtonItem = rightBarButtonItem()

        loadUserData()
        distributeUsersInfoSections()

        let nib = UINib(nibName: "GCContactSelectionTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GCContactSelectionTableViewCell")
        self.tableView.backgroundColor = AppFriendsColor.coolGreyLighter
        self.tableView.tableFooterView = UIView()
        self.automaticallyAdjustsScrollViewInsets = false
        styleReceipientBar()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - style view

    func styleReceipientBar() {

        receipientBar.fieldName = "To:"
        receipientBar.fieldColor = AppFriendsColor.charcoalGrey!
        receipientBar.tokenizationCharacters = [", "]
        receipientBar.delegate = self
    }

    // MARK: - load user data

    func loadUserData() {

        let users = UsersDataBase.sharedInstance.userInfos
        for userInfo in users {
            guard let loginInfo = userInfo["login"] as? [String: String] else {
                continue
            }
            if let userID = loginInfo["md5"],
                userID != HCSDKCore.sharedInstance.currentUserID() && !self.excludeIDs.contains(userID) {
                userInfos.append(userInfo)
            }
        }
    }

    func distributeUsersInfoSections() {

        // change this method to load your own user data

        sectionKeys = [String]()

        for sectionTitle in sectionTitles {
            self.sectionedUserInfos[sectionTitle] = self.userInfos.filter({ (userInfo) -> Bool in
                if let nameInfo = userInfo["name"] as? [String: String] {
                    let userName = "\(nameInfo["first"] ?? "") \(nameInfo["last"] ?? "")"
                    return userName.lowercased().hasPrefix(sectionTitle.lowercased())
                } else {
                    return false
                }
            })

            if self.sectionedUserInfos[sectionTitle]?.count > 0 {

                sectionKeys.append(sectionTitle)
            }
        }
    }

    func filterUsersInfo(_ text: String) {

        filteredSectionKeys = [String]()
        filteredSectionedUserInfos = [String: [[String: AnyObject]]]()

        for sectionTitle in sectionTitles {
            self.filteredSectionedUserInfos![sectionTitle] = self.userInfos.filter({ (userInfo) -> Bool in
                if let nameInfo = userInfo["name"] as? [String: String] {
                    let userName = "\(nameInfo["first"] ?? "") \(nameInfo["last"] ?? "")"
                    return userName.lowercased().hasPrefix(sectionTitle.lowercased()) &&
                        userName.lowercased().contains(text.lowercased())
                } else {
                    return false
                }
            })

            if self.filteredSectionedUserInfos![sectionTitle]?.count > 0 {

                filteredSectionKeys!.append(sectionTitle)
            }
        }
    }

    func userInfoAtIndexPath(_ indexPath: IndexPath) -> [String: AnyObject] {

        if let key = self.filteredSectionKeys?[(indexPath as NSIndexPath).section],
            let sectionsInfos = self.filteredSectionedUserInfos,
            let userInfos = sectionsInfos[key] {
            return userInfos[(indexPath as NSIndexPath).row]
        }

        let key = self.sectionKeys[(indexPath as NSIndexPath).section]
        if let userInfos = self.sectionedUserInfos[key] {
            return userInfos[(indexPath as NSIndexPath).row]
        }

        return [String: AnyObject]()
    }

    // MARK: - Navigation bar

    func rightBarButtonItem() -> UIBarButtonItem {

        // create new conversation button
        let newConversationItem = UIBarButtonItem(title: "Done",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(GCDialogContactsPickerViewController.done))
        return newConversationItem
    }

    func leftBarButtonItem() -> UIBarButtonItem? {

        let icon = UIImage(named: self.navigationController?.viewControllers.count > 1 ? "ic_left_arrow" : "ic_clear")
        let closeItem = UIBarButtonItem(image: icon,
                                        style: .plain,
                                        target: self,
                                        action: #selector(GCDialogContactsPickerViewController.close))
        return closeItem
    }

    func close() {
        if self.navigationController?.viewControllers.count > 1 {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.dismissVC(completion: nil)
        }
    }

    func done() {

        if self.userSelectedIDs.count > 0 {
            self.delegate?.usersSelected(self.userSelectedIDs)
        }
        close()
    }

    // MARK: tableview

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        if let keys = filteredSectionKeys {
            return keys
        } else {
            return sectionKeys
        }
    }

    func tableView(_ tableView: UITableView,
                   sectionForSectionIndexTitle title: String,
                   at index: Int) -> Int {

        if let keys = filteredSectionKeys, let section = keys.indexes(of: title).first {
            return section
        } else if let section = sectionKeys.indexes(of: title).first {
            return section
        }

        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if let keys = filteredSectionKeys {
            return keys[section]
        } else {
            return sectionKeys[section]
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = AppFriendsColor.coolGreyLighter
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 25)
        headerView.addBorderTop(size: 1, color: AppFriendsColor.coolGray!)
        headerView.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)

        let headerTitle = UILabel(x: 20, y: 0, w: tableView.w, h: 25, fontSize: 13)
        headerTitle.textColor = AppFriendsColor.coolGreyDark
        if let keys = filteredSectionKeys {
            headerTitle.text = keys[section]
        } else {
            headerTitle.text = sectionKeys[section]
        }

        headerView.addSubview(headerTitle)

        return headerView

    }

    func numberOfSections(in tableView: UITableView) -> Int {

        if let keys = filteredSectionKeys {
            return keys.count
        } else {
            return sectionKeys.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let key = self.filteredSectionKeys?[section],
            let sectionsInfos = self.filteredSectionedUserInfos,
            let userInfos = sectionsInfos[key] {
            return userInfos.count
        }

        let key = self.sectionKeys[section]
        if let userInfos = self.sectionedUserInfos[key] {
            return userInfos.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GCContactSelectionTableViewCell",
                                                       for: indexPath) as? GCContactTableViewCell else {
            return GCContactTableViewCell()
        }

        let userInfo = self.userInfoAtIndexPath(indexPath)
        if let nameInfo = userInfo["name"] as? [String: String],
            let loginInfo = userInfo["login"] as? [String: String] {

            let userName = "\(nameInfo["first"] ?? "") \(nameInfo["last"] ?? "")"
            cell.userNameLabel.text = userName
            if let userID = loginInfo["md5"] {
                cell.mark(selected: userSelectedIDs.contains(userID))
            }
        }
        cell.userNameLabel.textColor = AppFriendsColor.charcoalGrey!
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let userInfo = self.userInfoAtIndexPath(indexPath)
        guard let nameInfo = userInfo["name"] as? [String: String],
            let loginInfo = userInfo["login"] as? [String: String] else {
            return
        }
        let userName = "\(nameInfo["first"] ?? "") \(nameInfo["last"] ?? "")"
        let userID = loginInfo["md5"]!
        if userSelectedIDs.contains(userID) {
            userSelectedIDs.removeFirst(userID)
        } else {
            userSelectedIDs.append(userID)
        }

        let token = AFToken(displayText: userName, context: userID as NSObject?)
        if receipientBar.allTokens.contains(token) {
            receipientBar.remove(token)
        } else {
            receipientBar.add(token)
        }

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    // MARK: AFTokenInputViewDelegate
    func tokenInputView(_ view: AFTokenInputView, didRemove token: AFToken) {

        if let userID = token.context as? String {

            if userSelectedIDs.contains(userID) {
                userSelectedIDs.removeFirst(userID)
                self.tableView.reloadData()
            }
        }
    }

    func tokenInputView(_ view: AFTokenInputView, didChangeHeightTo height: CGFloat) {
        self.receipientBarHeightConstraint.constant = height
    }

    func tokenInputView(_ view: AFTokenInputView, didChangeText text: String?) {

        // filter users
        if let t = text, !t.isBlank {
            filterUsersInfo(t)
            self.tableView.reloadData()
        } else {
            self.filteredSectionedUserInfos = nil
            self.filteredSectionKeys = nil
            self.tableView.reloadData()
        }
    }
}
