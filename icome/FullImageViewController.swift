//
//  FullImageViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-04.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse


class FullImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var full_size_image: UIImageView!
    @IBOutlet weak var imageScroll: UIScrollView!
    var imageFile: PFFile!
    
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageScroll.delegate = self
        self.imageScroll.minimumZoomScale = 1.0
        self.imageScroll.maximumZoomScale = 3.0
        if(imageFile != nil){
            load_image()
        }else{
            SVProgressHUD.dismiss()
            NSLog("载入图片失败")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Loading Bar
        SVProgressHUD.show(withStatus: "载入中")
    }
    
    func load_image(){
        imageFile.getDataInBackground {
            (imageData: Data?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.full_size_image.image = UIImage(data: imageData)
                    SVProgressHUD.dismiss()
                }else{
                    NSLog("详情页图片格式转换失败")
                }
            }else{
                NSLog("详情页图片载入失败")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.full_size_image
    }
}
