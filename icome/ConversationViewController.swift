//
//  ConversationViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-27.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class ConversationViewController: RCConversationViewController {

    /*Conversation initialize*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.targetId = usernameTarget
        self.userName = nicknameTarget
        self.conversationType = RCConversationType.ConversationType_PRIVATE
        self.setMessageAvatarStyle(RCUserAvatarStyle.USER_AVATAR_CYCLE)
    }
    
    /*Setup the navagation bar*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = nicknameTarget
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
