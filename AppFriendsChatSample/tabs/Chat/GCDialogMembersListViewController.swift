//
//  GCDialogMembersListViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 10/19/16.
//  Copyright © 2016 hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI

class GCDialogMembersListViewController: BaseViewController,
UITableViewDelegate, UITableViewDataSource,
GCDialogContactsPickerViewControllerDelegate, AFEventSubscriber {

    @IBOutlet weak var tableView: UITableView!

    var _members: [AFUser]?
    var _dialog: AFDialog

    init(dialog: AFDialog) {

        _members = dialog.members
        _dialog = dialog

        super.init(nibName: "GCDialogMembersListViewController", bundle: nil)

        self.title = title
        AFEvent.subscribe(subscriber: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "GCContactTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "GCContactTableViewCell")
        self.tableView.backgroundColor = AppFriendsColor.coolGreyLighter
        self.tableView.tableFooterView = tableFooterView()
        self.tableView.tableHeaderView = tableHeaderView()

        self.navigationItem.leftBarButtonItem = leftBarButtonItem()
        self.navigationItem.rightBarButtonItem = rightBarButtonItem()

        self.title = "Group Members"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableFooterView() -> UIView? {

        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 75)
        footerView.addBorderTop(size: 1, color: AppFriendsColor.coolGray!)

        return footerView
    }

    func tableHeaderView() -> UIView? {

        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.w, height: 25)
        headerView.addBorderBottom(size: 1, color: AppFriendsColor.coolGray!)

        return headerView
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let members = _members {
            return members.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GCContactTableViewCell",
                                                       for: indexPath) as? GCContactTableViewCell else {
                                                        return GCContactTableViewCell()
        }

        if let member = self._members?[(indexPath as NSIndexPath).row] {

            if member.username.isEmpty {
                cell.userNameLabel.text = UsersDataBase.sharedInstance.findUserName(member.id)
            } else {
                cell.userNameLabel.text = member.username
            }
            cell.userNameLabel.textColor = AppFriendsColor.charcoalGrey!
            cell.selectionStyle = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    // MARK: - navigation items

    func rightBarButtonItem() -> UIBarButtonItem {

        // add more members

        let newConversationItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                  target: self,
                                                  action: #selector(GCDialogMembersListViewController.addMember))
        return newConversationItem
    }

    func leftBarButtonItem() -> UIBarButtonItem? {

        let icon = UIImage(named: "ic_left_arrow")
        let closeItem = UIBarButtonItem(image: icon,
                                        style: .plain,
                                        target: self,
                                        action: #selector(GCDialogMembersListViewController.close))
        return closeItem
    }

    func close() {

        _ = self.navigationController?.popViewController(animated: true)
    }

    func addMember() {

        var memberIDs = [String]()
        if let members = _members {
            for member in members {
                memberIDs.append(member.id)
            }
        }
        let contactSelectionVC = GCDialogContactsPickerViewController(viewTitle:"Add Members", excludeUsers: memberIDs)
        contactSelectionVC.delegate = self
        self.navigationController?.pushViewController(contactSelectionVC, animated: true)
    }

    // MARK: - GCDialogContactsPickerViewControllerDelegate

    func usersSelected(_ users: [String]) {

        _dialog.addMembers(newMembers: users) { (error) in

            if error != nil {
                self.showErrorWithMessage(error?.localizedDescription)
            } else if users.count > 0 {
                self.showSuccessWithMessage("Added \(users.count) members.")
            }
        }
    }

    // MARK: - AFEventSubscriber

    func emitEvent(_ event: AFEvent) {

        if event.name == .eventDialogUpdated,
            let dialog = event.data as? AFDialog,
            dialog.id == self._dialog.id {
            _members = dialog.members
            self.tableView?.reloadData()
        }
    }
}
