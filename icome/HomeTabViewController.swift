//
//  HomeTabViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-11.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class HomeTabViewController: CYLTabBarController {
    
    let tabTitle = ["首页","附近","聊天","我的"]
    let selectedImage = ["首页选中","地图选中","消息选中","我的选中"]
    let image = ["首页","地图","消息","我的"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Initialize Storyboard*/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*Set up View Controllers*/
        let home : HomeNaviViewController = storyboard.instantiateViewController(withIdentifier: HOME_NAV) as! HomeNaviViewController
        let map : MapNavViewController = storyboard.instantiateViewController(withIdentifier: "map_nav") as! MapNavViewController
        let message : MessageNavViewController = storyboard.instantiateViewController(withIdentifier: "message_nav") as! MessageNavViewController
        let setting : SettingNavViewController = storyboard.instantiateViewController(withIdentifier: "setting_nav") as! SettingNavViewController
        
        /*Create Tab Bar Items Array*/
        var tabBarItemsAttributes: [AnyObject] = []
        let viewControllers:[AnyObject] = [home,map,message,setting]
        
        for i in 0 ... tabTitle.count - 1 {
            let dict: [AnyHashable: Any] = [
                CYLTabBarItemTitle: tabTitle[i],
                CYLTabBarItemImage: image[i],
                CYLTabBarItemSelectedImage: selectedImage[i]
            ]
            
            tabBarItemsAttributes.append(dict as AnyObject)
        }
        self.tabBarItemsAttributes = tabBarItemsAttributes
        self.viewControllers = viewControllers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
