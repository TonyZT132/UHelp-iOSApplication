//
//  DKImagePickerController.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 14-10-2.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary

// MARK: - Public DKAsset

/**
 * An `DKAsset` object represents a photo or a video managed by the `DKImagePickerController`.
 */
open class DKAsset: NSObject {
    
    /// Returns a CGImage of the representation that is appropriate for displaying full screen.
    open fileprivate(set) lazy var fullScreenImage: UIImage? = {
		if let originalAsset = self.originalAsset {
			return UIImage(cgImage: (originalAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue()))
		}
		return nil
    }()
    
    /// Returns a CGImage representation of the asset.
    open fileprivate(set) lazy var fullResolutionImage: UIImage? = {
		if let originalAsset = self.originalAsset {
			return UIImage(cgImage: (originalAsset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()))
		}
		return nil
    }()
    
    /// The url uniquely identifies an asset that is an image or a video.
    open fileprivate(set) var url: URL?
    
    /// It's a square thumbnail of the asset.
    open fileprivate(set) var thumbnailImage: UIImage?
	
	/// The asset's creation date.
	open fileprivate(set) lazy var createDate: Date? = {
		if let originalAsset = self.originalAsset {
			return originalAsset.value(forProperty: ALAssetPropertyDate) as? Date
		}
		return nil
	}()
    
    /// When the asset was an image, it's false. Otherwise true.
    open fileprivate(set) var isVideo: Bool = false
    
    /// play time duration(seconds) of a video.
    open fileprivate(set) var duration: Double?
    
    internal var isFromCamera: Bool = false
    open fileprivate(set) var originalAsset: ALAsset?
	
	/// The source data of the asset.
	open fileprivate(set) lazy var rawData: Data? = {
		if let rep = self.originalAsset?.defaultRepresentation() {
			let sizeOfRawDataInBytes = Int(rep.size())
			let rawData = NSMutableData(length: sizeOfRawDataInBytes)!
			let bufferPtr = rawData.mutableBytes
			let bufferPtr8 = UnsafeMutablePointer<UInt8>(bufferPtr)
			
			rep.getBytes(bufferPtr8, fromOffset: 0, length: sizeOfRawDataInBytes, error: nil)
			return rawData as Data
		}
		return nil
	}()
	
    internal init(originalAsset: ALAsset) {
        super.init()
        
        self.thumbnailImage = UIImage(cgImage:originalAsset.aspectRatioThumbnail().takeUnretainedValue())
        self.url = originalAsset.value(forProperty: ALAssetPropertyAssetURL) as? URL
        self.originalAsset = originalAsset
        
        let assetType = originalAsset.value(forProperty: ALAssetPropertyType) as! NSString
        if assetType as String == ALAssetTypeVideo {
            let duration = originalAsset.value(forProperty: ALAssetPropertyDuration) as! NSNumber
            
            self.isVideo = true
            self.duration = duration.doubleValue
        }
    }
    
    internal init(image: UIImage) {
        super.init()
        
        self.isFromCamera = true
        self.fullScreenImage = image
        self.fullResolutionImage = image
        self.thumbnailImage = image
    }
    
    // Compare two DKAssets
    override open func isEqual(_ object: Any?) -> Bool {
        let another = object as! DKAsset!
        
        if let url = self.url, let anotherUrl = another?.url {
            return (url == anotherUrl)
        } else {
            return false
        }
    }
}

/**

 * allPhotos: Get all photos assets in the assets group.
 * allVideos: Get all video assets in the assets group.
 * allAssets: Get all assets in the group.
 */
@objc public enum DKImagePickerControllerAssetType : Int {

    case allPhotos, allVideos, allAssets
}

public struct DKImagePickerControllerSourceType : OptionSet {
    
    fileprivate var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    // MARK: _RawOptionSetType
    public init(rawValue value: UInt) { self.value = value }
    // MARK: NilLiteralConvertible
    public init(nilLiteral: ()) { self.value = 0 }
    // MARK: RawRepresentable
    public var rawValue: UInt { return self.value }
    // MARK: BitwiseOperationsType
    public static var allZeros: DKImagePickerControllerSourceType { return self.init(0) }
    
    public static var Camera: DKImagePickerControllerSourceType { return self.init(1 << 0) }
    public static var Photo: DKImagePickerControllerSourceType { return self.init(1 << 1) }
}

// MARK: - Public DKImagePickerController

