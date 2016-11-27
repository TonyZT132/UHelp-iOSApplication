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
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        RCIM.sharedRCIM().userInfoDataSource = self
        
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "消息"
        self.emptyConversationView = UIView.init(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
    }
    
    /*Triggered when user touch table cell*/
    override func onSelectedTableRow(conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, atIndexPath indexPath: NSIndexPath!) {
        let conVC = RCConversationViewController()
        conVC.targetId = model.targetId
        conVC.userName = model.conversationTitle
        conVC.conversationType = RCConversationType.ConversationType_PRIVATE
        conVC.title = model.conversationTitle
        conVC.setMessageAvatarStyle(RCUserAvatarStyle.USER_AVATAR_CYCLE)
        conVC.hidesBottomBarWhenPushed = true
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(conVC, animated: true)
    }
    
    /*Get user info*/
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        let userInfo = RCUserInfo()
        userInfo.userId = userId
        userInfo.name = "友帮用户"

        let loadAllData:PFQuery = PFQuery(className: "_User")
        loadAllData.whereKey("username", equalTo:userId)
        loadAllData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let temp = NSMutableArray()
                
                /*find user info in Parse*/
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                userInfo.name = temp.firstObject!.objectForKey("nick_name") as? String
                let image_file = temp.firstObject!.objectForKey("featured_image") as? PFFile
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
