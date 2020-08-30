//
//  MMPlayerView.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 16/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

public protocol MMPlayerViewDelegate: class {
    
    /// Fullscreen
    ///
    /// - Parameters:
    ///   - playerView: player view
    ///   - fullscreen: Whether full screen
    func mmPlayerView(_ playerView: MMPlayerView, willFullscreen isFullscreen: Bool)
    
    /// Close play view
    ///
    /// - Parameter playerView: player view
    func mmPlayerView(didTappedClose playerView: MMPlayerView)
    
    /// PIP mode ends
    ///
    /// - Parameter playerView: player view
    func mmPlayerView(didExitPIPMode playerView: MMPlayerView)
    
    /// Displaye control
    ///
    /// - Parameter playerView: playerView
    func mmPlayerView(didDisplayControl playerView: MMPlayerView)
    
}

// MARK: - delegate methods optional
public extension MMPlayerViewDelegate {
    
    func mmPlayerView(_ playerView: MMPlayerView, willFullscreen fullscreen: Bool){}
    
    func mmPlayerView(didTappedClose playerView: MMPlayerView) {}
    
    func mmPlayerView(didDisplayControl playerView: MMPlayerView) {}
}

public enum MMPlayerViewPanGestureDirection: Int {
    case vertical
    case horizontal
}


open class MMPlayerView: UIView {
    
    weak open var mmPlayer : MMPlayer?
    open var controlViewDuration : TimeInterval = 5.0  /// default 5.0
    open fileprivate(set) var playerLayer : AVPlayerLayer?
    open fileprivate(set) var isFullScreen : Bool = false
    open fileprivate(set) var isTimeSliding : Bool = false
    open fileprivate(set) var isDisplayControl : Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.mmPlayerView(didDisplayControl: self)
            }
        }
    }
    open weak var delegate : MMPlayerViewDelegate?
    // top view
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var timeSlider: MMPlayerSlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var loadingIndicator: MMPlayerLoadingIndicator!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    open var volumeSlider : UISlider!
    @IBOutlet weak var replayButton: UIButton!
    open fileprivate(set) var panGestureDirection : MMPlayerViewPanGestureDirection = .horizontal
    fileprivate var isVolume : Bool = false
    fileprivate var sliderSeekTimeValue : TimeInterval = .nan
    fileprivate var timer : Timer = {
        let time = Timer()
        return time
    }()
    
    fileprivate weak var parentView : UIView?
    fileprivate var viewFrame = CGRect()
    
    //Constraints for PIP mode
    fileprivate var trailing : NSLayoutConstraint?
    fileprivate var bottom : NSLayoutConstraint?
    fileprivate var width : NSLayoutConstraint?
    
    
    // GestureRecognizer
    open var singleTapGesture = UITapGestureRecognizer()
    open var doubleTapGesture = UITapGestureRecognizer()
    open var panGesture = UIPanGestureRecognizer()
    
    //MARK:- life cycle
    open override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
        self.playerLayer = AVPlayerLayer(player: nil)
        addDeviceOrientationNotifications()
        addGestureRecognizer()
        configurationVolumeSlider()
        configurationUI()
    }
    public class func initializeXib(with frame: CGRect) -> MMPlayerView {
        let bundle = Bundle(for: MMPlayerView.self)
        let view = bundle.loadNibNamed("MMPlayerView", owner: self, options: nil)?.first as! MMPlayerView
        view.frame = frame
        return view
    }
    
    required public init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    deinit {
        timer.invalidate()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplayerView(frame: bounds)
    }
    
    open func setmmPlayer(mmPlayer: MMPlayer) {
        self.mmPlayer = mmPlayer
    }
    
    open func reloadPlayerLayer() {
        playerLayer = AVPlayerLayer(player: self.mmPlayer?.player)
        layer.insertSublayer(self.playerLayer!, at: 0)
        updateDisplayerView(frame: self.bounds)
        timeSlider.isUserInteractionEnabled = mmPlayer?.mediaFormat != .m3u8
        reloadGravity()
    }
    
    
    /// play state did change
    ///
    /// - Parameter state: state
    open func playStateDidChange(_ state: MMPlayerState) {
        playButton.isSelected = state == .playing
        replayButton.isHidden = !(state == .playFinished)
        replayButton.isHidden = !(state == .playFinished)
        if state == .playing || state == .playFinished {
            setupTimer()
        }
        if state == .playFinished {
            loadingIndicator.isHidden = true
        }
    }
    
    /// buffer state change
    ///
    /// - Parameter state: buffer state
    open func bufferStateDidChange(_ state: MMPlayerBufferstate) {
        if state == .buffering {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
        
        var current = formatSecondsToString((mmPlayer?.currentDuration)!)
        if (mmPlayer?.totalDuration.isNaN)! {  // HLS
            current = "00:00"
        }
        if state == .readyToPlay && !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString((mmPlayer?.totalDuration)!)))"
        }
    }
    
    /// buffer duration
    ///
    /// - Parameters:
    ///   - bufferedDuration: buffer duration
    ///   - totalDuration: total duratiom
    open func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        timeSlider.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    /// player diration
    ///
    /// - Parameters:
    ///   - currentDuration: current duration
    ///   - totalDuration: total duration
    open func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        sliderSeekTimeValue = currentDuration
        var current = formatSecondsToString(currentDuration)
        if totalDuration.isNaN {  // HLS
            current = "00:00"
        }
        if !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString(totalDuration)))"
            timeSlider.value = Float(currentDuration / totalDuration)
        }
    }
    
    open func configurationUI() {
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    open func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
        timeSlider.value = Float(0)
        timeSlider.setProgress(0, animated: false)
        replayButton.isHidden = true
        isTimeSliding = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        timeLabel.text = "--:-- / --:--"
        reloadPlayerLayer()
    }
    
    /// To toggle control view visibility
    ///
    /// - Parameter display: is display
    open func displayControlView(_ isDisplay:Bool) {
        if isDisplay {
            displayControlAnimation()
        } else {
            hiddenControlAnimation()
        }
    }
}

