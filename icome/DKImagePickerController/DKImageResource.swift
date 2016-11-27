//
//  DKImageResource.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/11.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

private extension Bundle {
    
    class func imagePickerControllerBundle() -> Bundle {
        let assetPath = Bundle(for: DKImageResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKImagePickerController.bundle"))!
    }
    
}

internal class DKImageResource {

    fileprivate class func imageForResource(_ name: String) -> UIImage {
        let bundle = Bundle.imagePickerControllerBundle()
        let imagePath = bundle.path(forResource: name, ofType: "png", inDirectory: "Images")
        let image = UIImage(contentsOfFile: imagePath!)
        return image!
    }
    
    class func checkedImage() -> UIImage {
        var image = imageForResource("checked_background")
        let center = image.size.width / 2
        image = image.resizableImage(withCapInsets: UIEdgeInsets(top: center, left: center, bottom: center, right: center))
        
        return image
    }
    
    class func blueTickImage() -> UIImage {
        return imageForResource("tick_blue")
    }
    
    class func cameraImage() -> UIImage {
        return imageForResource("camera")
    }
    
    class func videoCameraIcon() -> UIImage {
        return imageForResource("video_camera")
    }
    
}

internal class DKImageLocalizedString {
    
    class func localizedStringForKey(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "DKImagePickerController", bundle:Bundle.imagePickerControllerBundle(), value: "", comment: "")
    }
    
}

internal func DKImageLocalizedStringWithKey(_ key: String) -> String {
    return DKImageLocalizedString.localizedStringForKey(key)
}

