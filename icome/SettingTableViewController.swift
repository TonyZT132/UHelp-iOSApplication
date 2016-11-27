//
//  SettingTableViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-09-30.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse
import CoreData

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var MessageBadge: UILabel!
    @IBOutlet weak var logout_button: UIButton!
    @IBOutlet weak var nick_name: UILabel!
    @IBOutlet weak var featured_image: UIImageView!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var GenderImage: UIImageView!
    @IBOutlet weak var email_verification_button: UIButton!

    var image_assets_update: [DKAsset]?
    var shared_code = ""
    var pending_submit = false
    
    // MARK: - Loading Root View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Load email validation status*/
        email_verification_button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        if(PFUser.currentUser()?.valueForKey("emailVerified") == nil || (PFUser.currentUser()?.valueForKey("emailVerified"))! as! Bool == false){
            
            /*If user requested email verifcation but not finish the verification yet*/
            if(PFUser.currentUser()?.email != nil){
                email_verification_button.setTitleColor(UIColor(red: 242.0/255.0, green: 55.0/255.0, blue: 61.0/255.0, alpha:1.0), forState: UIControlState.Normal)
                email_verification_button.setTitle("点击完成绑定", forState:.Normal)
                pending_submit = true
            }else{
                email_verification_button.setTitleColor(UIColor(red: 242.0/255.0, green: 55.0/255.0, blue: 61.0/255.0, alpha:1.0), forState: UIControlState.Normal)
                email_verification_button.setTitle("现在绑定", forState:.Normal)
                pending_submit = false
            }
        }else{
            email_verification_button.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: UIControlState.Normal)
            email_verification_button.setTitle("已绑定", forState:.Normal)
            email_verification_button.enabled = false
        }
        
        //load user info
        nick_name.text = PFUser.currentUser()?.objectForKey("nick_name") as? String
        CityLabel.text = PFUser.currentUser()?.objectForKey("city") as? String
        let gender_temp = PFUser.currentUser()?.objectForKey("gender") as? String
        if(gender_temp != nil){
            if (gender_temp == "M"){
                GenderImage.image = UIImage(named: "性别男")
            }
            else if (gender_temp == "F"){
                GenderImage.image = UIImage(named: "性别女")
            }else{
                /*Should Never Reach Here!*/
                NSLog("出现未知错误")
            }
        }
        
        /*Set the borderline and border colr for the buttom button*/
        logout_button.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this function is used to modify the layout of the featured image
    override func viewDidLayoutSubviews() {
        self.featured_image.layer.cornerRadius = self.featured_image.frame.size.height/2
        self.featured_image.clipsToBounds = true
    }
    
    //this function is used to setup the banner title, color and load user image
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MessageBadge.hidden = true
        MessageBadge.layer.cornerRadius = MessageBadge.frame.height / 2
        MessageBadge.clipsToBounds = true
        
        CheckMessage(PFUser.currentUser()) { (count, Error) -> Void in
            if(Error == nil){
                if(count > 0){
                    self.MessageBadge.text = String(count)
                    self.MessageBadge.hidden = false
                }
            }
        }
        navigationItem.title = "用户"
        
        let userImageFile = PFUser.currentUser()!.objectForKey("featured_image")  as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.featured_image.image = UIImage(data:imageData)
                }else{
                    NSLog("图片格式转换失败")
                }
            }else{
                NSLog("图片加载失败")
            }
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of rows
        if(section == 0){
            return 6
        }else{
            return 2
        }
    }
    
    //this function will provide transaction when user click certain table cells
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                
                /*Direct to profile page*/
                let profile : ProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
                
                profile.hidesBottomBarWhenPushed = true
                profile.SelectedUser = PFUser.currentUser()
                self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.pushViewController(profile, animated: true)
                
            }else if(indexPath.row == 2){
                /*Request changing password*/
                
                if(PFUser.currentUser()?.valueForKey("emailVerified") == nil || (PFUser.currentUser()?.valueForKey("emailVerified"))! as! Bool == false){
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMAIL_NOT_BIND, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    
                }else{
                    let alert = UIAlertController(title: ALERT, message: "确认更改密码？", preferredStyle: UIAlertControllerStyle.Alert)
                    let action_cancel = UIAlertAction(title: "返回",style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(action_cancel)
                    let action_reset = UIAlertAction(title: "更改密码",style: UIAlertActionStyle.Default, handler: resetPasswordHelper)
                    alert.addAction(action_reset)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else if(indexPath.row == 3){
                if(PFUser.currentUser()?.valueForKey("emailVerified") == nil || (PFUser.currentUser()?.valueForKey("emailVerified"))! as! Bool == false){
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMAIL_NOT_BIND, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    
                }else{
                    /*Request activation code*/
                    shared_code = ""
                    let params = ["number": (PFUser.currentUser()?.username)!] as [NSObject:AnyObject]
                    PFCloud.callFunctionInBackground("RequestActiviationCode", withParameters: params) {
                        (response: AnyObject?, error: NSError?) -> Void in
                        if(error == nil){
                            let code = response as! String
                                self.shared_code = code
                                let alert = UIAlertController(title: "获取成功", message: "邀请码为：" + code + "\n赶快告诉你的好友吧！", preferredStyle: UIAlertControllerStyle.Alert)
                                let action_cancel = UIAlertAction(title: "返回",style: UIAlertActionStyle.Default, handler: nil)
                                alert.addAction(action_cancel)
                                self.presentViewController(alert, animated: true, completion: nil)
                        }else{
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        }
                    }
                }
            }else if(indexPath.row == 4){
                
                /*Direct to follow page*/
                let follow : FollowViewController = self.storyboard?.instantiateViewControllerWithIdentifier("follow") as! FollowViewController
                if(PFUser.currentUser()?.objectForKey("follow") != nil){
                    var arr = [String]()
                    arr = PFUser.currentUser()?.objectForKey("follow") as! Array
                    if(arr.isEmpty == true){
                        self.presentViewController(show_alert_one_button("提示", message: "您还没有关注任何用户呢", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    }else{
                        follow.hidesBottomBarWhenPushed = true
                        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                        self.navigationController?.pushViewController(follow, animated: true)
                    }
                }else{
                     self.presentViewController(show_alert_one_button("提示", message: "您还没有关注任何用户呢", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                }
            }else if(indexPath.row == 5){
                print("消息中心")
                
                /*Check Local Database*/
                let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
                do {
                    let messageArr = try managedContext.executeFetchRequest(fetchRequest)
                    if messageArr.count > 0 {
                        SVProgressHUD.dismiss()
                        let personal_info : PersonalInfoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("personal_info") as! PersonalInfoViewController
                        personal_info.hidesBottomBarWhenPushed = true
                        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                        self.navigationController?.pushViewController(personal_info, animated: true)
                    }else{
                        SVProgressHUD.dismiss()
                        self.presentViewController(show_alert_one_button("提示", message: "未收到任何信息", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    }
                } catch let error as NSError {
                    NSLog("Could not fetch \(error), \(error.userInfo)")
                    SVProgressHUD.dismiss()
                    self.presentViewController(show_alert_one_button("提示", message: "读取数据失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                }
            }
        }else if(indexPath.section == 1){
            switch indexPath.row{
                case 0:
                    //print("关于友帮")
                    let about : AboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("about") as! AboutViewController
                    about.hidesBottomBarWhenPushed = true
                    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                    self.navigationController?.pushViewController(about, animated: true)
                
                case 1:
                    //print("意见反馈")
                    let suggestion : SuggestionNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier("suggestion_nav") as! SuggestionNavViewController
                    self.presentViewController(suggestion, animated: true, completion: nil)
                default:
                    return
            }
        }else{
            return 
        }
    }
    
    func resetPasswordHelper (alert: UIAlertAction!) {
        resetPassword((PFUser.currentUser()?.email)!)
    }
    
    /*If user select change password*/
    func resetPassword(email : String){
        
        // convert the email string to lower case
        let emailToLowerCase = email.lowercaseString
        
        // remove any whitespaces before and after the email address
        let emailClean = emailToLowerCase.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        /*Request change password email*/
        PFUser.requestPasswordResetForEmailInBackground(emailClean) { (success, error) -> Void in
            if (error == nil) {
                
                self.presentViewController(show_alert_one_button(ALERT, message: ALERT_DO_PASSWORD_RESET_SOON, actionButton: ALERT_ACTION), animated: true, completion: nil)
            }else {
                
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_SEND_MESSAGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            }
        }
    }
    
    /*When user touch the eamil validation button*/
    @IBAction func email_veirfication(sender: AnyObject) {
        //self.performSegueWithIdentifier("email_veri", sender: self)
        /*1. Create the alert controller.*/
        
        if(pending_submit == false){
            email_input()
        }else{
            
            /*Last step to finish the email verification*/
            let alert = UIAlertController(title: ALERT, message: "如果您已经收到Email并已点击验证链接，请点击“完成验证”，如果需要重新发送邮件，点击“重新验证”", preferredStyle: UIAlertControllerStyle.Alert)
            let action_cancel = UIAlertAction(title: "完成验证",style: UIAlertActionStyle.Default, handler: finish_verification)
            alert.addAction(action_cancel)
            let action_reselect = UIAlertAction(title: "重新验证",style: UIAlertActionStyle.Default, handler: resend_email)
            alert.addAction(action_reselect)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /*Email Verfication: get email address*/
    func email_input(){
        let alert = UIAlertController(title: "绑定邮箱", message: "请输入邮箱地址", preferredStyle: .Alert)
        
        /*2. Add the text field. You can configure it however you need.*/
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "请输入邮箱地址"
        })
        
        /*3. Grab the value from the text field, and print it when the user clicks OK.*/
        alert.addAction(UIAlertAction(title: "提交", style: .Default, handler: { (action) -> Void in
            let email = alert.textFields![0] as UITextField
            
            if(email.text?.isEmpty == true || email.text! == ""){
                
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
                
            }else if(email.text?.isEmpty == false  && isValidEmail(email.text!) == false){
                
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            self.do_validation(email.text!)
        }))
        
        let action_cancel = UIAlertAction(title: "返回",style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action_cancel)
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func do_validation(email:String!){
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*Update email and request confirmation email*/
        let user = PFUser.currentUser()
        user!.email = ""
        user!.saveInBackgroundWithBlock { result, error in
            if (error != nil) {
                // Handle the error
                SVProgressHUD.dismiss()
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_VALIDATION_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            user!.email = email
            user!.saveInBackgroundWithBlock {result, error in
                if (error != nil) {
                    SVProgressHUD.dismiss()
                    
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_VALIDATION_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    return
                }else{
                    SVProgressHUD.dismiss()
                    
                    self.presentViewController(show_alert_one_button(ALERT, message: ALERT_EMAIL_VALIDATION_SENT, actionButton: ALERT_ACTION), animated: true, completion: nil)
                    
                    self.email_verification_button.setTitleColor(UIColor(red: 242.0/255.0, green: 55.0/255.0, blue: 61.0/255.0, alpha:1.0), forState: UIControlState.Normal)
                    self.email_verification_button.setTitle("点击完成绑定", forState:.Normal)
                    self.pending_submit = true
                }
            }
        }
    }
    
    /*When user want to redo the email verification*/
    func resend_email(alert: UIAlertAction!){
        email_input()
    }
    
    func finish_verification(alert: UIAlertAction!){
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:"_User")
        loadData.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                
                if(temp.count > 0){
                    if(temp.firstObject!.valueForKey("emailVerified") != nil && (temp.firstObject!.valueForKey("emailVerified"))! as! Bool == true){
                        
                        if let currentUser = PFUser.currentUser(){
                            currentUser["finished_submit"] = true
                            //set other fields the same way....
                            currentUser.saveInBackground()
                            SVProgressHUD.dismiss()
                            
                            self.email_verification_button.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: UIControlState.Normal)
                            self.email_verification_button.setTitle("已绑定", forState:.Normal)
                            self.email_verification_button.enabled = false
                            
                            self.presentViewController(show_alert_one_button("成功", message: "邮箱绑定成功", actionButton: "好的"), animated: true, completion: nil)
                        }else{
                            SVProgressHUD.dismiss()
                            self.presentViewController(show_alert_one_button("错误", message: "邮箱绑定失败", actionButton: "知道了"), animated: true, completion: nil)
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        self.presentViewController(show_alert_one_button("错误", message: "邮箱绑定失败", actionButton: "知道了"), animated: true, completion: nil)
                    }
                }else{
                    SVProgressHUD.dismiss()
                    self.presentViewController(show_alert_one_button("错误", message: "邮箱绑定失败", actionButton: "知道了"), animated: true, completion: nil)
                }
            } else {
                // Log details of the failure
                SVProgressHUD.dismiss()
                self.presentViewController(show_alert_one_button("错误", message: "邮箱绑定失败", actionButton: "知道了"), animated: true, completion: nil)
            }
        }
    }
    
    //This function will be trigered when user click logout button
    @IBAction func logout(sender: AnyObject) {
        let alert = UIAlertController(title: ALERT, message: "确定退出登录？", preferredStyle: UIAlertControllerStyle.Alert)
        let action_reselect = UIAlertAction(title: "退出登录",style: UIAlertActionStyle.Default, handler: back_to_login)
        alert.addAction(action_reselect)
        let action_cancel = UIAlertAction(title: "取消",style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action_cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //back to login page
    func back_to_login (alert: UIAlertAction!) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        //do logout
        image_assets?.removeAll()
        full_image_array.removeAllObjects()
        thumbnail_image_array.removeAllObjects()
        
        PFUser.logOut()
        RCIM.sharedRCIM().disconnect()
        searchByGender = "A"
        searchByCategory = "搞学术"
        messageConnect = false
        CleanUpLocalData()
        
        let start : StartingPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("starting_page") as! StartingPageViewController
        self.presentViewController(start, animated: true, completion: nil)
    }
}