// MARK: - public
extension MMPlayerView {
    
    open func updateDisplayerView(frame: CGRect) {
        playerLayer?.frame = frame
    }
    
    open func reloadGravity() {
        if mmPlayer != nil {
            switch mmPlayer!.gravityMode {
            case .resize:
                playerLayer?.videoGravity = .resize
            case .resizeAspect:
                playerLayer?.videoGravity = .resizeAspect
            case .resizeAspectFill:
                playerLayer?.videoGravity = .resizeAspectFill
            }
        }
    }

    open func enterFullscreen() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait{
            parentView = (self.superview)!
            viewFrame = self.frame
        }
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIApplication.shared.statusBarOrientation = .landscapeRight
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    open func exitFullscreen() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIApplication.shared.statusBarOrientation = .portrait
    }
    
    /// play failed
    ///
    /// - Parameter error: error
    open func playFailed(_ error: MMPlayerError) {
        // error
    }
    
    public func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN{
            return "00:00"
        }
        let interval = Int(seconds)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let min = interval / 60
        return String(format: "%02d:%02d", min, sec)
    }
}

// MARK: - private
extension MMPlayerView {
    
    internal func play() {
        playButton.isSelected = true
    }
    
    internal func pause() {
        playButton.isSelected = false
    }
    
    internal func displayControlAnimation() {
        bottomView.isHidden = false
        topView.isHidden = false
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1
            self.topView.alpha = 1
        }) { (completion) in
            self.setupTimer()
        }
    }
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0
            self.topView.alpha = 0
        }) { (completion) in
            self.bottomView.isHidden = true
            self.topView.isHidden = true
        }
    }
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.mmPlayer_scheduledTimerWithTimeInterval(self.controlViewDuration, block: {  [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
        }, repeats: false)
    }
    internal func addDeviceOrientationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
    
    internal func configurationVolumeSlider() {
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider {
            volumeSlider = view
        }
    }
}


// MARK: - GestureRecognizer
extension MMPlayerView {
    internal func addGestureRecognizer() {
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSingleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delegate = self
        addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension MMPlayerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? MMPlayerView != nil) {
            return true
        }
        return false
    }
}

