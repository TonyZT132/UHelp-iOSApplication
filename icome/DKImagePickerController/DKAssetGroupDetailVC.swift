//
//  DKAssetGroupDetailVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/10.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

private let DKImageCameraIdentifier = "DKImageCameraIdentifier"
private let DKImageAssetIdentifier = "DKImageAssetIdentifier"
private let DKVideoAssetIdentifier = "DKVideoAssetIdentifier"

// Nofifications
internal let DKImageSelectedNotification = "DKImageSelectedNotification"
internal let DKImageUnselectedNotification = "DKImageUnselectedNotification"

// Group Model
internal class DKAssetGroup : NSObject {
    var groupName: String!
    var thumbnail: UIImage!
    var totalCount: Int!
    var group: ALAssetsGroup!
}

private extension DKImagePickerControllerAssetType {

    func toALAssetsFilter() -> ALAssetsFilter {
        switch self {
        case .allPhotos:
            return ALAssetsFilter.allPhotos()
        case .allVideos:
            return ALAssetsFilter.allVideos()
        case .allAssets:
            return ALAssetsFilter.allAssets()
        }
    }
}

private let DKImageSystemVersionLessThan8 = UIDevice.current.systemVersion.compare("8.0.0", options: .numeric) == .orderedAscending

// Show all images in the asset group
internal class DKAssetGroupDetailVC: UICollectionViewController {
    
    class DKImageCameraCell: UICollectionViewCell {
        
        var didCameraButtonClicked: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let cameraButton = UIButton(frame: frame)
            cameraButton.addTarget(self, action: #selector(DKImageCameraCell.cameraButtonClicked), for: .touchUpInside)
            cameraButton.setImage(DKImageResource.cameraImage(), for: UIControlState())
            cameraButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView.addSubview(cameraButton)
            
            self.contentView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func cameraButtonClicked() {
            if let didCameraButtonClicked = self.didCameraButtonClicked {
                didCameraButtonClicked()
            }
        }
        
    } /* DKImageCameraCell */

    class DKAssetCell: UICollectionViewCell {
        
        class DKImageCheckView: UIView {
            
            fileprivate lazy var checkImageView: UIImageView = {
                let imageView = UIImageView(image: DKImageResource.checkedImage())
                
                return imageView
            }()
            
            fileprivate lazy var checkLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.boldSystemFont(ofSize: 14)
                label.textColor = UIColor.white
                label.textAlignment = .right
                
                return label
            }()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                self.addSubview(checkImageView)
                self.addSubview(checkLabel)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                self.checkImageView.frame = self.bounds
                self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
            }
            
        } /* DKImageCheckView */
		
		var asset: DKAsset! {
			didSet {
				self.thumbnailImageView.image = asset.thumbnailImage
			}
		}
        fileprivate let thumbnailImageView: UIImageView = {
            let thumbnailImageView = UIImageView()
            thumbnailImageView.contentMode = .scaleAspectFill
            thumbnailImageView.clipsToBounds = true
            
            return thumbnailImageView
        }()
        
        fileprivate let checkView = DKImageCheckView()
        
