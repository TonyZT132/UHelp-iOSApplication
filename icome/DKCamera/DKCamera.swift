//
//  DKCamera.swift
//  DKCameraDemo
//
//  Created by ZhangAo on 15/8/30.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

open class DKCamera: UIViewController {

    open var didCancel: (() -> Void)?
    open var didFinishCapturingImage: ((_ image: UIImage) -> Void)?
    
    open var cameraOverlayView: UIView? {
        didSet {
            if let cameraOverlayView = cameraOverlayView {
                self.view.addSubview(cameraOverlayView)
            }
        }
    }
    
    /// The flashModel will to be remembered to next use.
    open var flashMode:AVCaptureFlashMode! {
        didSet {
            self.updateFlashButton()
            self.updateFlashMode()
            self.updateFlashModeToUserDefautls(self.flashMode)
        }
    }
    
    open class func isAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    fileprivate let captureSession = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    
    fileprivate var currentDevice: AVCaptureDevice?
    fileprivate var captureDeviceFront: AVCaptureDevice?
    fileprivate var captureDeviceBack: AVCaptureDevice?
    
    fileprivate var currentOrientation = UIInterfaceOrientation.portrait
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate lazy var flashButton: UIButton = {
        let flashButton = UIButton()
        flashButton.addTarget(self, action: #selector(DKCamera.switchFlashMode), for: .touchUpInside)
        
        return flashButton
    }()
    fileprivate var cameraSwitchButton: UIButton!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        self.setupDevices()
        self.setupUI()
        self.beginSession()
        
        self.setupMotionManager()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.captureSession.isRunning {
            self.captureSession.startRunning()
        }

        if !self.motionManager.isAccelerometerActive {
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (accelerometerData, error) -> Void in
                if error == nil {
                    self.outputAccelertionData(accelerometerData!.acceleration)
                } else {
                    print("error while update accelerometer: \(error!.localizedDescription)", terminator: "")
                }
            })
        }

    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession.stopRunning()
        self.motionManager.stopAccelerometerUpdates()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupDevices() {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        
        for device in devices {
            if device.position == .back {
                self.captureDeviceBack = device
            }
            
            if device.position == .front {
                self.captureDeviceFront = device
            }
        }
        
        self.currentDevice = self.captureDeviceBack ?? self.captureDeviceFront
    }
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.black
        let contentView = self.view
        
        let bottomView = UIView()
        let bottomViewHeight: CGFloat = 70
        bottomView.bounds.size = CGSize(width: (contentView?.bounds.width)!, height: bottomViewHeight)
        bottomView.frame.origin = CGPoint(x: 0, y: (contentView?.bounds.height)! - bottomViewHeight)
        bottomView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        contentView?.addSubview(bottomView)
        
        // switch button
        let cameraSwitchButton: UIButton = {
            let cameraSwitchButton = UIButton()
            cameraSwitchButton.addTarget(self, action: #selector(DKCamera.switchCamera), for: .touchUpInside)
            cameraSwitchButton.setImage(DKCameraResource.cameraSwitchImage(), for: UIControlState())
            cameraSwitchButton.sizeToFit()
            
            return cameraSwitchButton
        }()
        
        cameraSwitchButton.frame.origin = CGPoint(x: bottomView.bounds.width - cameraSwitchButton.bounds.width - 15,
            y: (bottomView.bounds.height - cameraSwitchButton.bounds.height) / 2)
        cameraSwitchButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        bottomView.addSubview(cameraSwitchButton)
        self.cameraSwitchButton = cameraSwitchButton
        
        // capture button
        let captureButton: UIButton = {
            
            class CaptureButton: UIButton {
                fileprivate override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.white
                    return true
                }
                
                fileprivate override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
                    self.backgroundColor = UIColor.white
                    return true
                }
                
                fileprivate override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
                    self.backgroundColor = nil
                }
                
                fileprivate override func cancelTracking(with event: UIEvent?) {
                    self.backgroundColor = nil
                }
            }
            
            let captureButton = CaptureButton()
            captureButton.addTarget(self, action: #selector(DKCamera.takePicture), for: .touchUpInside)
            captureButton.bounds.size = CGSize(width: bottomViewHeight,
                height: bottomViewHeight).applying(CGAffineTransform(scaleX: 0.9, y: 0.9))
            captureButton.layer.cornerRadius = captureButton.bounds.height / 2
            captureButton.layer.borderColor = UIColor.white.cgColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.masksToBounds = true
            
            return captureButton
        }()
        
        captureButton.center = CGPoint(x: bottomView.bounds.width / 2, y: bottomView.bounds.height / 2)
        captureButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        bottomView.addSubview(captureButton)
        
        // cancel button
        let cancelButton: UIButton = {
            let cancelButton = UIButton()
            cancelButton.addTarget(self, action: #selector(DKCamera.dismiss), for: .touchUpInside)
            cancelButton.setImage(DKCameraResource.cameraCancelImage(), for: UIControlState())
            cancelButton.sizeToFit()
            
            return cancelButton
        }()
        
        cancelButton.frame.origin = CGPoint(x: (contentView?.bounds.width)! - cancelButton.bounds.width - 15, y: 25)
        cancelButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        contentView?.addSubview(cancelButton)
        
        self.flashButton.frame.origin = CGPoint(x: 5, y: 15)
        contentView?.addSubview(self.flashButton)
    }
    
    // MARK: - Callbacks
    
    internal func dismiss() {
        self.didCancel?()
    }
    
    internal func takePicture() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .denied {
            return
        }
        
        if let stillImageOutput = self.captureSession.outputs.first as? AVCaptureStillImageOutput {
            DispatchQueue.global(priority: 0).async(execute: { () -> Void in
                let connection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
                
                if connection == nil {
                    return
                }
                
                connection.videoOrientation = self.currentOrientation.toAVCaptureVideoOrientation()
                
                stillImageOutput.captureStillImageAsynchronously(from: connection, completionHandler: { (imageDataSampleBuffer, error: NSError?) -> Void in
                    
                    if error == nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                                                
                        if let didFinishCapturingImage = self.didFinishCapturingImage,
                            let image = UIImage(data: imageData) {
                                
                                didFinishCapturingImage(image: image)
                        }
                    } else {
                        print("error while capturing still image: \(error!.localizedDescription)", terminator: "")
                    }
                })
            })
        }
        
    }
    
    // MARK: - Handles Focus
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch = touches.first!
        let touchPoint = anyTouch.location(in: self.view)
        self.focusAtTouchPoint(touchPoint)
    }
    
    // MARK: - Handles Switch Camera
    
    internal func switchCamera() {
        self.currentDevice = self.currentDevice == self.captureDeviceBack ?
            self.captureDeviceFront : self.captureDeviceBack
        
        self.setupCurrentDevice();
    }
    
    // MARK: - Handles Flash
    
    internal func switchFlashMode() {
        switch self.flashMode! {
        case .auto:
            self.flashMode = .off
        case .on:
            self.flashMode = .auto
        case .off:
            self.flashMode = .on
        }
    }
    
    fileprivate func flashModeFromUserDefaults() -> AVCaptureFlashMode {
        let rawValue = UserDefaults.standard.integer(forKey: "DKCamera.flashMode")
        return AVCaptureFlashMode(rawValue: rawValue)!
    }
    
    fileprivate func updateFlashModeToUserDefautls(_ flashMode: AVCaptureFlashMode) {
        UserDefaults.standard.set(flashMode.rawValue, forKey: "DKCamera.flashMode")
    }
    
    fileprivate func updateFlashButton() {
        struct FlashImage {
            
            static let images = [
                AVCaptureFlashMode.auto : DKCameraResource.cameraFlashAutoImage(),
                AVCaptureFlashMode.on : DKCameraResource.cameraFlashOnImage(),
                AVCaptureFlashMode.off : DKCameraResource.cameraFlashOffImage()
            ]
            
        }
        let flashImage: UIImage = FlashImage.images[self.flashMode]!
        
        self.flashButton.setImage(flashImage, for: UIControlState())
        self.flashButton.sizeToFit()
    }
    
    // MARK: - Capture Session
    
    fileprivate func beginSession() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        self.setupCurrentDevice()
        
        let stillImageOutput = AVCaptureStillImageOutput()
        if self.captureSession.canAddOutput(stillImageOutput) {
            self.captureSession.addOutput(stillImageOutput)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.bounds.size = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
            height: max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
        self.previewLayer?.anchorPoint = CGPoint.zero
        self.previewLayer?.position = CGPoint.zero
        
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
    }
    
    fileprivate func setupCurrentDevice() {
        if let currentDevice = self.currentDevice {
            
            if currentDevice.isFlashAvailable {
                self.flashButton.isHidden = false
                self.flashMode = self.flashModeFromUserDefaults()
            } else {
                self.flashButton.isHidden = true
            }
            
            for oldInput in self.captureSession.inputs as! [AVCaptureInput] {
                self.captureSession.removeInput(oldInput)
            }
            
            let frontInput = try? AVCaptureDeviceInput(device: self.currentDevice)
            if self.captureSession.canAddInput(frontInput) {
                self.captureSession.addInput(frontInput)
            }
            
            try! currentDevice.lockForConfiguration()
            if currentDevice.isFocusModeSupported(.continuousAutoFocus) {
                currentDevice.focusMode = .continuousAutoFocus
            }
            
            if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentDevice.exposureMode = .continuousAutoExposure
            }
            
            currentDevice.unlockForConfiguration()
        }
    }
    
    fileprivate func updateFlashMode() {
        if let currentDevice = self.currentDevice, currentDevice.isFlashAvailable {
                try! currentDevice.lockForConfiguration()
                currentDevice.flashMode = self.flashMode
                currentDevice.unlockForConfiguration()
        }
    }
    
    fileprivate func focusAtTouchPoint(_ touchPoint: CGPoint) {
        
        func showFocusViewAtPoint(_ touchPoint: CGPoint) {
            
            struct FocusView {
                static let focusView: UIView = {
                    let focusView = UIView()
                    let diameter: CGFloat = 100
                    focusView.bounds.size = CGSize(width: diameter, height: diameter)
                    focusView.layer.borderWidth = 2
                    focusView.layer.cornerRadius = diameter / 2
                    focusView.layer.borderColor = UIColor.white.cgColor
                    
                    return focusView
                }()
            }
            FocusView.focusView.transform = CGAffineTransform.identity
            FocusView.focusView.center = touchPoint
            self.view.addSubview(FocusView.focusView)
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.1,
                options: UIViewAnimationOptions(), animations: { () -> Void in
                    FocusView.focusView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }) { (Bool) -> Void in
                FocusView.focusView.removeFromSuperview()
            }
        }
        
        if self.currentDevice == nil || self.currentDevice?.isFlashAvailable == false {
            return
        }
        
        let focusPoint = self.previewLayer!.captureDevicePointOfInterest(for: touchPoint)
        
        showFocusViewAtPoint(touchPoint)
        
        if let currentDevice = self.currentDevice {
                try! currentDevice.lockForConfiguration()
                currentDevice.focusPointOfInterest = focusPoint
                currentDevice.exposurePointOfInterest = focusPoint
                
                    currentDevice.focusMode = .continuousAutoFocus

                if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                    currentDevice.exposureMode = .continuousAutoExposure
                }

                currentDevice.unlockForConfiguration()
        }

    }
    
    // MARK: - Handles Orientation
    
    fileprivate func setupMotionManager() {
        self.motionManager.accelerometerUpdateInterval = 0.2
        self.motionManager.gyroUpdateInterval = 0.2
    }
    
    fileprivate func outputAccelertionData(_ acceleration: CMAcceleration) {
        var currentOrientation: UIInterfaceOrientation?
        
        if acceleration.x >= 0.75 {
            currentOrientation = .landscapeLeft
        } else if acceleration.x <= -0.75 {
            currentOrientation = .landscapeRight
        } else if acceleration.y <= -0.75 {
            currentOrientation = .portrait
        } else if acceleration.y >= 0.75 {
            currentOrientation = .portraitUpsideDown
        } else {
            return
        }
        
        if self.currentOrientation != currentOrientation! {
            self.currentOrientation = currentOrientation!
            
            self.updateUIForCurrentOrientation()
        }
    }
    
    fileprivate func updateUIForCurrentOrientation() {
        var degree = 0.0
        
        switch self.currentOrientation {
        case .portrait:
            degree = 0
        case .portraitUpsideDown:
            degree = 180
        case .landscapeLeft:
            degree = 270
        case .landscapeRight:
            degree = 90
        default:
            degree = 0.0
        }
        
        let rotateAffineTransform = CGAffineTransform.identity.rotated(by: degreesToRadians(degree))
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.flashButton.transform = rotateAffineTransform
            self.cameraSwitchButton.transform = rotateAffineTransform
        }) 
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}

// MARK: - Utilities

private extension UIInterfaceOrientation {
    
    func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        return AVCaptureVideoOrientation(rawValue: self.rawValue)!
    }

}

private func degreesToRadians(_ degree: Double) -> CGFloat {
    return CGFloat(degree / 180.0 * M_PI)
}

// MARK: - Rersources

private extension Bundle {
    
    class func cameraBundle() -> Bundle {
        let assetPath = Bundle(for: DKCameraResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKCameraResource.bundle"))!
    }
    
}

private class DKCameraResource {
    
    fileprivate class func imageForResource(_ name: String) -> UIImage {
        let bundle = Bundle.cameraBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
    
    class func cameraCancelImage() -> UIImage {
        return imageForResource("camera_cancel")
    }
    
    class func cameraFlashOnImage() -> UIImage {
        return imageForResource("camera_flash_on")
    }
    
    class func cameraFlashAutoImage() -> UIImage {
        return imageForResource("camera_flash_auto")
    }
    
    class func cameraFlashOffImage() -> UIImage {
        return imageForResource("camera_flash_off")
    }
    
    class func cameraSwitchImage() -> UIImage {
        return imageForResource("camera_switch")
    }
    
}