// MARK: - Event
extension MMPlayerView {
    ///To change the seek time on Slider slide
    @IBAction internal func timeSliderValueChanged(_ sender: MMPlayerSlider) {
        isTimeSliding = true
        if let duration = mmPlayer?.totalDuration {
            let currentTime = Double(sender.value) * duration
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    /// To pause the seek
    @IBAction internal func timeSliderTouchDown(_ sender: MMPlayerSlider) {
        isTimeSliding = true
        timer.invalidate()
    }
    /// To change seek time on tap
    @IBAction func timeSliderTouchUpInside(_ sender: MMPlayerSlider) {
        isTimeSliding = true
        if let duration = mmPlayer?.totalDuration {
            let currentTime = Double(sender.value) * duration
            mmPlayer?.seekTime(currentTime, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                if finished {
                    strongSelf.isTimeSliding = false
                    strongSelf.setupTimer()
                }
            })
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    
    /// To toggle play and pause mode
    @IBAction func onPlayerButton(_ sender: UIButton) {
        if !sender.isSelected {
            mmPlayer?.play()
        } else {
            mmPlayer?.pause()
        }
    }
    
    ///To toggle full screen mode manually
    @IBAction func onFullscreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isFullScreen = sender.isSelected
        if isFullScreen {
            enterFullscreen()
        } else {
            exitFullscreen()
        }
    }
    
    
    /// Single Tap Event to toggle control view visibility
    ///
    /// - Parameter gesture: Single Tap Gesture
    @objc open func onSingleTapGesture(_ gesture: UITapGestureRecognizer) {
        isDisplayControl = !isDisplayControl
        displayControlView(isDisplayControl)
    }
    
    /// Double Tap Event to toggle play and pause
    ///
    /// - Parameter gesture: Double Tap Gesture
    @objc open func onDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        guard mmPlayer == nil else {
            switch mmPlayer!.state {
            case .playFinished:
                break
            case .playing:
                mmPlayer?.pause()
            case .paused:
                mmPlayer?.play()
            case .none:
                break
            case .error:
                break
            }
            return
        }
    }
    
    /// Pan Event to manage the volume in right half vertically, manage brightness in left half vertically and manage seek time horizontally
    ///
    /// - Parameter gesture: Pan Gesture
    @objc open func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let location = gesture.location(in: self)
        let velocity = gesture.velocity(in: self)
        switch gesture.state {
        case .began:
            let x = abs(translation.x)
            let y = abs(translation.y)
            if x < y {
                panGestureDirection = .vertical
                if location.x > bounds.width / 2 {
                    isVolume = true
                } else {
                    isVolume = false
                }
            } else if x > y{
                guard mmPlayer?.mediaFormat == .m3u8 else {
                    panGestureDirection = .horizontal
                    return
                }
            }
        case .changed:
            switch panGestureDirection {
            case .horizontal:
                if mmPlayer?.currentDuration == 0 { break }
                sliderSeekTimeValue = panGestureHorizontal(velocity.x)
            case .vertical:
                panGestureVertical(velocity.y)
            }
        case .ended:
            switch panGestureDirection{
            case .horizontal:
                if sliderSeekTimeValue.isNaN { return }
                self.mmPlayer?.seekTime(sliderSeekTimeValue, completion: { [weak self] (finished) in
                    guard let strongSelf = self else { return }
                    if finished {
                        
                        strongSelf.isTimeSliding = false
                        strongSelf.setupTimer()
                    }
                })
            case .vertical:
                isVolume = false
            }
            
        default:
            break
        }
    }
    
    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        displayControlView(true)
        isTimeSliding = true
        timer.invalidate()
        let value = timeSlider.value
        if let _ = mmPlayer?.currentDuration ,let totalDuration = mmPlayer?.totalDuration {
            let sliderValue = (TimeInterval(value) *  totalDuration) + TimeInterval(velocityX) / 100.0 * (TimeInterval(totalDuration) / 400)
            timeSlider.setValue(Float(sliderValue/totalDuration), animated: true)
            return sliderValue
        } else {
            return TimeInterval.nan
        }
        
    }
    
    internal func panGestureVertical(_ velocityY: CGFloat) {
        isVolume ? (volumeSlider.value -= Float(velocityY / 10000)) : (UIScreen.main.brightness -= velocityY / 10000)
    }

    @IBAction func onCloseView(_ sender: UIButton) {
        if sender.isSelected {
            exitInAppPIPMode()
        } else {
            delegate?.mmPlayerView(didTappedClose: self)
        }
        
    }
    
    ///Button action to remove the video player view
    @IBAction func onDismissView(_ sender: UIButton) {
        guard (PIPManager.shared.video != nil) else {
            return
        }
        VideoDBM.shared.updateLastPlayedDuration(duration: sliderSeekTimeValue, for: PIPManager.shared.video!.id!)
        removeFromSuperview()
        PIPManager.shared.video = nil
        PIPManager.shared.player = nil
    }
    @IBAction func onReplay(_ sender: UIButton) {
        mmPlayer?.replaceVideo((mmPlayer?.contentURL)!)
        mmPlayer?.play()
    }
    
    @objc internal func deviceOrientationWillChange(_ sender: Notification) {
        let orientation = UIDevice.current.orientation
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait{
            if superview != nil {
                parentView = (superview)!
                viewFrame = frame
            }
        }
        switch orientation {
        case .unknown:
            break
        case .faceDown:
            break
        case .faceUp:
            break
        case .landscapeLeft:
            onDeviceOrientation(true, orientation: .landscapeLeft)
        case .landscapeRight:
            onDeviceOrientation(true, orientation: .landscapeRight)
        case .portrait:
            onDeviceOrientation(false, orientation: .portrait)
        case .portraitUpsideDown:
            onDeviceOrientation(false, orientation: .portraitUpsideDown)
        @unknown default:
            print("@unknown orientation")
        }
    }
    internal func onDeviceOrientation(_ fullScreen: Bool, orientation: UIInterfaceOrientation) {
        isFullScreen = fullScreen
        fullscreenButton.isSelected = fullScreen
        delegate?.mmPlayerView(self, willFullscreen: isFullScreen)
    }
}

