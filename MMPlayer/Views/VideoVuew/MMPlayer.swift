//
//  MMPlayer.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 16/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/// play state
///
/// - none: none
/// - playing: playing
/// - paused: pause
/// - playFinished: finished
/// - error: play failed
public enum MMPlayerState: Int {
    case none            // default
    case playing
    case paused
    case playFinished
    case error
}

/// buffer state which basically used for activiry inicator
///
/// - none: none
/// - readyToPlay: ready To Play
/// - buffering: buffered
/// - stop : buffer error stop
/// - bufferFinished: finished
public enum MMPlayerBufferstate: Int {
    case none           // default
    case readyToPlay
    case buffering
    case stop
    case bufferFinished
}

/// play video content mode
///
/// - resize: Stretch to fill layer bounds.
/// - resizeAspect: Preserve aspect ratio; fit within layer bounds.
/// - resizeAspectFill: Preserve aspect ratio; fill layer bounds.
public enum MMVideoGravityMode: Int {
    case resize
    case resizeAspect      // default
    case resizeAspectFill
}

/// play background mode
///
/// - suspend: suspend
/// - autoPlayAndPaused: auto play and Paused
/// - proceed: continue
public enum MMPlayerBackgroundMode: Int {
    case suspend
    case autoPlayAndPaused
    case proceed
}

public protocol MMPlayerDelegate: class {
    // play state
    func mmPlayer(_ player: MMPlayer, stateDidChange state: MMPlayerState)
    // player Duration
    func mmPlayer(_ player: MMPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    // buffer state
    func mmPlayer(_ player: MMPlayer, bufferStateDidChange state: MMPlayerBufferstate)
    // buffered Duration
    func mmPlayer(_ player: MMPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    // play error
    func mmPlayer(_ player: MMPlayer, playerFailed error: MMPlayerError)
}

// MARK: - delegate methods optional
public extension MMPlayerDelegate {
    func mmPlayer(_ player: MMPlayer, stateDidChange state: MMPlayerState) {}
    func mmPlayer(_ player: MMPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func mmPlayer(_ player: MMPlayer, bufferStateDidChange state: MMPlayerBufferstate) {}
    func mmPlayer(_ player: MMPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func mmPlayer(_ player: MMPlayer, playerFailed error: MMPlayerError) {}
}

open class MMPlayer: NSObject {
    
    open var state: MMPlayerState = .none {
        didSet {
            if state != oldValue {
                self.displayView.playStateDidChange(state)
                self.delegate?.mmPlayer(self, stateDidChange: state)
            }
        }
    }
    
    open var bufferState : MMPlayerBufferstate = .none {
        didSet {
            if bufferState != oldValue {
                self.displayView.bufferStateDidChange(bufferState)
                self.delegate?.mmPlayer(self, bufferStateDidChange: bufferState)
            }
        }
    }
    
    open var displayView : MMPlayerView
    
    open var gravityMode : MMVideoGravityMode = .resizeAspect
    open var backgroundMode : MMPlayerBackgroundMode = .autoPlayAndPaused
    open var bufferInterval : TimeInterval = 2.0
    open weak var delegate : MMPlayerDelegate?
    
    open fileprivate(set) var mediaFormat : MMPlayerMediaFormat
    open fileprivate(set) var totalDuration : TimeInterval = 0.0
    open fileprivate(set) var currentDuration : TimeInterval = 0.0
    open fileprivate(set) var buffering : Bool = false
    open fileprivate(set) var player : AVPlayer? {
        willSet{
            removePlayerObservers()
        }
        didSet {
            addPlayerObservers()
        }
    }
    private var timeObserver: Any?
    
    open fileprivate(set) var playerItem : AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            addPlayerItemObservers()
            addPlayerNotifications()
        }
    }
    
    open fileprivate(set) var playerAsset : AVURLAsset?
    open fileprivate(set) var contentURL : URL?
    
    open fileprivate(set) var error : MMPlayerError
    
    fileprivate var seeking : Bool = false
    //fileprivate var resourceLoaderManager = MMPlayerResourceLoaderManager()
    
    
    //MARK:- life cycle
    public init(URL: URL?, playerView: MMPlayerView?) {
        mediaFormat = MMPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        error = MMPlayerError()
        if let view = playerView {
            displayView = view
        } else {
            displayView = MMPlayerView.initializeXib(with: CGRect.zero)
        }
        super.init()
        if contentURL != nil {
            configurationPlayer(contentURL!)
        }
    }
    
    public convenience init(URL: URL) {
        self.init(URL: URL, playerView: nil)
    }
    
    public convenience init(playerView: MMPlayerView) {
        self.init(URL: nil, playerView: playerView)
    }
    
    public override convenience init() {
        self.init(URL: nil, playerView: nil)
    }
    
    deinit {
        removePlayerNotifations()
        cleanPlayer()
        displayView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func configurationPlayer(_ URL: URL) {
        self.displayView.setmmPlayer(mmPlayer: self)
        self.playerAsset = AVURLAsset(url: URL, options: .none)
        if URL.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"];
            playerItem = AVPlayerItem(asset: playerAsset!, automaticallyLoadedAssetKeys: keys)
        } else {
            // remote add cache
            playerItem = AVPlayerItem(url: URL)
        }
        player = AVPlayer(playerItem: playerItem)
        displayView.reloadPlayerView()
    }
    
    // time KVO
    internal func addPlayerObservers() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] time in
            guard let strongSelf = self else { return }
            if let currentTime = strongSelf.player?.currentTime().seconds, let totalDuration = strongSelf.player?.currentItem?.duration.seconds {
                strongSelf.currentDuration = currentTime
                strongSelf.delegate?.mmPlayer(strongSelf, playerDurationDidChange: currentTime, totalDuration: totalDuration)
                strongSelf.displayView.playerDurationDidChange(currentTime, totalDuration: totalDuration)
            }
        })
    }
    
    internal func removePlayerObservers() {
        player?.removeTimeObserver(timeObserver!)
    }
    
}

