//
//  VideoListViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 10/15/17.
//  Copyright © 2017 hacknocraft. All rights reserved.
//

import UIKit

class VideoListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func videoDemoButtonTapped(_ sender: Any) {
        let videoDemo = VideoDemoViewController()
        self.navigationController?.pushViewController(videoDemo)
    }

}