        override var isSelected: Bool {
            didSet {
                checkView.isHidden = !super.isSelected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.thumbnailImageView.frame = self.bounds
            self.contentView.addSubview(self.thumbnailImageView)
            self.contentView.addSubview(checkView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
			
            self.thumbnailImageView.frame = self.bounds
            checkView.frame = self.thumbnailImageView.frame
        }
		
    } /* DKAssetCell */
    
    class DKVideoAssetCell: DKAssetCell {
		
		override var asset: DKAsset! {
			didSet {
				let videoDurationLabel = self.videoInfoView.viewWithTag(-1) as! UILabel
				let minutes: Int = Int(asset.duration!) / 60
				let seconds: Int = Int(asset.duration!) % 60
				videoDurationLabel.text = "\(minutes):\(seconds)"
			}
		}
		
        override var isSelected: Bool {
            didSet {
                if super.isSelected {
                    self.videoInfoView.backgroundColor = UIColor(red: 20 / 255, green: 129 / 255, blue: 252 / 255, alpha: 1)
                } else {
                    self.videoInfoView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
                }
            }
        }
        
        fileprivate lazy var videoInfoView: UIView = {
            let videoInfoView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))

            let videoImageView = UIImageView(image: DKImageResource.videoCameraIcon())
            videoInfoView.addSubview(videoImageView)
            videoImageView.center = CGPoint(x: videoImageView.bounds.width / 2 + 7, y: videoInfoView.bounds.height / 2)
            videoImageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
            
            let videoDurationLabel = UILabel()
            videoDurationLabel.tag = -1
            videoDurationLabel.textAlignment = .right
            videoDurationLabel.font = UIFont.systemFont(ofSize: 12)
            videoDurationLabel.textColor = UIColor.white
            videoInfoView.addSubview(videoDurationLabel)
            videoDurationLabel.frame = CGRect(x: 0, y: 0, width: videoInfoView.bounds.width - 7, height: videoInfoView.bounds.height)
            videoDurationLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            return videoInfoView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.contentView.addSubview(videoInfoView)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let height: CGFloat = 30
            self.videoInfoView.frame = CGRect(x: 0, y: self.contentView.bounds.height - height,
                width: self.contentView.bounds.width, height: height)
        }
        
    } /* DKVideoAssetCell */
    
    class DKPermissionView: UIView {
        
        let titleLabel = UILabel()
        let permitButton = UIButton()
        
        class func permissionView(_ style: DKImagePickerControllerSourceType) -> DKPermissionView {
            
            let permissionView = DKPermissionView()
            permissionView.addSubview(permissionView.titleLabel)
            permissionView.addSubview(permissionView.permitButton)
            
            if style == .Photo {
                permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionPhoto")
                permissionView.titleLabel.textColor = UIColor.gray
            } else {
                permissionView.titleLabel.textColor = UIColor.white
                permissionView.titleLabel.text = DKImageLocalizedStringWithKey("permissionCamera")
            }
            permissionView.titleLabel.sizeToFit()
            
            if DKImageSystemVersionLessThan8 {
                permissionView.permitButton.setTitle(DKImageLocalizedStringWithKey("gotoSettings"), for: UIControlState())
            } else {
                permissionView.permitButton.setTitle(DKImageLocalizedStringWithKey("permit"), for: UIControlState())
                permissionView.permitButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255, blue: 1, alpha: 1), for: UIControlState())
                permissionView.permitButton.addTarget(permissionView, action: #selector(DKPermissionView.gotoSettings), for: .touchUpInside)
            }
            permissionView.permitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            permissionView.permitButton.sizeToFit()
            permissionView.permitButton.center = CGPoint(x: permissionView.titleLabel.center.x,
                y: permissionView.titleLabel.bounds.height + 40)
            
            permissionView.frame.size = CGSize(width: max(permissionView.titleLabel.bounds.width, permissionView.permitButton.bounds.width),
                height: permissionView.permitButton.frame.maxY)
            
            return permissionView
        }
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            self.center = self.superview!.center
        }
        
        func gotoSettings() {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        
    } /* DKPermissionView */
    
    fileprivate var groups = [DKAssetGroup]()
    
    fileprivate lazy var selectGroupButton: UIButton = {
        let button = UIButton()
		
		let globalTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor
		button.setTitleColor(globalTitleColor ?? UIColor.black, for: UIControlState())
		
		let globalTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont
		button.titleLabel!.font = globalTitleFont ?? UIFont.boldSystemFont(ofSize: 18.0)
		
		button.addTarget(self, action: #selector(DKAssetGroupDetailVC.showGroupSelector), for: .touchUpInside)
        return button
    }()
	
	static fileprivate let library = ALAssetsLibrary()
    
    internal var selectedAssetGroup: DKAssetGroup?
    
    fileprivate lazy var selectGroupVC: DKAssetGroupVC = {
        let groupVC = DKAssetGroupVC()
        groupVC.selectedGroupBlock = {[unowned self] (assetGroup: DKAssetGroup) in
            self.selectAssetGroup(assetGroup)
        }
        return groupVC
    }()
    
    fileprivate var hidesCamera :Bool = false
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        
        let interval: CGFloat = 3
        layout.minimumInteritemSpacing = interval
        layout.minimumLineSpacing = interval
        
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let itemWidth = (screenWidth - interval * 3) / 3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        self.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.collectionView!.backgroundColor = UIColor.white
        self.collectionView!.allowsMultipleSelection = true
        self.collectionView!.register(DKImageCameraCell.self, forCellWithReuseIdentifier: DKImageCameraIdentifier)
        self.collectionView!.register(DKAssetCell.self, forCellWithReuseIdentifier: DKImageAssetIdentifier)
        self.collectionView!.register(DKVideoAssetCell.self, forCellWithReuseIdentifier: DKVideoAssetIdentifier)
		
		self.loadAssetGroupsThen { (error) -> () in
			if let firstGroup = self.groups.first {
				self.selectAssetGroup(firstGroup)
			}
		}

    }
	
	func loadAssetGroupsThen(_ block: @escaping ((_ error: NSError?) -> ())) {
		if let imagePickerController = self.imagePickerController, imagePickerController.sourceType.rawValue & DKImagePickerControllerSourceType.Photo.rawValue == 0 {
				imagePickerController.isNavigationBarHidden = true
				imagePickerController.setViewControllers([self.createCamera()], animated: false)
				return
		}
		
		DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async { () -> Void in
			
			type(of: self).library.enumerateGroupsWithTypes(self.imagePickerController!.assetGroupTypes, usingBlock: { [weak self] (group, stop) in
				
				guard let strongSelf = self else { return }
				guard let imagePickerController = strongSelf.imagePickerController else { return }
				
				if group != nil {
					group?.setAssetsFilter(imagePickerController.assetType.toALAssetsFilter())

					if group?.numberOfAssets() != 0 {
						let groupName = group?.value(forProperty: ALAssetsGroupPropertyName) as! String
						
						let assetGroup = DKAssetGroup()
						assetGroup.groupName = groupName
						
						group?.enumerateAssets(at: IndexSet(integer: (group?.numberOfAssets())! - 1),
							options: .reverse,
							using: { (asset, index, stop) -> Void in
								if asset != nil {
									assetGroup.thumbnail = UIImage(cgImage:(asset?.thumbnail().takeUnretainedValue())!)
								}
						})
						
						assetGroup.group = group
						assetGroup.totalCount = group?.numberOfAssets()
						strongSelf.groups.insert(assetGroup, at: 0)
					}
				} else {
					DispatchQueue.main.async(execute: { [weak self] () -> Void in
						guard let strongSelf = self else { return }
						strongSelf.hidesCamera = imagePickerController.sourceType.rawValue & DKImagePickerControllerSourceType.Camera.rawValue == 0
						strongSelf.selectGroupButton.isEnabled = strongSelf.groups.count > 1
						block(nil)
					})
				}
				}, failureBlock: {(error) in
					DispatchQueue.main.async(execute: { [weak self]() -> Void in
						guard let strongSelf = self else { return }
						strongSelf.collectionView?.isHidden = true
						strongSelf.view.addSubview(DKPermissionView.permissionView(.Photo))
						block(error as NSError?)
					})
			})
		}
	}
	
    func selectAssetGroup(_ assetGroup: DKAssetGroup) {
        if self.selectedAssetGroup == assetGroup {
            return
        }
        
        self.selectedAssetGroup = assetGroup
        self.title = assetGroup.groupName
		
        self.selectGroupButton.setTitle(assetGroup.groupName + (self.groups.count > 1 ? "  \u{25be}" : "" ), for: UIControlState())
        self.selectGroupButton.sizeToFit()
        self.navigationItem.titleView = self.selectGroupButton
		self.collectionView!.reloadData()
    }
    
    func showGroupSelector() {
        self.selectGroupVC.groups = groups
        
        DKPopoverViewController.popoverViewController(self.selectGroupVC, fromView: self.selectGroupButton)
    }
    
    func createCamera() -> DKCamera {
        let camera = DKCamera()
        camera.didCancel = {[unowned camera] () -> Void in
            camera.dismiss(animated: true, completion: nil)
        }
        
        camera.didFinishCapturingImage = {(image) in
            NotificationCenter.default.post(name: Notification.Name(rawValue: DKImageSelectedNotification), object: DKAsset(image: image))
            self.dismiss(animated: true, completion: nil)
        }
        
        func cameraDenied() {
            DispatchQueue.main.async {
                let permissionView = DKPermissionView.permissionView(.Camera)
                camera.cameraOverlayView = permissionView
            }
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus != .authorized {
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                    if !granted {
                        cameraDenied()
                    }
                })
            } else {
                cameraDenied()
            }
        }
        
        return camera
    }
	
    // MARK: - Cells

    func cameraCellForIndexPath(_ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: DKImageCameraIdentifier, for: indexPath) as! DKImageCameraCell
        
        cell.didCameraButtonClicked = { [unowned self] () in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.present(self.createCamera(), animated: true, completion: nil)
                
            }
        }

        return cell
    }

    func assetCellForIndexPath(_ indexPath: IndexPath) -> UICollectionViewCell {
		var assetIndex: Int!
		if let totalCount = self.selectedAssetGroup?.totalCount {
			assetIndex = totalCount - (indexPath.row - (self.hidesCamera ? 0 : 1)) - 1
		}

		var cell: DKAssetCell!
		self.selectedAssetGroup?.group.enumerateAssets(at: IndexSet(integer: assetIndex), options: .reverse,
			using: { (result, index, stop) -> Void in
				if result != nil {
					// WARNING: test
					let asset = DKAsset(originalAsset: result!)
					
					var identifier: String!
					if asset.isVideo {
						identifier = DKVideoAssetIdentifier
					} else {
						identifier = DKImageAssetIdentifier
					}
					
					cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DKAssetCell
					cell.asset = asset
					
					if let index = self.imagePickerController!.selectedAssets.index(of: asset) {
						cell.isSelected = true
						cell.checkView.checkLabel.text = "\(index + 1)"
						self.collectionView!.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
					} else {
						cell.isSelected = false
						self.collectionView!.deselectItem(at: indexPath, animated: false)
					}
				}
		})
		
        return cell
    }
	
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.selectedAssetGroup?.totalCount ?? 0) + (self.hidesCamera ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 && !self.hidesCamera {
            return self.cameraCellForIndexPath(indexPath)
        } else {
            return self.assetCellForIndexPath(indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let firstSelectedAsset = self.imagePickerController?.selectedAssets.first,
            let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset, self.imagePickerController?.allowMultipleTypes == false && firstSelectedAsset.isVideo != selectedAsset.isVideo {
                
                UIAlertView(title: DKImageLocalizedStringWithKey("selectPhotosOrVideos"),
                    message: DKImageLocalizedStringWithKey("selectPhotosOrVideosError"),
                    delegate: nil,
                    cancelButtonTitle: DKImageLocalizedStringWithKey("ok")).show()
                
                return false
        }
        
        return self.imagePickerController!.selectedAssets.count < self.imagePickerController!.maxSelectableCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset
        NotificationCenter.default.post(name: Notification.Name(rawValue: DKImageSelectedNotification), object: selectedAsset)
        
		let cell = collectionView.cellForItem(at: indexPath) as! DKAssetCell
		cell.checkView.checkLabel.text = "\(self.imagePickerController!.selectedAssets.count)"
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if let removedAsset = (collectionView.cellForItem(at: indexPath) as? DKAssetCell)?.asset {
			let removedIndex = self.imagePickerController!.selectedAssets.index(of: removedAsset)!
			
			/// Minimize the number of cycles.
			let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems as [IndexPath]!
			let indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
			
			let intersect = Set(indexPathsForVisibleItems).intersection(Set(indexPathsForSelectedItems))
			
			for selectedIndexPath in intersect {
				if let selectedCell = (collectionView.cellForItem(at: selectedIndexPath) as? DKAssetCell) {
					let selectedIndex = self.imagePickerController!.selectedAssets.index(of: selectedCell.asset)!
					
					if selectedIndex > removedIndex {
						selectedCell.checkView.checkLabel.text = "\(Int(selectedCell.checkView.checkLabel.text!)! - 1)"
					}
				}
			}
			
			NotificationCenter.default.post(name: Notification.Name(rawValue: DKImageUnselectedNotification), object: removedAsset)
		}
    }
	
}