/**
 * The `DKImagePickerController` class offers the all public APIs which will affect the UI.
 */
open class DKImagePickerController: UINavigationController {
    
    /// Forces selction of tapped image immediatly
    open var singleSelect = false
    
    /// The maximum count of assets which the user will be able to select.
    open var maxSelectableCount = 999
    
    // The types of ALAssetsGroups to display in the picker
    open var assetGroupTypes: UInt32 = ALAssetsGroupAll

    /// The type of picker interface to be displayed by the controller.
    open var assetType = DKImagePickerControllerAssetType.allAssets
    
    /// If sourceType is Camera will cause the assetType & maxSelectableCount & allowMultipleTypes & defaultSelectedAssets to be ignored.
    open var sourceType: DKImagePickerControllerSourceType = [.Camera, .Photo]
    
    /// Whether allows to select photos and videos at the same time.
    open var allowMultipleTypes = true
	
	/// The callback block is executed when user pressed the cancel button.
	open var didCancel: (() -> Void)?
	open var showCancelButton = false {
		didSet {
			if let rootVC =  self.viewControllers.first {
				if showCancelButton {
					rootVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
						target: self,
						action: #selector(DKImagePickerController.dismiss))
				} else {
					rootVC.navigationItem.leftBarButtonItem = nil
				}
			}
		}
	}
	
    /// The callback block is executed when user pressed the select button.
    open var didSelectAssets: ((_ assets: [DKAsset]) -> Void)?
	
    /// It will have selected the specific assets.
    open var defaultSelectedAssets: [DKAsset]? {
        didSet {
            if let defaultSelectedAssets = self.defaultSelectedAssets {
                for (index, asset) in defaultSelectedAssets.enumerated() {
                    if asset.isFromCamera {
                        self.defaultSelectedAssets!.remove(at: index)
                    }
                }
                
                self.selectedAssets = defaultSelectedAssets
                self.updateDoneButtonTitle()
            }
        }
    }
    
    internal var selectedAssets = [DKAsset]()
    
    fileprivate lazy var doneButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.navigationBar.tintColor, for: UIControlState())
        button.reversesTitleShadowWhenHighlighted = true
        button.addTarget(self, action: #selector(DKImagePickerController.done), for: UIControlEvents.touchUpInside)
      
        return button
    }()
    
    public convenience init() {
        let rootVC = DKAssetGroupDetailVC()
        self.init(rootViewController: rootVC)
      
        rootVC.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
        rootVC.navigationItem.hidesBackButton = true
        
        self.updateDoneButtonTitle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DKImagePickerController.selectedImage(_:)),
                                                                   name: NSNotification.Name(rawValue: DKImageSelectedNotification),
                                                                 object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DKImagePickerController.unselectedImage(_:)),
                                                                   name: NSNotification.Name(rawValue: DKImageUnselectedNotification),
                                                                 object: nil)
    }
    
    fileprivate func updateDoneButtonTitle() {
        if self.selectedAssets.count > 0 {
            self.doneButton.setTitle(DKImageLocalizedStringWithKey("select") + "(\(selectedAssets.count))", for: UIControlState())
        } else {
            self.doneButton.setTitle(DKImageLocalizedStringWithKey("done"), for: UIControlState())
        }
        self.doneButton.sizeToFit()
    }
	
	internal func dismiss() {
		self.dismiss(animated: true, completion: nil)
		self.didCancel?()
	}
	
    internal func done() {
        self.dismiss(animated: true, completion: nil)
        self.didSelectAssets?(self.selectedAssets)
    }
    
    // MARK: - Notifications
    
    internal func selectedImage(_ noti: Notification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.append(asset)
            if asset.isFromCamera {
                self.done()
            } else if self.singleSelect {
                self.done()
            } else {
                updateDoneButtonTitle()
            }
        }
    }
    
    internal func unselectedImage(_ noti: Notification) {
        if let asset = noti.object as? DKAsset {
            selectedAssets.remove(at: selectedAssets.index(of: asset)!)
            updateDoneButtonTitle()
        }
    }
    
    // MARK: - Handles Orientation

    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

}

// MARK: - Utilities

internal extension UIViewController {
    
    var imagePickerController: DKImagePickerController? {
        get {
            let nav = self.navigationController
            if nav is DKImagePickerController {
                return nav as? DKImagePickerController
            } else {
                return nil
            }
        }
    }
    
}