//MARK: - public
extension MMPlayer {
    
    open func replaceVideo(_ URL: URL) {
        reloadPlayer()
        mediaFormat = MMPlayerUtils.decoderVideoFormat(URL)
        contentURL = URL
        configurationPlayer(URL)
    }
    
    open func reloadPlayer() {
        seeking = false
        totalDuration = 0.0
        currentDuration = 0.0
        error = MMPlayerError()
        state = .none
        buffering = false
        bufferState = .none
        cleanPlayer()
    }
    
    open func cleanPlayer() {
        player?.pause()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerAsset?.cancelLoading()
        playerAsset = nil
        playerItem?.cancelPendingSeeks()
        playerItem = nil
    }
    
    open func play() {
        if contentURL == nil { return }
        player?.play()
        state = .playing
        displayView.play()
    }
    
    open func pause() {
        guard state == .paused else {
            player?.pause()
            state = .paused
            displayView.pause()
            return
        }
    }
    
    open func seekTime(_ time: TimeInterval) {
        seekTime(time, completion: nil)
    }
    
    open func seekTime(_ time: TimeInterval, completion: ((Bool) -> Swift.Void)?) {
        if time.isNaN  {
            if completion != nil {
                completion!(false)
            }
            return
        }
        
        DispatchQueue.main.async { [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.seeking = true
            strongSelf.startPlayerBuffering()
            strongSelf.playerItem?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { (finished) in
                DispatchQueue.main.async {
                    strongSelf.seeking = false
                    strongSelf.stopPlayerBuffering()
                    strongSelf.play()
                    if completion != nil {
                        completion!(finished)
                    }
                }
            })
        }
    }
    
}


//MARK: - private
extension MMPlayer {
    
    internal func startPlayerBuffering() {
        pause()
        bufferState = .buffering
        buffering = true
    }
    
    internal func stopPlayerBuffering() {
        bufferState = .stop
        buffering = false
    }
    
    internal func collectPlayerErrorLogEvent() {
        error.playerItemErrorLogEvent = playerItem?.errorLog()?.events
        error.error = playerItem?.error
        error.extendedLogData = playerItem?.errorLog()?.extendedLogData()
        error.extendedLogDataStringEncoding = playerItem?.errorLog()?.extendedLogDataStringEncoding
    }
}

//MARK: - Notifation Selector & KVO
private var playerItemContext = 0

extension MMPlayer {
    
    internal func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
    }
    
    internal func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MMPlayer.playerItemDidPlayToEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MMPlayer.applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MMPlayer.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    internal func removePlayerItemObservers() {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
    }
    
    internal func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    @objc internal func playerItemDidPlayToEnd(_ notification: Notification) {
        if state != .playFinished {
            state = .playFinished
        }
        
    }
    
    @objc internal func applicationWillEnterForeground(_ notification: Notification) {
        
        if let playerLayer = displayView.playerLayer  {
            playerLayer.player = player
        }
        
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            play()
        case .proceed:
            break
        }
    }
    
    @objc internal func applicationDidEnterBackground(_ notification: Notification) {
        
        if let playerLayer = displayView.playerLayer  {
            playerLayer.player = nil
        }

        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            pause()
        case .proceed:
            play()
            break
        }
    }
}

extension MMPlayer {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &playerItemContext) {
            
            if keyPath == #keyPath(AVPlayerItem.status) {
                let status: AVPlayerItem.Status
                if let statusNumber = change?[.newKey] as? NSNumber {
                    status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
                } else {
                    status = .unknown
                }
                
                switch status {
                case .unknown:
                    startPlayerBuffering()
                case .readyToPlay:
                    bufferState = .readyToPlay
                case .failed:
                    state = .error
                    collectPlayerErrorLogEvent()
                    stopPlayerBuffering()
                    delegate?.mmPlayer(self, playerFailed: error)
                    displayView.playFailed(error)
                @unknown default:
                    print("@unknown default")
                }
                
            } else if keyPath == #keyPath(AVPlayerItem.playbackBufferEmpty){
                
                if let playbackBufferEmpty = change?[.newKey] as? Bool {
                    if playbackBufferEmpty {
                        startPlayerBuffering()
                    }
                }
            } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
                
                let loadedTimeRanges = player?.currentItem?.loadedTimeRanges
                if let bufferTimeRange = loadedTimeRanges?.first?.timeRangeValue {
                    let star = bufferTimeRange.start.seconds         // The start time of the time range.
                    let duration = bufferTimeRange.duration.seconds  // The duration of the time range.
                    let bufferTime = star + duration
                    
                    if let itemDuration = playerItem?.duration.seconds {
                        delegate?.mmPlayer(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                        displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                        totalDuration = itemDuration
                        if itemDuration == bufferTime {
                            bufferState = .bufferFinished
                        }
                        
                    }
                    if let currentTime = playerItem?.currentTime().seconds{
                        if (bufferTime - currentTime) >= bufferInterval && state != .paused {
                            play()
                        }
                        
                        if (bufferTime - currentTime) < bufferInterval {
                            bufferState = .buffering
                            buffering = true
                        } else {
                            buffering = false
                            bufferState = .readyToPlay
                        }
                    }
                    
                } else {
                    play()
                }
            }
            
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

