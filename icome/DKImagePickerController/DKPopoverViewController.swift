//
//  DKPopoverViewController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/6/27.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

class DKPopoverViewController: UIViewController {
    
    class func popoverViewController(_ viewController: UIViewController, fromView: UIView) {
        let window = UIApplication.shared.keyWindow!
        
        let popoverViewController = DKPopoverViewController()
        
        popoverViewController.contentViewController = viewController
        popoverViewController.fromView = fromView
        
        popoverViewController.showInView(window)
        window.rootViewController!.addChildViewController(popoverViewController)
    }
    
    class func dismissPopoverViewController() {
        let window = UIApplication.shared.keyWindow!

        for vc in window.rootViewController!.childViewControllers {
            if vc is DKPopoverViewController {
                (vc as! DKPopoverViewController).dismiss()
            }
        }
    }
    
    class DKPopoverView: UIView {
        
        var contentView: UIView! {
            didSet {
                contentView.layer.cornerRadius = 5
                contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(contentView)
            }
        }
        
        let arrowWidth: CGFloat = 20
        let arrowHeight: CGFloat = 10
        fileprivate let arrowImageView: UIImageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.commonInit()
        }
        
        func commonInit() {
            arrowImageView.image = self.arrowImage()
            self.addSubview(arrowImageView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.arrowImageView.frame = CGRect(x: (self.bounds.width - self.arrowWidth) / 2, y: 0, width: arrowWidth, height: arrowHeight)
            self.contentView.frame = CGRect(x: 0, y: self.arrowHeight, width: self.bounds.width, height: self.bounds.height - arrowHeight)
        }
        
        func arrowImage() -> UIImage {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: arrowWidth, height: arrowHeight), false, UIScreen.main.scale)
            
            let context = UIGraphicsGetCurrentContext()
            UIColor.clear.setFill()
            context?.fill(CGRect(x: 0, y: 0, width: arrowWidth, height: arrowHeight))
            
            let arrowPath = CGMutablePath()
            
            CGPathMoveToPoint(arrowPath, nil,  arrowWidth / 2, 0)
            CGPathAddLineToPoint(arrowPath, nil, arrowWidth, arrowHeight)
            CGPathAddLineToPoint(arrowPath, nil, 0, arrowHeight)
            arrowPath.closeSubpath()

            context?.addPath(arrowPath)
            
            context?.setFillColor(UIColor.white.cgColor)
            context?.drawPath(using: CGPathDrawingMode.fill)

            let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return arrowImage!
        }
    }
    
    var contentViewController: UIViewController!
    var fromView: UIView!
    fileprivate let popoverView = DKPopoverView()
    fileprivate var popoverViewHeight: CGFloat!
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = UIControl(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.addTarget(self, action: #selector(DKPopoverViewController.dismiss), for: .touchUpInside)
        backgroundView.autoresizingMask = self.view.autoresizingMask
        self.view = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(popoverView)
    }

	@available(iOS, deprecated: 8.0)
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotate(from: fromInterfaceOrientation)
		
        let popoverY = self.fromView.convert(self.fromView.frame.origin, to: self.view).y + self.fromView.bounds.height
        self.popoverViewHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, self.view.bounds.height - popoverY - 40)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.popoverView.frame = CGRect(x: 0, y: popoverY,
                width: self.view.bounds.width, height: self.popoverViewHeight)
        })
        
    }
    
    func showInView(_ view: UIView) {
        let popoverY = self.fromView.convert(self.fromView.frame.origin, to: view).y + self.fromView.bounds.height
        self.popoverViewHeight = min(self.contentViewController.preferredContentSize.height + self.popoverView.arrowHeight, view.bounds.height - popoverY - 40)
        
        self.popoverView.frame = CGRect(x: 0, y: popoverY,
            width: view.bounds.width, height: popoverViewHeight)
        self.popoverView.contentView = self.contentViewController.view
        
        view.addSubview(self.view)
        
        self.popoverView.transform = self.popoverView.transform.translatedBy(x: 0, y: -(self.popoverViewHeight / 2)).scaledBy(x: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.3, options: .allowUserInteraction, animations: {
            self.popoverView.transform = CGAffineTransform.identity
            self.view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        }, completion: nil)
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.popoverView.transform = self.popoverView.transform.translatedBy(x: 0, y: -(self.popoverViewHeight / 2)).scaledBy(x: 0.01, y: 0.01)
            self.view.backgroundColor = UIColor.clear
        }, completion: { (result) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }) 
    }
}
