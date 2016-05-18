//
//  SCLAlertView.swift
//  SCLAlertView Example
//
//  Created by Viktor Radchenko on 6/5/14.
//  Copyright (c) 2014 Viktor Radchenko. All rights reserved.
//

import Foundation
import UIKit

// Pop Up Styles
public enum SCLAlertViewStyle {
    case Success, Error, Notice, Warning, Info, Edit, Wait
    
    var defaultColorInt: UInt {
        switch self {
        case Success:
            return 0x22B573
        case Error:
            return 0xC1272D
        case Notice:
            return 0x727375
        case Warning:
            return 0xFFD110
        case Info:
            return 0x2866BF
        case Edit:
            return 0xA429FF
        case Wait:
            return 0xD62DA5
        }
        
    }

}

// Action Types
public enum SCLActionType {
    case None, Selector, Closure
}

// Button sub-class
public class SCLButton: UIButton {
    var actionType = SCLActionType.None
    var target:AnyObject!
    var selector:Selector!
    var action:(()->Void)!
    var customBackgroundColor:UIColor?
    var customTextColor:UIColor?
    var initialTitle:String!
    var showDurationStatus:Bool=false
    
    public init() {
        super.init(frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame:CGRect) {
        super.init(frame:frame)
    }
}

// Allow alerts to be closed/renamed in a chainable manner
// Example: SCLAlertView().showSuccess(self, title: "Test", subTitle: "Value").close()
public class SCLAlertViewResponder {
    let alertview: SCLAlertView
    
    // Initialisation and Title/Subtitle/Close functions
    public init(alertview: SCLAlertView) {
        self.alertview = alertview
    }
    
    public func setTitle(title: String) {
        self.alertview.labelTitle.text = title
    }
    
    public func setSubTitle(subTitle: String) {
        self.alertview.viewText.text = subTitle
    }
    
    public func close() {
        self.alertview.hideView()
    }
    
    public func setDismissBlock(dismissBlock: DismissBlock) {
        self.alertview.dismissBlock = dismissBlock
    }
}

let kCircleHeightBackground: CGFloat = 62.0

public typealias DismissBlock = () -> Void

// The Main Class
public class SCLAlertView: UIViewController {
    
    public struct SCLAppearance {
        let kDefaultShadowOpacity: CGFloat
        let kCircleTopPosition: CGFloat
        let kCircleBackgroundTopPosition: CGFloat
        let kCircleHeight: CGFloat
        let kCircleIconHeight: CGFloat
        let kTitleTop:CGFloat
        let kTitleHeight:CGFloat
        let kWindowWidth: CGFloat
        var kWindowHeight: CGFloat
        var kTextHeight: CGFloat
        let kTextFieldHeight: CGFloat
        let kTextViewdHeight: CGFloat
        let kButtonHeight: CGFloat
        let contentViewColor: UIColor
        let contentViewBorderColor: UIColor
        let titleColor: UIColor
        
        // Fonts
        let kTitleFont: UIFont
        let kTextFont: UIFont
        let kButtonFont: UIFont
        
        // UI Options
        var showCloseButton: Bool
        var showCircularIcon: Bool
        var shouldAutoDismiss: Bool // Set this false to 'Disable' Auto hideView when SCLButton is tapped
        var contentViewCornerRadius : CGFloat
        var fieldCornerRadius : CGFloat
        var buttonCornerRadius : CGFloat
        
        // Actions
        var hideWhenBackgroundViewIsTapped: Bool
        
        public init(kDefaultShadowOpacity: CGFloat = 0.7, kCircleTopPosition: CGFloat = -12.0, kCircleBackgroundTopPosition: CGFloat = -15.0, kCircleHeight: CGFloat = 56.0, kCircleIconHeight: CGFloat = 20.0, kTitleTop:CGFloat = 30.0, kTitleHeight:CGFloat = 25.0, kWindowWidth: CGFloat = 240.0, kWindowHeight: CGFloat = 178.0, kTextHeight: CGFloat = 90.0, kTextFieldHeight: CGFloat = 45.0, kTextViewdHeight: CGFloat = 80.0, kButtonHeight: CGFloat = 45.0, kTitleFont: UIFont = UIFont.systemFontOfSize(20), kTextFont: UIFont = UIFont.systemFontOfSize(14), kButtonFont: UIFont = UIFont.boldSystemFontOfSize(14), showCloseButton: Bool = true, showCircularIcon: Bool = true, shouldAutoDismiss: Bool = true, contentViewCornerRadius: CGFloat = 5.0, fieldCornerRadius: CGFloat = 3.0, buttonCornerRadius: CGFloat = 3.0, hideWhenBackgroundViewIsTapped: Bool = false, contentViewColor: UIColor = UIColorFromRGB(0xFFFFFF), contentViewBorderColor: UIColor = UIColorFromRGB(0xCCCCCC), titleColor: UIColor = UIColorFromRGB(0x4D4D4D)) {
            
            self.kDefaultShadowOpacity = kDefaultShadowOpacity
            self.kCircleTopPosition = kCircleTopPosition
            self.kCircleBackgroundTopPosition = kCircleBackgroundTopPosition
            self.kCircleHeight = kCircleHeight
            self.kCircleIconHeight = kCircleIconHeight
            self.kTitleTop = kTitleTop
            self.kTitleHeight = kTitleHeight
            self.kWindowWidth = kWindowWidth
            self.kWindowHeight = kWindowHeight
            self.kTextHeight = kTextHeight
            self.kTextFieldHeight = kTextFieldHeight
            self.kTextViewdHeight = kTextViewdHeight
            self.kButtonHeight = kButtonHeight
            self.contentViewColor = contentViewColor
            self.contentViewBorderColor = contentViewBorderColor
            self.titleColor = titleColor
            
            self.kTitleFont = kTitleFont
            self.kTextFont = kTextFont
            self.kButtonFont = kButtonFont
            
            self.showCloseButton = showCloseButton
            self.showCircularIcon = showCircularIcon
            self.shouldAutoDismiss = shouldAutoDismiss
            self.contentViewCornerRadius = contentViewCornerRadius
            self.fieldCornerRadius = fieldCornerRadius
            self.buttonCornerRadius = buttonCornerRadius
            
            self.hideWhenBackgroundViewIsTapped = hideWhenBackgroundViewIsTapped
        }
        
