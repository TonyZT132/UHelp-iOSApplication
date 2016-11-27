//
//  ConversationListViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-27.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class ConversationListViewController: RCConversationListViewController, RCIMUserInfoDataSource {


    //@IBOutlet weak var back_to_main: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Remove notification badge number*/
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        RCIM.shared().userInfoDataSource = self
        
        /*Set up list of conversation type*/
        self.setDisplayConversationTypes([
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_CUSTOMERSERVICE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_PUBLICSERVICE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue
        ])
        self.refreshConversationTableViewIfNeeded()
    }
    
    /*Set up the navigation bar*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "消息"
        self.emptyConversationView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
    }
    
    /*Triggered when user touch table cell*/
    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {
        let conVC = RCConversationViewController()
        conVC.targetId = model.targetId
        conVC.userName = model.conversationTitle
        conVC.conversationType = RCConversationType.ConversationType_PRIVATE
        conVC.title = model.conversationTitle
        conVC.setMessageAvatarStyle(RCUserAvatarStyle.USER_AVATAR_CYCLE)
        conVC.hidesBottomBarWhenPushed = true
        
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController?.pushViewController(conVC, animated: true)
    }
    
    /*Get user info*/
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        let userInfo = RCUserInfo()
        userInfo.userId = userId
        userInfo.name = "友帮用户"

        let loadAllData:PFQuery = PFQuery(className: "_User")
        loadAllData.whereKey("username", equalTo:userId)
        loadAllData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let temp = NSMutableArray()
                
                /*find user info in Parse*/
                for obj:AnyObject in objects!{
                    temp.add(obj)
                }
                userInfo.name = temp.firstObject!.object(forKey: "nick_name") as? String
                let image_file = temp.firstObject!.object(forKey: "featured_image") as? PFFile
                userInfo.portraitUri = image_file?.url
                self.refreshConversationTableViewIfNeeded()
                completion(userInfo)
            } else {
                // Log details of the failure
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
}
