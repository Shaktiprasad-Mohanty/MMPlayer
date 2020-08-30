//
//  HomeViewController.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 25/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    //storyboard references
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var coresalCollectionView: UICollectionView!
    @IBOutlet weak var freshReleaseCollectionView: UICollectionView!
    @IBOutlet weak var tendingTableView: UITableView!
    @IBOutlet weak var trendingListHeight: NSLayoutConstraint!
    
    ///Variable intialization
    fileprivate var coresalVideos = [Video]()
    fileprivate var newReleaseVideos = [Video]()
    fileprivate var trendingVideos = [Video]()
    
    
    //variables to manage coresal view auto scrooling
    fileprivate var autoScrollTimer : Timer?
    fileprivate var currentIndex:Int = 0
    
    // custom tableview / collection cell names
    fileprivate let coresalCellId = "CoresalCell"
    fileprivate let newReleaseCellId = "NewReleaseCell"
    fileprivate let trendingCellId = "VideoTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshData()
    }

    // MARK: - View WillAppear -
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Table view height based on the cell
        self.autoScrollTimer?.fire()
        tendingTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    // MARK: - View WillDisappear -
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.autoScrollTimer?.invalidate()
        self.tendingTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
    /// This method is to load fresh data from coredata and reload UI
    func refreshData() {
        let concurrentQueue = DispatchQueue(label: "com.mmplayer.currentQueue", attributes: .concurrent)
        concurrentQueue.async {
            self.coresalVideos = VideoDBM.shared.fetchForCoresal()
            self.newReleaseVideos = VideoDBM.shared.fetchForNewRelease()
            self.trendingVideos = VideoDBM.shared.fetchForTreding()
            DispatchQueue.main.async {
                self.coresalCollectionView.reloadData()
                self.freshReleaseCollectionView.reloadData()
                self.tendingTableView.reloadData()
                self.autoScrollTimer?.invalidate()
                self.startImageSliding()
            }
        }
        
    }
    
    ///This Method is to play video in PIP mode if PIP mode activated / navigate to details screen with video
    func playVideo(video : Video) {
        if let player = PIPManager.shared.player {
            player.pause()
            VideoDBM.shared.updateLastPlayedDuration(duration: player.currentDuration, for: PIPManager.shared.video!.id!)
            PIPManager.shared.video = video
            player.replaceVideo(URL(string:video.video_url!)!)
            player.play()
            return
        }
        
        let detailVC = CommonUtility.getVcObject(vcName: "DetailsViewController") as! DetailsViewController
        detailVC.video = video
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
}


//MARK: Collection view delegate method
extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == coresalCollectionView {
            return coresalVideos.count
        } else {
            return newReleaseVideos.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell : VideoCollectionViewCell
        var video : Video
        if collectionView == coresalCollectionView {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: coresalCellId, for: indexPath) as! VideoCollectionViewCell
            video = coresalVideos[indexPath.row]
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: newReleaseCellId, for: indexPath) as! VideoCollectionViewCell
            video = newReleaseVideos[indexPath.row]
        }
        cell.lblSource?.text = video.source
        cell.lblTitle.text = video.name
        ImageDownloader.shared.setImage(urlString: video.image_url ?? "", imageView: cell.thumbnailView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == coresalCollectionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            let height = collectionView.frame.height
            return CGSize(width: height * 1.78, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var video : Video
        if collectionView == coresalCollectionView {
            video = coresalVideos[indexPath.row]
        } else {
            video = newReleaseVideos[indexPath.row]
        }
        playVideo(video: video)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == coresalCollectionView {
            self.autoScrollTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.getVisibleIndex()
            }
        } else {
            
        }
    }
    func getVisibleIndex (){
        let page = coresalCollectionView.contentOffset.x / coresalCollectionView.frame.width
        self.pageController.currentPage = Int(page.rounded(.toNearestOrAwayFromZero))
         currentIndex = self.pageController.currentPage
        self.pageController.numberOfPages = coresalVideos.count
        startImageSliding()
    }
}

extension HomeViewController{
    
    func startImageSliding() {
        if self.autoScrollTimer != nil {
            self.autoScrollTimer?.invalidate()
            self.autoScrollTimer = nil
        }
        self.autoScrollTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.collectionViewScroll), userInfo: nil, repeats: false )
    }
    @objc func collectionViewScroll() {
        if currentIndex < self.coresalVideos.count-1 {
        currentIndex = currentIndex + 1
        let index = IndexPath.init(item: currentIndex , section: 0)
        self.coresalCollectionView.scrollToItem(at: index, at: .right, animated: true)
        } else {
          currentIndex = 0
            let index = IndexPath.init(item: currentIndex , section: 0)
            self.coresalCollectionView.scrollToItem(at: index, at: .right, animated: false)
        }
        
    }
  
}


//MARK: TableView Delegate method
extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingVideos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: trendingCellId) as! VideoTableViewCell
        let video = trendingVideos[indexPath.row]
        ImageDownloader.shared.setImage(urlString: video.image_url ?? "", imageView: cell.thumbnailView)
        cell.lblSource.text = video.source
        cell.lblTitle.text = video.name
        /// this is to set height for table view according to the content height
        print("indexPath.row\(indexPath.row)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playVideo(video: trendingVideos[indexPath.row])
    }
    ///Set the table view observer for handle table view height as based on the rows
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.tendingTableView && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    self.trendingListHeight.constant = newSize.height
                    self.tendingTableView.invalidateIntrinsicContentSize()
                    self.tendingTableView.layoutIfNeeded()
                }
            }
        }
    }
    
}
