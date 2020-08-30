//
//  DetailsViewController.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 25/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSource: RoundedCornerLabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    
    var video : Video?
    fileprivate var player : MMPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        checkAndSetPlayer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func checkAndSetPlayer() {
        guard (video != nil) else {
            return
        }
        let url : URL = URL(string:video!.video_url!)!
        self.player = MMPlayer(URL: url)
        self.player!.seekTime(video!.played_duration)
        //self.player!.play()
        self.player!.backgroundMode = .proceed
        setDisplayView()
    }
    
    /// This method is to add the video preview and set constraints
    func setDisplayView() {
        preloadData()
        videoPreview.addSubview(self.player!.displayView)
        self.player!.delegate = self
        self.player!.displayView.delegate = self
        self.player!.displayView.titleLabel.text = ""
        self.player!.displayView.translatesAutoresizingMaskIntoConstraints = false
        
        videoPreview.addConstraint(NSLayoutConstraint(item: self.player!.displayView, attribute: .trailing, relatedBy: .equal, toItem: videoPreview, attribute: .trailing, multiplier: 1, constant: 0))
        videoPreview.addConstraint(NSLayoutConstraint(item: self.player!.displayView, attribute: .leading, relatedBy: .equal, toItem: videoPreview, attribute: .leading, multiplier: 1, constant: 0))
        videoPreview.addConstraint(NSLayoutConstraint(item: self.player!.displayView, attribute: .top, relatedBy: .equal, toItem: videoPreview, attribute: .top, multiplier: 1, constant: 0))
        videoPreview.addConstraint(NSLayoutConstraint(item: self.player!.displayView, attribute: .bottom, relatedBy: .equal, toItem: videoPreview, attribute: .bottom,multiplier: 1, constant: 0))
    }
    
    /// this method is to set preload data
    func preloadData() {
        lblTitle.text = video!.name
        lblSource.text = video!.source
        lblDetails.text = video!.details
        btnFav.isSelected = video!.is_fav
    }
    
    //MARK: Button action
    @IBAction func favButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let  fav = sender.isSelected
        DispatchQueue.global(qos: .background).async {
            VideoDBM.shared.updateFavValue(isFav: fav, for: self.video!.id!)
        }
    }
    
}
extension DetailsViewController: MMPlayerDelegate {
    func  mmPlayer(_ player: MMPlayer, playerFailed error: MMPlayerError) {
        print(error)
    }
    func  mmPlayer(_ player: MMPlayer, stateDidChange state: MMPlayerState) {
        print("player State ",state)
    }
    func  mmPlayer(_ player: MMPlayer, bufferStateDidChange state: MMPlayerBufferstate) {
        print("buffer State", state)
    }
    
}

extension DetailsViewController : MMPlayerViewDelegate {
    
    func  mmPlayerView(_ playerView: MMPlayerView, willFullscreen fullscreen: Bool) {
        
    }
    func  mmPlayerView(didTappedClose playerView: MMPlayerView) {
        if playerView.isFullScreen {
            playerView.exitFullscreen()
        } else {
            PIPManager.shared.video = video
            PIPManager.shared.player = player
            player.displayView.startInAppPIPMode()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    func  mmPlayerView(didDisplayControl playerView: MMPlayerView) {
        UIApplication.shared.setStatusBarHidden(!playerView.isDisplayControl, with: .fade)
    }
    func mmPlayerView(didExitPIPMode playerView: MMPlayerView){
        video = PIPManager.shared.video
        player = PIPManager.shared.player
        setDisplayView()
    }
}