//MARK: - Methods for InApp PIP mode management
 
extension MMPlayerView {
    /// This method is to remove the video view from details page and enter in PIP mode with animation, set constartints
    open func startInAppPIPMode() {
        guard let window = appDelegate.window else { return  }
        fullscreenButton.isHidden = true
        closeButton.isSelected = true
        dismissButton.isHidden = false
        timeSlider.isHidden = true
        let rectInWindow = convert(bounds, to: window)
        removeFromSuperview()
        frame = rectInWindow
        window.addSubview(self)
        let windowBounds = window.bounds
         trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: window, attribute: .trailing, multiplier: 1, constant: 0)
         bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: window, attribute: .bottom, multiplier: 1, constant: (rectInWindow.origin.y + rectInWindow.size.height) - windowBounds.size.height)
        window.addConstraint(trailing!)
        window.addConstraint(bottom!)
         width = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: rectInWindow.size.width)
        let ratio = NSLayoutConstraint(item: self,attribute: .height,relatedBy: .equal,toItem: self,attribute: .width,multiplier: 9/16,constant: 0)
        addConstraint(width!)
        addConstraint(ratio)
        layer.masksToBounds = true
        UIView.animate(withDuration: 0.03, animations: {
            self.bottom?.constant = -(window.safeAreaInsets.bottom)
            self.layer.cornerRadius = 15
            window.layoutIfNeeded()
        }) { (isFinished) in
            self.width?.constant = windowBounds.size.width / 2.5
            self.trailing?.constant = -5.0
        }
    }
    
    /// This method is to exit from PIP mode and call delegate method to add the player in details page.
    internal func exitInAppPIPMode() {
        guard let window = appDelegate.window else { return  }
        fullscreenButton.isHidden = false
        closeButton.isSelected = false
        dismissButton.isHidden = true
        timeSlider.isHidden = false
        
        let detailVC = CommonUtility.getVcObject(vcName: "DetailsViewController") as! DetailsViewController
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .fullScreen
        window.rootViewController!.present(nav, animated: true, completion: nil)
        self.delegate = detailVC
        
        let windowBounds = window.bounds
        UIView.animate(withDuration: 0.03, animations: {
            self.bottom?.constant = (window.safeAreaInsets.top + windowBounds.size.width * 0.5625) - windowBounds.size.height
            self.width?.constant = windowBounds.size.width
            self.trailing?.constant = 0.0
            self.layer.cornerRadius = 0
            window.layoutIfNeeded()
        }) { (isFinished) in
            self.layer.masksToBounds = false
            self.removeFromSuperview()
            self.delegate?.mmPlayerView(didExitPIPMode: self)
        }
    }
}
