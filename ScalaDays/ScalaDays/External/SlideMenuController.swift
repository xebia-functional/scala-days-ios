//
//  SlideMenuController.swift
//
//  Created by Yuji Hato on 12/3/14.
//

import Foundation
import UIKit

struct SlideMenuOptions {
    static var leftViewWidth: CGFloat = 270.0
    static var leftBezelWidth: CGFloat = 16.0
    static var contentViewScale: CGFloat = 0.96
    static var contentViewOpacity: CGFloat = 0.5
    static var shadowOpacity: CGFloat = 0.0
    static var shadowRadius: CGFloat = 0.0
    static var shadowOffset: CGSize = CGSize(width: 0,height: 0)
    static var panFromBezel: Bool = true
    static var animationDuration: CGFloat = 0.4
    static var rightViewWidth: CGFloat = 270.0
    static var rightBezelWidth: CGFloat = 16.0
    static var rightPanFromBezel: Bool = true
    static var hideStatusBar: Bool = true
    static var pointOfNoReturnWidth: CGFloat = 44.0
}

@objc protocol SlideMenuControllerDelegate {
    @objc optional func willBeHiddenFromMenu()
}

class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {

    enum SlideAction {
        case open
        case close
    }
    
    enum TrackAction {
        case tapOpen
        case tapClose
        case flickOpen
        case flickClose
    }
    
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    var opacityView = UIView()
    var mainContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView =  UIView()
    var mainViewController: UIViewController?
    var leftViewController: UIViewController?
    var leftPanGesture: UIPanGestureRecognizer?
    var leftTapGetsture: UITapGestureRecognizer?
    var rightViewController: UIViewController?
    var rightPanGesture: UIPanGestureRecognizer?
    var rightTapGesture: UITapGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        initView()
    }
    
    convenience init(mainViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        rightViewController = rightMenuViewController
        initView()
    }
    
    convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        rightViewController = rightMenuViewController
        initView()
    }
    
    deinit { }
    
    func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clear
        mainContainerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        view.insertSubview(mainContainerView, at: 0)

        var opacityframe: CGRect = view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = UIColor.black
        opacityView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, at: 1)
        
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = SlideMenuOptions.leftViewWidth
        leftFrame.origin.x = leftMinOrigin();
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = UIView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clear
        leftContainerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        view.insertSubview(leftContainerView, at: 2)
        
        var rightFrame: CGRect = view.bounds
        rightFrame.size.width = SlideMenuOptions.rightViewWidth
        rightFrame.origin.x = rightMinOrigin()
        let rightOffset: CGFloat = 0
        rightFrame.origin.y = rightFrame.origin.y + rightOffset;
        rightFrame.size.height = rightFrame.size.height - rightOffset
        rightContainerView = UIView(frame: rightFrame)
        rightContainerView.backgroundColor = UIColor.clear
        rightContainerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        view.insertSubview(rightContainerView, at: 3)
        
        addLeftGestures()
        addRightGestures()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        leftContainerView.isHidden = true
        rightContainerView.isHidden = true
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        
        closeLeftNonAnimation()
        closeRightNonAnimation()
        leftContainerView.isHidden = false
        rightContainerView.isHidden = false

        removeLeftGestures()
        removeRightGestures()
        addLeftGestures()
        addRightGestures()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewWillLayoutSubviews() {
        // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        setUpViewController(rightContainerView, targetViewController: rightViewController)
    }
    
    override func openLeft() {
        setOpenWindowLevel()
        
        //leftViewControllerのviewWillAppearを呼ぶため
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        openLeftWithVelocity(0.0)
        
        track(.tapOpen)
    }
    
    override func openRight() {
        setOpenWindowLevel()
        
        //menuViewControllerのviewWillAppearを呼ぶため
        rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
        openRightWithVelocity(0.0)
    }
    
    override func closeLeft() {
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLebel()
    }
    
    override func closeRight() {
        rightViewController?.beginAppearanceTransition(isRightHidden(), animated: true)
        closeRightWithVelocity(0.0)
        setCloseWindowLebel()
    }
    
    
    func addLeftGestures() {
    
        if (leftViewController != nil) {
            if leftPanGesture == nil {
                leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideMenuController.handleLeftPanGesture(_:)))
                leftPanGesture!.delegate = self
                view.addGestureRecognizer(leftPanGesture!)
            }
            
            if leftTapGetsture == nil {
                leftTapGetsture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.toggleLeft))
                leftTapGetsture!.delegate = self
                view.addGestureRecognizer(leftTapGetsture!)
            }
        }
    }
    
    func addRightGestures() {
        
        if (rightViewController != nil) {
            if rightPanGesture == nil {
                rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideMenuController.handleRightPanGesture(_:)))
                rightPanGesture!.delegate = self
                view.addGestureRecognizer(rightPanGesture!)
            }
            
            if rightTapGesture == nil {
                rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.toggleRight))
                rightTapGesture!.delegate = self
                view.addGestureRecognizer(rightTapGesture!)
            }
        }
    }
    
    func removeLeftGestures() {
        
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
        
        if leftTapGetsture != nil {
            view.removeGestureRecognizer(leftTapGetsture!)
            leftTapGetsture = nil
        }
    }
    
    func removeRightGestures() {
        
        if rightPanGesture != nil {
            view.removeGestureRecognizer(rightPanGesture!)
            rightPanGesture = nil
        }
        
        if rightTapGesture != nil {
            view.removeGestureRecognizer(rightTapGesture!)
            rightTapGesture = nil
        }
    }
    
    func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    func track(_ trackAction: TrackAction) {
        // function is for tracking
        // Please to override it if necessary
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    @objc func handleLeftPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        if isRightOpen() {
            return
        }
        
        switch panGesture.state {
            case UIGestureRecognizerState.began:
                
                LeftPanState.frameAtStartOfPan = leftContainerView.frame
                LeftPanState.startPointOfPan = panGesture.location(in: view)
                LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
                LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
                
                leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
                addShadowToView(leftContainerView)
                setOpenWindowLevel()
            case UIGestureRecognizerState.changed:
                
                let translation: CGPoint = panGesture.translation(in: panGesture.view!)
                leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
                applyLeftOpacity()
                applyLeftContentViewScale()
            case UIGestureRecognizerState.ended:
                
                let velocity:CGPoint = panGesture.velocity(in: panGesture.view)
                let panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
                
                if panInfo.action == .open {
                    if !LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(true, animated: true)
                    }
                    openLeftWithVelocity(panInfo.velocity)
                    track(.flickOpen)
                    
                } else {
                    if LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(false, animated: true)
                    }
                    closeLeftWithVelocity(panInfo.velocity)
                    setCloseWindowLebel()
                    
                    track(.flickClose)

                }
        default:
            break
        }
        
    }
    
    struct RightPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    @objc func handleRightPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        if isLeftOpen() {
            return
        }
        
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            
            RightPanState.frameAtStartOfPan = rightContainerView.frame
            RightPanState.startPointOfPan = panGesture.location(in: view)
            RightPanState.wasOpenAtStartOfPan =  isRightOpen()
            RightPanState.wasHiddenAtStartOfPan = isRightHidden()
            
            rightViewController?.beginAppearanceTransition(RightPanState.wasHiddenAtStartOfPan, animated: true)
            addShadowToView(rightContainerView)
            setOpenWindowLevel()
        case UIGestureRecognizerState.changed:
            
            let translation: CGPoint = panGesture.translation(in: panGesture.view!)
            rightContainerView.frame = applyRightTranslation(translation, toFrame: RightPanState.frameAtStartOfPan)
            applyRightOpacity()
            applyRightContentViewScale()
            
        case UIGestureRecognizerState.ended:
            
            let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
            let panInfo: PanInfo = panRightResultInfoForVelocity(velocity)
            
            if panInfo.action == .open {
                if !RightPanState.wasHiddenAtStartOfPan {
                    rightViewController?.beginAppearanceTransition(true, animated: true)
                }
                openRightWithVelocity(panInfo.velocity)
            } else {
                if RightPanState.wasHiddenAtStartOfPan {
                    rightViewController?.beginAppearanceTransition(false, animated: true)
                }
                closeRightWithVelocity(panInfo.velocity)
                setCloseWindowLebel()
            }
        default:
            break
        }
    }
    
    func openLeftWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame;
        frame.origin.x = finalXOrigin;
        
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        addShadowToView(leftContainerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: SlideMenuOptions.contentViewScale, y: SlideMenuOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }
    
    func openRightWithVelocity(_ velocity: CGFloat) {
        let xOrigin: CGFloat = rightContainerView.frame.origin.x
    
        //	CGFloat finalXOrigin = SlideMenuOptions.rightViewOverlapWidth;
        let finalXOrigin: CGFloat = view.bounds.width - rightContainerView.frame.size.width
        
        var frame = rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - view.bounds.width) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
    
        addShadowToView(rightContainerView)
    
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.rightContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: SlideMenuOptions.contentViewScale, y: SlideMenuOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.rightViewController?.endAppearanceTransition()
                }
        }
    }
    
    func closeLeftWithVelocity(_ velocity: CGFloat) {
        
        let xOrigin: CGFloat = leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.removeShadow(strongSelf.leftContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }
    
    
    func closeRightWithVelocity(_ velocity: CGFloat) {
    
        let xOrigin: CGFloat = rightContainerView.frame.origin.x
        let finalXOrigin: CGFloat = view.bounds.width
    
        var frame: CGRect = rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - view.bounds.width) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
    
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.rightContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.removeShadow(strongSelf.rightContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.rightViewController?.endAppearanceTransition()
                }
        }
    }
    
    
    override func toggleLeft() {
        if isLeftOpen() {
            closeLeft()
            setCloseWindowLebel()
            // closeMenuはメニュータップ時にも呼ばれるため、closeタップのトラッキングはここに入れる
            
            track(.tapClose)
        } else {
            openLeft()
        }
    }
    
    func isLeftOpen() -> Bool {
        return leftContainerView.frame.origin.x == 0.0
    }
    
    func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    override func toggleRight() {
        if isRightOpen() {
            closeRight()
            setCloseWindowLebel()
        } else {
            openRight()
        }
    }
    
    func isRightOpen() -> Bool {
        return rightContainerView.frame.origin.x == view.bounds.width - rightContainerView.frame.size.width
    }
    
    func isRightHidden() -> Bool {
        return rightContainerView.frame.origin.x >= view.bounds.width
    }
    
    func changeMainViewController(_ mainViewController: UIViewController,  close: Bool) {
        // Let know the current mainViewController that it's going to be swapped out:
        if let _vc = (self.mainViewController as? UINavigationController)?.topViewController
            as? SlideMenuControllerDelegate {
                _vc.willBeHiddenFromMenu?()
        }
        
        
        removeViewController(mainViewController)
        self.mainViewController = mainViewController
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        if (close) {
            closeLeft()
            closeRight()
        }
    }
    
    func changeLeftViewController(_ leftViewController: UIViewController, closeLeft:Bool) {
        
        removeViewController(leftViewController)
        self.leftViewController = leftViewController
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        if closeLeft {
            self.closeLeft()
        }
    }
    
    func changeRightViewController(_ rightViewController: UIViewController, closeRight:Bool) {
        removeViewController(rightViewController)
        self.rightViewController = rightViewController;
        setUpViewController(rightContainerView, targetViewController: rightViewController)
        if closeRight {
            self.closeRight()
        }
    }
    
    fileprivate func leftMinOrigin() -> CGFloat {
        return  -SlideMenuOptions.leftViewWidth
    }
    
    fileprivate func rightMinOrigin() -> CGFloat {
        return view.bounds.width
    }
    
    
    fileprivate func panLeftResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + SlideMenuOptions.pointOfNoReturnWidth
        let leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .close : .open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func panRightResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = -1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(view.bounds.width) - SlideMenuOptions.pointOfNoReturnWidth)
        let rightOrigin: CGFloat = rightContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = rightOrigin >= pointOfNoReturn ? .close : .open
        
        if velocity.x <= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if (velocity.x >= (-1.0 * thresholdVelocity)) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func applyLeftTranslation(_ translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func applyRightTranslation(_ translation: CGPoint, toFrame: CGRect) -> CGRect {
        
        var  newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = rightMinOrigin()
        //        var maxOrigin: CGFloat = SlideMenuOptions.rightViewOverlapWidth
        let maxOrigin: CGFloat = rightMinOrigin() - rightContainerView.frame.size.width
        var newFrame: CGRect = toFrame
        
        if newOrigin > minOrigin {
            newOrigin = minOrigin
        } else if newOrigin < maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func getOpenedLeftRatio() -> CGFloat {
        
        let width: CGFloat = leftContainerView.frame.size.width
        let currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    fileprivate func getOpenedRightRatio() -> CGFloat {
        
        let width: CGFloat = rightContainerView.frame.size.width
        let currentPosition: CGFloat = rightContainerView.frame.origin.x
        return -(currentPosition - view.bounds.width) / width
    }
    
    fileprivate func applyLeftOpacity() {
        
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedLeftRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    
    fileprivate func applyRightOpacity() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedRightRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    fileprivate func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedLeftRatio);
        mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    fileprivate func applyRightContentViewScale() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedRightRatio)
        mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    fileprivate func addShadowToView(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = SlideMenuOptions.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(SlideMenuOptions.shadowOpacity)
        targetContainerView.layer.shadowRadius = SlideMenuOptions.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).cgPath
    }
    
    fileprivate func removeShadow(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        mainContainerView.layer.opacity = 1.0
    }
    
    fileprivate func removeContentOpacity() {
        opacityView.layer.opacity = 0.0
    }
    

    fileprivate func addContentOpacity() {
        opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
    }
    
    fileprivate func disableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = false
    }
    
    fileprivate func enableContentInteraction() {
        mainContainerView.isUserInteractionEnabled = true
    }
    
    fileprivate func setOpenWindowLevel() {
        if (SlideMenuOptions.hideStatusBar) {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    fileprivate func setCloseWindowLebel() {
        if (SlideMenuOptions.hideStatusBar) {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    fileprivate func setUpViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            viewController.view.frame = targetView.bounds
            targetView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
    
    
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMove(toParentViewController: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    func closeLeftNonAnimation(){
        setCloseWindowLebel()
        let finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(leftContainerView)
        enableContentInteraction()
    }
    
    func closeRightNonAnimation(){
        setCloseWindowLebel()
        let finalXOrigin: CGFloat = view.bounds.width
        var frame: CGRect = rightContainerView.frame
        frame.origin.x = finalXOrigin
        rightContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        removeShadow(rightContainerView)
        enableContentInteraction()
    }
    
    //pragma mark – UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
        let point: CGPoint = touch.location(in: view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == rightPanGesture {
            return slideRightViewForGestureRecognizer(gestureRecognizer, withTouchPoint: point)
        } else if gestureRecognizer == leftTapGetsture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        } else if gestureRecognizer == rightTapGesture {
            return isRightOpen() && !isPointContainedWithinRightRect(point)
        }
        
        return true
    }
    
    fileprivate func slideLeftForGestureRecognizer( _ gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || SlideMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isLeftPointContainedWithinBezelRect(_ point: CGPoint) -> Bool{
        var leftBezelRect: CGRect = CGRect.zero
        var tempRect: CGRect = CGRect.zero
        let bezelWidth: CGFloat = SlideMenuOptions.leftBezelWidth
        
       (leftBezelRect, tempRect) = view.bounds.divided(atDistance: bezelWidth, from: .minXEdge)
        
        return leftBezelRect.contains(point)
    }
    
    fileprivate func isPointContainedWithinLeftRect(_ point: CGPoint) -> Bool {
        return leftContainerView.frame.contains(point)
    }
    
    
    
    fileprivate func slideRightViewForGestureRecognizer(_ gesture: UIGestureRecognizer, withTouchPoint point: CGPoint) -> Bool {
        return isRightOpen() || SlideMenuOptions.rightPanFromBezel && isRightPointContainedWithinBezelRect(point)
    }
    
    fileprivate func isRightPointContainedWithinBezelRect(_ point: CGPoint) -> Bool {
        var rightBezelRect: CGRect = CGRect.zero
        var tempRect: CGRect = CGRect.zero
        let bezelWidth: CGFloat = view.bounds.width - SlideMenuOptions.rightBezelWidth
        
        (rightBezelRect, tempRect) = view.bounds.divided(atDistance: bezelWidth, from: .minXEdge)
        return rightBezelRect.contains(point)
    }
    
    fileprivate func isPointContainedWithinRightRect(_ point: CGPoint) -> Bool {
        return rightContainerView.frame.contains(point)
    }
    
}


extension UIViewController {

    func slideMenuController() -> SlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideMenuController {
                return viewController as? SlideMenuController
            }
            viewController = viewController?.parent
        }
        return nil;
    }
    
    func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UIViewController.toggleLeft))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func addRightBarButtonWithImage(_ buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.bordered, target: self, action: #selector(UIViewController.toggleRight))
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    @objc func toggleLeft() {
        slideMenuController()?.toggleLeft()
    }

    @objc func toggleRight() {
        slideMenuController()?.toggleRight()
    }
    
    @objc func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    @objc func openRight() {
        slideMenuController()?.openRight()    }
    
    @objc func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    @objc func closeRight() {
        slideMenuController()?.closeRight()
    }
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    func addPriorityToMenuGesuture(_ targetScrollView: UIScrollView) {
        if let slideControlelr = slideMenuController() {
            let recognizers =  slideControlelr.view.gestureRecognizers
            for recognizer in recognizers! as [UIGestureRecognizer] {
                if recognizer is UIPanGestureRecognizer {
                    targetScrollView.panGestureRecognizer.require(toFail: recognizer)
                }
            }
        }
    }
}
