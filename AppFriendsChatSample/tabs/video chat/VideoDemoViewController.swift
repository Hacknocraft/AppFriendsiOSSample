//
//  VideoDemoViewController.swift
//  AFChatUISample
//
//  Created by HAO WANG on 10/15/17.
//  Copyright © 2017 hacknocraft. All rights reserved.
//

import UIKit
import AVKit

class VideoDemoViewController: BaseViewController {

    @IBOutlet weak var videoHolder: UIView!
    @IBOutlet weak var chatHolder: UIView!

    lazy var playerView: AVPlayerLayer = {
        let url = "https://tungsten.aaplimg.com/VOD/bipbop_adv_example_hevc/master.m3u8"
        let player = AVPlayer(url: URL(string: url)!)
        var pv = AVPlayerLayer(player: player)
        pv.videoGravity = .resizeAspect

        return pv
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        if let tabBarImage = UIImage(named: "tabbarOnAir") {
            let customTabBarItem: UITabBarItem = UITabBarItem(title: "Live",
                                                              image: tabBarImage.withRenderingMode(.alwaysOriginal),
                                                              selectedImage: tabBarImage)
            self.tabBarItem = customTabBarItem
        }
        self.hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Live Video"
//        addVideo()
        addchat()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addVideo() {
        self.playerView.frame = videoHolder.bounds
        videoHolder.layer.addSublayer(self.playerView)
        playerView.player?.play()
    }

    func addchat() {
        if let videoChat = VideoChatViewController(dialogID: "16ab804b-c1c4-40a2-b347-a29cafcded0d") {
            videoChat.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addVC(vc: videoChat)
        }
    }

    func addVC(vc: UIViewController) {
        self.addChildViewController(vc)
        vc.view.frame = self.chatHolder.bounds
        self.chatHolder.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
}