        mutating func setkWindowHeight(kWindowHeight:CGFloat) {
            self.kWindowHeight = kWindowHeight
        }
        
        mutating func setkTextHeight(kTextHeight:CGFloat) {
            self.kTextHeight = kTextHeight
        }
    }
    
    var appearance: SCLAppearance!
    
    // UI Colour
    var viewColor = UIColor()
    
    // UI Options
    public var iconTintColor: UIColor?
    public var customSubview : UIView?
    

    
    // Members declaration
    var baseView = UIView()
    var labelTitle = UILabel()
    var viewText = UITextView()
    var contentView = UIView()
    var circleBG = UIView(frame:CGRect(x:0, y:0, width:kCircleHeightBackground, height:kCircleHeightBackground))
    var circleView = UIView()
    var circleIconView : UIView?
    var duration: NSTimeInterval!
    var durationStatusTimer: NSTimer!
    var durationTimer: NSTimer!
    var dismissBlock : DismissBlock?
    private var inputs = [UITextField]()
    private var input = [UITextView]()
    internal var buttons = [SCLButton]()
    private var selfReference: SCLAlertView?
    
    public init(appearance: SCLAppearance) {
        self.appearance = appearance
        super.init(nibName:nil, bundle:nil)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required public init() {
        appearance = SCLAppearance()
        super.init(nibName:nil, bundle:nil)
        setup()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        appearance = SCLAppearance()
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    private func setup() {
        // Set up main view
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:appearance.kDefaultShadowOpacity)
        view.addSubview(baseView)
        // Base View
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        // Content View
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        // Circle View
        circleBG.backgroundColor = UIColor.whiteColor()
        circleBG.layer.cornerRadius = circleBG.frame.size.height / 2
        baseView.addSubview(circleBG)
        circleBG.addSubview(circleView)
        let x = (kCircleHeightBackground - appearance.kCircleHeight) / 2
        circleView.frame = CGRect(x:x, y:x, width:appearance.kCircleHeight, height:appearance.kCircleHeight)
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        // Title
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .Center
        labelTitle.font = appearance.kTitleFont
        labelTitle.frame = CGRect(x:12, y:appearance.kTitleTop, width: appearance.kWindowWidth - 24, height:appearance.kTitleHeight)
        // View text
        viewText.editable = false
        viewText.textAlignment = .Center
        viewText.textContainerInset = UIEdgeInsetsZero
        viewText.textContainer.lineFragmentPadding = 0;
        viewText.font = appearance.kTextFont
        // Colours
        contentView.backgroundColor = appearance.contentViewColor
        viewText.backgroundColor = appearance.contentViewColor
        labelTitle.textColor = appearance.titleColor
        viewText.textColor = appearance.titleColor
        contentView.layer.borderColor = appearance.contentViewBorderColor.CGColor
        //Gesture Recognizer for tapping outside the textinput
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SCLAlertView.tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        let sz = rv.frame.size
        
        // Set background frame
        view.frame.size = sz
        
        // computing the right size to use for the textView
        let maxHeight = sz.height - 100 // max overall height
        var consumedHeight = CGFloat(0)
        consumedHeight += appearance.kTitleTop + appearance.kTitleHeight
        consumedHeight += 14
        consumedHeight += appearance.kButtonHeight * CGFloat(buttons.count)
        consumedHeight += appearance.kTextFieldHeight * CGFloat(inputs.count)
        consumedHeight += appearance.kTextViewdHeight * CGFloat(input.count)
        let maxViewTextHeight = maxHeight - consumedHeight
        let viewTextWidth = appearance.kWindowWidth - 24
        var viewTextHeight = appearance.kTextHeight
        
        // Check if there is a custom subview and add it over the textview
        if let customSubview = customSubview {
            viewTextHeight = min(customSubview.frame.height, maxViewTextHeight)
            viewText.text = ""
            viewText.addSubview(customSubview)
        } else {
            // computing the right size to use for the textView
            let suggestedViewTextSize = viewText.sizeThatFits(CGSizeMake(viewTextWidth, CGFloat.max))
            viewTextHeight = min(suggestedViewTextSize.height, maxViewTextHeight)
            
            // scroll management
            if (suggestedViewTextSize.height > maxViewTextHeight) {
                viewText.scrollEnabled = true
            } else {
                viewText.scrollEnabled = false
            }
        }
        
        let windowHeight = consumedHeight + viewTextHeight
        // Set frames
        var x = (sz.width - appearance.kWindowWidth) / 2
        var y = (sz.height - windowHeight - (appearance.kCircleHeight / 8)) / 2
        contentView.frame = CGRect(x:x, y:y, width:appearance.kWindowWidth, height:windowHeight)
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        y -= kCircleHeightBackground * 0.6
        x = (sz.width - kCircleHeightBackground) / 2
        circleBG.frame = CGRect(x:x, y:y+6, width:kCircleHeightBackground, height:kCircleHeightBackground)
        
        //adjust Title frame based on circularIcon show/hide flag
        let titleOffset : CGFloat = appearance.showCircularIcon ? 0.0 : -12.0
        labelTitle.frame = labelTitle.frame.offsetBy(dx: 0, dy: titleOffset)
        
        // Subtitle
        y = appearance.kTitleTop + appearance.kTitleHeight + titleOffset
        viewText.frame = CGRect(x:12, y:y, width: appearance.kWindowWidth - 24, height:appearance.kTextHeight)
        viewText.frame = CGRect(x:12, y:y, width: viewTextWidth, height:viewTextHeight)
        // Text fields
        y += viewTextHeight + 14.0
        for txt in inputs {
            txt.frame = CGRect(x:12, y:y, width:appearance.kWindowWidth - 24, height:30)
            txt.layer.cornerRadius = appearance.fieldCornerRadius
            y += appearance.kTextFieldHeight
        }
        for txt in input {
            txt.frame = CGRect(x:12, y:y, width:appearance.kWindowWidth - 24, height:70)
            //txt.layer.cornerRadius = fieldCornerRadius
            y += appearance.kTextViewdHeight
        }
        // Buttons
        for btn in buttons {
            btn.frame = CGRect(x:12, y:y, width:appearance.kWindowWidth - 24, height:35)
            btn.layer.cornerRadius = appearance.buttonCornerRadius
            y += appearance.kButtonHeight
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCLAlertView.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCLAlertView.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
    
    override public func touchesEnded(touches:Set<UITouch>, withEvent event:UIEvent?) {
        if event?.touchesForView(view)?.count > 0 {
            view.endEditing(true)
        }
    }
    
    public func addTextField(title:String?=nil, accessibilityIdentifier:String?=nil)->UITextField {
        // Update view height
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kTextFieldHeight)
        // Add text field
        let txt = UITextField()
        txt.borderStyle = UITextBorderStyle.RoundedRect
        txt.font = appearance.kTextFont
        txt.autocapitalizationType = UITextAutocapitalizationType.Words
        txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        if title != nil {
            txt.placeholder = title!
        }
        txt.accessibilityIdentifier = accessibilityIdentifier
        contentView.addSubview(txt)
        inputs.append(txt)
        return txt
    }
    
    public func addTextView(accessibilityIdentifier accessibilityIdentifier:String?=nil)->UITextView {
        // Update view height
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kTextViewdHeight)
        // Add text view
        let txt = UITextView()
        // No placeholder with UITextView but you can use KMPlaceholderTextView library 
        txt.font = appearance.kTextFont
        //txt.autocapitalizationType = UITextAutocapitalizationType.Words
        //txt.clearButtonMode = UITextFieldViewMode.WhileEditing
        txt.layer.masksToBounds = true
        txt.layer.borderWidth = 1.0
        txt.accessibilityIdentifier = accessibilityIdentifier
        contentView.addSubview(txt)
        input.append(txt)
        return txt
    }
    
    public func addButton(title:String, backgroundColor:UIColor? = nil, textColor:UIColor? = nil, showDurationStatus:Bool=false, accessibilityIdentifier:String?=nil, action:()->Void)->SCLButton {
        let btn = addButton(title, backgroundColor: backgroundColor, textColor: textColor, showDurationStatus: showDurationStatus, accessibilityIdentifier: accessibilityIdentifier)
        btn.actionType = SCLActionType.Closure
        btn.action = action
        btn.addTarget(self, action:#selector(SCLAlertView.buttonTapped(_:)), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:#selector(SCLAlertView.buttonTapDown(_:)), forControlEvents:[.TouchDown, .TouchDragEnter])
        btn.addTarget(self, action:#selector(SCLAlertView.buttonRelease(_:)), forControlEvents:[.TouchUpInside, .TouchUpOutside, .TouchCancel, .TouchDragOutside] )
        return btn
    }
    
    public func addButton(title:String, backgroundColor:UIColor? = nil, textColor:UIColor? = nil, showDurationStatus:Bool = false, accessibilityIdentifier: String?=nil, target:AnyObject, selector:Selector)->SCLButton {
        let btn = addButton(title, backgroundColor: backgroundColor, textColor: textColor, showDurationStatus: showDurationStatus, accessibilityIdentifier: accessibilityIdentifier)
        btn.actionType = SCLActionType.Selector
        btn.target = target
        btn.selector = selector
        btn.addTarget(self, action:#selector(SCLAlertView.buttonTapped(_:)), forControlEvents:.TouchUpInside)
        btn.addTarget(self, action:#selector(SCLAlertView.buttonTapDown(_:)), forControlEvents:[.TouchDown, .TouchDragEnter])
        btn.addTarget(self, action:#selector(SCLAlertView.buttonRelease(_:)), forControlEvents:[.TouchUpInside, .TouchUpOutside, .TouchCancel, .TouchDragOutside] )
        return btn
    }
    
    private func addButton(title:String, backgroundColor:UIColor? = nil, textColor:UIColor? = nil, showDurationStatus:Bool = false, accessibilityIdentifier: String?=nil)->SCLButton {
        // Update view height
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kButtonHeight)
        // Add button
        let btn = SCLButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, forState: .Normal)
        btn.titleLabel?.font = appearance.kButtonFont
        btn.accessibilityIdentifier = accessibilityIdentifier
        btn.customBackgroundColor = backgroundColor
        btn.customTextColor = textColor
        btn.initialTitle = title
        btn.showDurationStatus = showDurationStatus
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    
    func buttonTapped(btn:SCLButton) {
        if btn.actionType == SCLActionType.Closure {
            btn.action()
        } else if btn.actionType == SCLActionType.Selector {
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to:btn.target, forEvent:nil)
        } else {
            print("Unknow action type for button")
        }
        
        if(self.view.alpha != 0.0 && appearance.shouldAutoDismiss){ hideView() }
    }
    
    
    func buttonTapDown(btn:SCLButton) {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        var pressBrightnessFactor = 0.85
        btn.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        brightness = brightness * CGFloat(pressBrightnessFactor)
        btn.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func buttonRelease(btn:SCLButton) {
        btn.backgroundColor = btn.customBackgroundColor
    }
    
    var tmpContentViewFrameOrigin: CGPoint?
    var tmpCircleViewFrameOrigin: CGPoint?
    var keyboardHasBeenShown:Bool = false
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardHasBeenShown = true
        
        guard let userInfo = notification.userInfo else {return}
        guard let endKeyBoardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.minY else {return}
        
        if tmpContentViewFrameOrigin == nil {
        tmpContentViewFrameOrigin = self.contentView.frame.origin
        }
        
        if tmpCircleViewFrameOrigin == nil {
        tmpCircleViewFrameOrigin = self.circleBG.frame.origin
        }
        
        var newContentViewFrameY = self.contentView.frame.maxY - endKeyBoardFrame
        if newContentViewFrameY < 0 {
            newContentViewFrameY = 0
        }
        let newBallViewFrameY = self.circleBG.frame.origin.y - newContentViewFrameY
        self.contentView.frame.origin.y -= newContentViewFrameY
        self.circleBG.frame.origin.y = newBallViewFrameY
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(keyboardHasBeenShown){//This could happen on the simulator (keyboard will be hidden)
            if(self.tmpContentViewFrameOrigin != nil){
                self.contentView.frame.origin.y = self.tmpContentViewFrameOrigin!.y
                self.tmpContentViewFrameOrigin = nil
            }
            if(self.tmpCircleViewFrameOrigin != nil){
                self.circleBG.frame.origin.y = self.tmpCircleViewFrameOrigin!.y
                self.tmpCircleViewFrameOrigin = nil
            }
            
            keyboardHasBeenShown = false
        }
    }
    
    //Dismiss keyboard when tapped outside textfield & close SCLAlertView when hideWhenBackgroundViewIsTapped
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        
        if let tappedView = gestureRecognizer.view where tappedView.hitTest(gestureRecognizer.locationInView(tappedView), withEvent: nil) == baseView && appearance.hideWhenBackgroundViewIsTapped {
            
            hideView()
        }
    }
    
    // showSuccess(view, title, subTitle)
    public func showSuccess(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Success.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Success, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showError(view, title, subTitle)
    public func showError(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Error.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Error, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showNotice(view, title, subTitle)
    public func showNotice(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Notice.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Notice, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showWarning(view, title, subTitle)
    public func showWarning(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Warning.defaultColorInt, colorTextButton: UInt=0x000000, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Warning, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showInfo(view, title, subTitle)
    public func showInfo(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Info.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Info, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showWait(view, title, subTitle)
    public func showWait(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt?=SCLAlertViewStyle.Wait.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Wait, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    public func showEdit(title: String, subTitle: String, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt=SCLAlertViewStyle.Edit.defaultColorInt, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration: duration, completeText:closeButtonTitle, style: .Edit, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showTitle(view, title, subTitle, style)
    public func showTitle(title: String, subTitle: String, style: SCLAlertViewStyle, closeButtonTitle:String?=nil, duration:NSTimeInterval=0.0, colorStyle: UInt?=0x000000, colorTextButton: UInt=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier: String? = nil) -> SCLAlertViewResponder {
        return showTitle(title, subTitle: subTitle, duration:duration, completeText:closeButtonTitle, style: style, colorStyle: colorStyle, colorTextButton: colorTextButton, circleIconImage: circleIconImage, accessibilityIdentifier: accessibilityIdentifier)
    }
    
    // showTitle(view, title, subTitle, duration, style)
    public func showTitle(title: String, subTitle: String, duration: NSTimeInterval?, completeText: String?, style: SCLAlertViewStyle, colorStyle: UInt?=0x000000, colorTextButton: UInt?=0xFFFFFF, circleIconImage: UIImage? = nil, accessibilityIdentifier:String?=nil) -> SCLAlertViewResponder {
        selfReference = self
        view.alpha = 0
        view.accessibilityIdentifier = accessibilityIdentifier
        let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds
        
        // Alert colour/icon
        viewColor = UIColor()
        var iconImage: UIImage?
        let colorInt = colorStyle ?? style.defaultColorInt
        viewColor = UIColorFromRGB(colorInt)
        // Icon style
        switch style {
        case .Success:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage: SCLAlertViewStyleKit.imageOfCheckmark)
            
        case .Error:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage: SCLAlertViewStyleKit.imageOfCross)
            
        case .Notice:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage:SCLAlertViewStyleKit.imageOfNotice)
            
        case .Warning:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage:SCLAlertViewStyleKit.imageOfWarning)
            
        case .Info:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage:SCLAlertViewStyleKit.imageOfInfo)
            
        case .Edit:
            
            iconImage = checkCircleIconImage(circleIconImage, defaultImage:SCLAlertViewStyleKit.imageOfEdit)
            
        case .Wait:
            iconImage = nil
        }
        
        // Title
        if !title.isEmpty {
            self.labelTitle.text = title
        }
        
        // Subtitle
        if !subTitle.isEmpty {
            viewText.text = subTitle
            // Adjust text view size, if necessary
            let str = subTitle as NSString
            let attr = [NSFontAttributeName:viewText.font ?? UIFont()]
            let sz = CGSize(width: appearance.kWindowWidth - 24, height:90)
            let r = str.boundingRectWithSize(sz, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:attr, context:nil)
            let ht = ceil(r.size.height)
            if ht < appearance.kTextHeight {
                appearance.kWindowHeight -= (appearance.kTextHeight - ht)
                appearance.setkTextHeight(ht)
            }
        }
        
        // Done button
        if appearance.showCloseButton {
            addButton(completeText ?? "Done", target:self, selector:#selector(SCLAlertView.hideView))
        }
        
        //hidden/show circular view based on the ui option
        circleView.hidden = !appearance.showCircularIcon
        circleBG.hidden = !appearance.showCircularIcon
        
        // Alert view colour and images
        circleView.backgroundColor = viewColor
        // Spinner / icon
        if style == .Wait {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            indicator.startAnimating()
            circleIconView = indicator
        }
        else {
            if let iconTintColor = iconTintColor {
                circleIconView = UIImageView(image: iconImage!.imageWithRenderingMode(.AlwaysTemplate))
                circleIconView?.tintColor = iconTintColor
            }
            else {
                circleIconView = UIImageView(image: iconImage!)
            }
        }
        circleView.addSubview(circleIconView!)
        let x = (appearance.kCircleHeight - appearance.kCircleIconHeight) / 2
        circleIconView!.frame = CGRectMake( x, x, appearance.kCircleIconHeight, appearance.kCircleIconHeight)
        
        for txt in inputs {
            txt.layer.borderColor = viewColor.CGColor
        }
        
        for txt in input {
            txt.layer.borderColor = viewColor.CGColor
        }
        
        for btn in buttons {
            if let customBackgroundColor = btn.customBackgroundColor {
                // Custom BackgroundColor set
                btn.backgroundColor = customBackgroundColor
            } else {
                // Use default BackgroundColor derived from AlertStyle
                btn.backgroundColor = viewColor
            }
            
            if let customTextColor = btn.customTextColor {
                // Custom TextColor set
                btn.setTitleColor(customTextColor, forState:UIControlState.Normal)
            } else {
                // Use default BackgroundColor derived from AlertStyle
                btn.setTitleColor(UIColorFromRGB(colorTextButton ?? 0xFFFFFF), forState:UIControlState.Normal)
            }
        }
        
        // Adding duration
        if duration > 0 {
            self.duration = duration
            durationTimer?.invalidate()
            durationTimer = NSTimer.scheduledTimerWithTimeInterval(self.duration, target: self, selector: #selector(SCLAlertView.hideView), userInfo: nil, repeats: false)
            durationStatusTimer?.invalidate()
            durationStatusTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SCLAlertView.updateDurationStatus), userInfo: nil, repeats: true)
        }
        
        // Animate in the alert view
        self.baseView.frame.origin.y = -400
        UIView.animateWithDuration(0.2, animations: {
            self.baseView.center.y = rv.center.y + 15
            self.view.alpha = 1
            }, completion: { finished in
                UIView.animateWithDuration(0.2, animations: {
                    self.baseView.center = rv.center
                })
        })
        // Chainable objects
        return SCLAlertViewResponder(alertview: self)
    }
    
    public func updateDurationStatus() {
        duration = duration.advancedBy(-1)
        for btn in buttons.filter({$0.showDurationStatus}) {
            let txt = "\(btn.initialTitle) (\(duration))"
            btn.setTitle(txt, forState: .Normal)
        }
    }
    
    // Close SCLAlertView
    public func hideView() {
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                
                //Stop durationTimer so alertView does not attempt to hide itself and fire it's dimiss block a second time when close button is tapped
                self.durationTimer?.invalidate()
                // Stop StatusTimer
                self.durationStatusTimer?.invalidate()
                
                // Call completion handler when the alert is dismissed
                self.dismissBlock?()
                
                // This is necessary for SCLAlertView to be de-initialized, preventing a strong reference cycle with the viewcontroller calling SCLAlertView.
                for button in self.buttons {
                    button.action = nil
                    button.target = nil
                    button.selector = nil
                }
                
                self.view.removeFromSuperview()
                self.selfReference = nil
        })
    }
    
    func checkCircleIconImage(circleIconImage: UIImage?, defaultImage: UIImage) -> UIImage {
        if let image = circleIconImage {
            return image
        } else {
            return defaultImage
        }
    }
}

// Helper function to convert from RGB to UIColor
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

// ------------------------------------
// Icon drawing
// Code generated by PaintCode
// ------------------------------------

class SCLAlertViewStyleKit : NSObject {
    
    // Cache
    struct Cache {
        static var imageOfCheckmark: UIImage?
        static var checkmarkTargets: [AnyObject]?
        static var imageOfCross: UIImage?
        static var crossTargets: [AnyObject]?
        static var imageOfNotice: UIImage?
        static var noticeTargets: [AnyObject]?
        static var imageOfWarning: UIImage?
        static var warningTargets: [AnyObject]?
        static var imageOfInfo: UIImage?
        static var infoTargets: [AnyObject]?
        static var imageOfEdit: UIImage?
        static var editTargets: [AnyObject]?
    }
    
    // Initialization
    /// swift 1.2 abolish func load
    //    override class func load() {
    //    }
    
    // Drawing Methods
    class func drawCheckmark() {
        // Checkmark Shape Drawing
        let checkmarkShapePath = UIBezierPath()
        checkmarkShapePath.moveToPoint(CGPointMake(73.25, 14.05))
        checkmarkShapePath.addCurveToPoint(CGPointMake(64.51, 13.86), controlPoint1: CGPointMake(70.98, 11.44), controlPoint2: CGPointMake(66.78, 11.26))
        checkmarkShapePath.addLineToPoint(CGPointMake(27.46, 52))
        checkmarkShapePath.addLineToPoint(CGPointMake(15.75, 39.54))
        checkmarkShapePath.addCurveToPoint(CGPointMake(6.84, 39.54), controlPoint1: CGPointMake(13.48, 36.93), controlPoint2: CGPointMake(9.28, 36.93))
        checkmarkShapePath.addCurveToPoint(CGPointMake(6.84, 49.02), controlPoint1: CGPointMake(4.39, 42.14), controlPoint2: CGPointMake(4.39, 46.42))
        checkmarkShapePath.addLineToPoint(CGPointMake(22.91, 66.14))
        checkmarkShapePath.addCurveToPoint(CGPointMake(27.28, 68), controlPoint1: CGPointMake(24.14, 67.44), controlPoint2: CGPointMake(25.71, 68))
        checkmarkShapePath.addCurveToPoint(CGPointMake(31.65, 66.14), controlPoint1: CGPointMake(28.86, 68), controlPoint2: CGPointMake(30.43, 67.26))
        checkmarkShapePath.addLineToPoint(CGPointMake(73.08, 23.35))
        checkmarkShapePath.addCurveToPoint(CGPointMake(73.25, 14.05), controlPoint1: CGPointMake(75.52, 20.75), controlPoint2: CGPointMake(75.7, 16.65))
        checkmarkShapePath.closePath()
        checkmarkShapePath.miterLimit = 4;
        
        UIColor.whiteColor().setFill()
        checkmarkShapePath.fill()
    }
    
    class func drawCross() {
        // Cross Shape Drawing
        let crossShapePath = UIBezierPath()
        crossShapePath.moveToPoint(CGPointMake(10, 70))
        crossShapePath.addLineToPoint(CGPointMake(70, 10))
        crossShapePath.moveToPoint(CGPointMake(10, 10))
        crossShapePath.addLineToPoint(CGPointMake(70, 70))
        crossShapePath.lineCapStyle = CGLineCap.Round;
        crossShapePath.lineJoinStyle = CGLineJoin.Round;
        UIColor.whiteColor().setStroke()
        crossShapePath.lineWidth = 14
        crossShapePath.stroke()
    }
    
    class func drawNotice() {
        // Notice Shape Drawing
        let noticeShapePath = UIBezierPath()
        noticeShapePath.moveToPoint(CGPointMake(72, 48.54))
        noticeShapePath.addLineToPoint(CGPointMake(72, 39.9))
        noticeShapePath.addCurveToPoint(CGPointMake(66.38, 34.01), controlPoint1: CGPointMake(72, 36.76), controlPoint2: CGPointMake(69.48, 34.01))
        noticeShapePath.addCurveToPoint(CGPointMake(61.53, 35.97), controlPoint1: CGPointMake(64.82, 34.01), controlPoint2: CGPointMake(62.69, 34.8))
        noticeShapePath.addCurveToPoint(CGPointMake(60.36, 35.78), controlPoint1: CGPointMake(61.33, 35.97), controlPoint2: CGPointMake(62.3, 35.78))
        noticeShapePath.addLineToPoint(CGPointMake(60.36, 33.22))
        noticeShapePath.addCurveToPoint(CGPointMake(54.16, 26.16), controlPoint1: CGPointMake(60.36, 29.3), controlPoint2: CGPointMake(57.65, 26.16))
        noticeShapePath.addCurveToPoint(CGPointMake(48.73, 29.89), controlPoint1: CGPointMake(51.64, 26.16), controlPoint2: CGPointMake(50.67, 27.73))
        noticeShapePath.addLineToPoint(CGPointMake(48.73, 28.71))
        noticeShapePath.addCurveToPoint(CGPointMake(43.49, 21.64), controlPoint1: CGPointMake(48.73, 24.78), controlPoint2: CGPointMake(46.98, 21.64))
        noticeShapePath.addCurveToPoint(CGPointMake(39.03, 25.37), controlPoint1: CGPointMake(40.97, 21.64), controlPoint2: CGPointMake(39.03, 23.01))
        noticeShapePath.addLineToPoint(CGPointMake(39.03, 9.07))
        noticeShapePath.addCurveToPoint(CGPointMake(32.24, 2), controlPoint1: CGPointMake(39.03, 5.14), controlPoint2: CGPointMake(35.73, 2))
        noticeShapePath.addCurveToPoint(CGPointMake(25.45, 9.07), controlPoint1: CGPointMake(28.56, 2), controlPoint2: CGPointMake(25.45, 5.14))
        noticeShapePath.addLineToPoint(CGPointMake(25.45, 41.47))
        noticeShapePath.addCurveToPoint(CGPointMake(24.29, 43.44), controlPoint1: CGPointMake(25.45, 42.45), controlPoint2: CGPointMake(24.68, 43.04))
        noticeShapePath.addCurveToPoint(CGPointMake(9.55, 43.04), controlPoint1: CGPointMake(16.73, 40.88), controlPoint2: CGPointMake(11.88, 40.69))
        noticeShapePath.addCurveToPoint(CGPointMake(8, 46.58), controlPoint1: CGPointMake(8.58, 43.83), controlPoint2: CGPointMake(8, 45.2))
        noticeShapePath.addCurveToPoint(CGPointMake(14.4, 55.81), controlPoint1: CGPointMake(8.19, 50.31), controlPoint2: CGPointMake(12.07, 53.84))
        noticeShapePath.addLineToPoint(CGPointMake(27.2, 69.56))
        noticeShapePath.addCurveToPoint(CGPointMake(42.91, 77.8), controlPoint1: CGPointMake(30.5, 74.47), controlPoint2: CGPointMake(35.73, 77.21))
        noticeShapePath.addCurveToPoint(CGPointMake(43.88, 77.8), controlPoint1: CGPointMake(43.3, 77.8), controlPoint2: CGPointMake(43.68, 77.8))
        noticeShapePath.addCurveToPoint(CGPointMake(47.18, 78), controlPoint1: CGPointMake(45.04, 77.8), controlPoint2: CGPointMake(46.01, 78))
        noticeShapePath.addLineToPoint(CGPointMake(48.34, 78))
        noticeShapePath.addLineToPoint(CGPointMake(48.34, 78))
        noticeShapePath.addCurveToPoint(CGPointMake(71.61, 52.08), controlPoint1: CGPointMake(56.48, 78), controlPoint2: CGPointMake(69.87, 75.05))
        noticeShapePath.addCurveToPoint(CGPointMake(72, 48.54), controlPoint1: CGPointMake(71.81, 51.29), controlPoint2: CGPointMake(72, 49.72))
        noticeShapePath.closePath()
        noticeShapePath.miterLimit = 4;
        
        UIColor.whiteColor().setFill()
        noticeShapePath.fill()
    }
    
    class func drawWarning() {
        // Color Declarations
        let greyColor = UIColor(red: 0.236, green: 0.236, blue: 0.236, alpha: 1.000)
        
        // Warning Group
        // Warning Circle Drawing
        let warningCirclePath = UIBezierPath()
        warningCirclePath.moveToPoint(CGPointMake(40.94, 63.39))
        warningCirclePath.addCurveToPoint(CGPointMake(36.03, 65.55), controlPoint1: CGPointMake(39.06, 63.39), controlPoint2: CGPointMake(37.36, 64.18))
        warningCirclePath.addCurveToPoint(CGPointMake(34.14, 70.45), controlPoint1: CGPointMake(34.9, 66.92), controlPoint2: CGPointMake(34.14, 68.49))
        warningCirclePath.addCurveToPoint(CGPointMake(36.22, 75.54), controlPoint1: CGPointMake(34.14, 72.41), controlPoint2: CGPointMake(34.9, 74.17))
        warningCirclePath.addCurveToPoint(CGPointMake(40.94, 77.5), controlPoint1: CGPointMake(37.54, 76.91), controlPoint2: CGPointMake(39.06, 77.5))
        warningCirclePath.addCurveToPoint(CGPointMake(45.86, 75.35), controlPoint1: CGPointMake(42.83, 77.5), controlPoint2: CGPointMake(44.53, 76.72))
        warningCirclePath.addCurveToPoint(CGPointMake(47.93, 70.45), controlPoint1: CGPointMake(47.18, 74.17), controlPoint2: CGPointMake(47.93, 72.41))
        warningCirclePath.addCurveToPoint(CGPointMake(45.86, 65.35), controlPoint1: CGPointMake(47.93, 68.49), controlPoint2: CGPointMake(47.18, 66.72))
        warningCirclePath.addCurveToPoint(CGPointMake(40.94, 63.39), controlPoint1: CGPointMake(44.53, 64.18), controlPoint2: CGPointMake(42.83, 63.39))
        warningCirclePath.closePath()
        warningCirclePath.miterLimit = 4;
        
        greyColor.setFill()
        warningCirclePath.fill()
        
        
        // Warning Shape Drawing
        let warningShapePath = UIBezierPath()
        warningShapePath.moveToPoint(CGPointMake(46.23, 4.26))
        warningShapePath.addCurveToPoint(CGPointMake(40.94, 2.5), controlPoint1: CGPointMake(44.91, 3.09), controlPoint2: CGPointMake(43.02, 2.5))
        warningShapePath.addCurveToPoint(CGPointMake(34.71, 4.26), controlPoint1: CGPointMake(38.68, 2.5), controlPoint2: CGPointMake(36.03, 3.09))
        warningShapePath.addCurveToPoint(CGPointMake(31.5, 8.77), controlPoint1: CGPointMake(33.01, 5.44), controlPoint2: CGPointMake(31.5, 7.01))
        warningShapePath.addLineToPoint(CGPointMake(31.5, 19.36))
        warningShapePath.addLineToPoint(CGPointMake(34.71, 54.44))
        warningShapePath.addCurveToPoint(CGPointMake(40.38, 58.16), controlPoint1: CGPointMake(34.9, 56.2), controlPoint2: CGPointMake(36.41, 58.16))
        warningShapePath.addCurveToPoint(CGPointMake(45.67, 54.44), controlPoint1: CGPointMake(44.34, 58.16), controlPoint2: CGPointMake(45.67, 56.01))
        warningShapePath.addLineToPoint(CGPointMake(48.5, 19.36))
        warningShapePath.addLineToPoint(CGPointMake(48.5, 8.77))
        warningShapePath.addCurveToPoint(CGPointMake(46.23, 4.26), controlPoint1: CGPointMake(48.5, 7.01), controlPoint2: CGPointMake(47.74, 5.44))
        warningShapePath.closePath()
        warningShapePath.miterLimit = 4;
        
        greyColor.setFill()
        warningShapePath.fill()
    }
    
    class func drawInfo() {
        // Color Declarations
        let color0 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        // Info Shape Drawing
        let infoShapePath = UIBezierPath()
        infoShapePath.moveToPoint(CGPointMake(45.66, 15.96))
        infoShapePath.addCurveToPoint(CGPointMake(45.66, 5.22), controlPoint1: CGPointMake(48.78, 12.99), controlPoint2: CGPointMake(48.78, 8.19))
        infoShapePath.addCurveToPoint(CGPointMake(34.34, 5.22), controlPoint1: CGPointMake(42.53, 2.26), controlPoint2: CGPointMake(37.47, 2.26))
        infoShapePath.addCurveToPoint(CGPointMake(34.34, 15.96), controlPoint1: CGPointMake(31.22, 8.19), controlPoint2: CGPointMake(31.22, 12.99))
        infoShapePath.addCurveToPoint(CGPointMake(45.66, 15.96), controlPoint1: CGPointMake(37.47, 18.92), controlPoint2: CGPointMake(42.53, 18.92))
        infoShapePath.closePath()
        infoShapePath.moveToPoint(CGPointMake(48, 69.41))
        infoShapePath.addCurveToPoint(CGPointMake(40, 77), controlPoint1: CGPointMake(48, 73.58), controlPoint2: CGPointMake(44.4, 77))
        infoShapePath.addLineToPoint(CGPointMake(40, 77))
        infoShapePath.addCurveToPoint(CGPointMake(32, 69.41), controlPoint1: CGPointMake(35.6, 77), controlPoint2: CGPointMake(32, 73.58))
        infoShapePath.addLineToPoint(CGPointMake(32, 35.26))
        infoShapePath.addCurveToPoint(CGPointMake(40, 27.67), controlPoint1: CGPointMake(32, 31.08), controlPoint2: CGPointMake(35.6, 27.67))
        infoShapePath.addLineToPoint(CGPointMake(40, 27.67))
        infoShapePath.addCurveToPoint(CGPointMake(48, 35.26), controlPoint1: CGPointMake(44.4, 27.67), controlPoint2: CGPointMake(48, 31.08))
        infoShapePath.addLineToPoint(CGPointMake(48, 69.41))
        infoShapePath.closePath()
        color0.setFill()
        infoShapePath.fill()
    }
    
    class func drawEdit() {
        // Color Declarations
        let color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        
        // Edit shape Drawing
        let editPathPath = UIBezierPath()
        editPathPath.moveToPoint(CGPointMake(71, 2.7))
        editPathPath.addCurveToPoint(CGPointMake(71.9, 15.2), controlPoint1: CGPointMake(74.7, 5.9), controlPoint2: CGPointMake(75.1, 11.6))
        editPathPath.addLineToPoint(CGPointMake(64.5, 23.7))
        editPathPath.addLineToPoint(CGPointMake(49.9, 11.1))
        editPathPath.addLineToPoint(CGPointMake(57.3, 2.6))
        editPathPath.addCurveToPoint(CGPointMake(69.7, 1.7), controlPoint1: CGPointMake(60.4, -1.1), controlPoint2: CGPointMake(66.1, -1.5))
        editPathPath.addLineToPoint(CGPointMake(71, 2.7))
        editPathPath.addLineToPoint(CGPointMake(71, 2.7))
        editPathPath.closePath()
        editPathPath.moveToPoint(CGPointMake(47.8, 13.5))
        editPathPath.addLineToPoint(CGPointMake(13.4, 53.1))
        editPathPath.addLineToPoint(CGPointMake(15.7, 55.1))
        editPathPath.addLineToPoint(CGPointMake(50.1, 15.5))
        editPathPath.addLineToPoint(CGPointMake(47.8, 13.5))
        editPathPath.addLineToPoint(CGPointMake(47.8, 13.5))
        editPathPath.closePath()
        editPathPath.moveToPoint(CGPointMake(17.7, 56.7))
        editPathPath.addLineToPoint(CGPointMake(23.8, 62.2))
        editPathPath.addLineToPoint(CGPointMake(58.2, 22.6))
        editPathPath.addLineToPoint(CGPointMake(52, 17.1))
        editPathPath.addLineToPoint(CGPointMake(17.7, 56.7))
        editPathPath.addLineToPoint(CGPointMake(17.7, 56.7))
        editPathPath.closePath()
        editPathPath.moveToPoint(CGPointMake(25.8, 63.8))
        editPathPath.addLineToPoint(CGPointMake(60.1, 24.2))
        editPathPath.addLineToPoint(CGPointMake(62.3, 26.1))
        editPathPath.addLineToPoint(CGPointMake(28.1, 65.7))
        editPathPath.addLineToPoint(CGPointMake(25.8, 63.8))
        editPathPath.addLineToPoint(CGPointMake(25.8, 63.8))
        editPathPath.closePath()
        editPathPath.moveToPoint(CGPointMake(25.9, 68.1))
        editPathPath.addLineToPoint(CGPointMake(4.2, 79.5))
        editPathPath.addLineToPoint(CGPointMake(11.3, 55.5))
        editPathPath.addLineToPoint(CGPointMake(25.9, 68.1))
        editPathPath.closePath()
        editPathPath.miterLimit = 4;
        editPathPath.usesEvenOddFillRule = true;
        color.setFill()
        editPathPath.fill()
    }
    
    // Generated Images
    class var imageOfCheckmark: UIImage {
        if (Cache.imageOfCheckmark != nil) {
            return Cache.imageOfCheckmark!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawCheckmark()
        Cache.imageOfCheckmark = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCheckmark!
    }
    
    class var imageOfCross: UIImage {
        if (Cache.imageOfCross != nil) {
            return Cache.imageOfCross!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawCross()
        Cache.imageOfCross = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfCross!
    }
    
    class var imageOfNotice: UIImage {
        if (Cache.imageOfNotice != nil) {
            return Cache.imageOfNotice!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawNotice()
        Cache.imageOfNotice = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfNotice!
    }
    
    class var imageOfWarning: UIImage {
        if (Cache.imageOfWarning != nil) {
            return Cache.imageOfWarning!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawWarning()
        Cache.imageOfWarning = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfWarning!
    }
    
    class var imageOfInfo: UIImage {
        if (Cache.imageOfInfo != nil) {
            return Cache.imageOfInfo!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawInfo()
        Cache.imageOfInfo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfInfo!
    }
    
    class var imageOfEdit: UIImage {
        if (Cache.imageOfEdit != nil) {
            return Cache.imageOfEdit!
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(80, 80), false, 0)
        SCLAlertViewStyleKit.drawEdit()
        Cache.imageOfEdit = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Cache.imageOfEdit!
    }
}
