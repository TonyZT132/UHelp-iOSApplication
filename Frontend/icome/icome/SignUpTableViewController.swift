//
//  SignUpTableViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-05.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class SignUpTableViewController: UITableViewController, RSKImageCropViewControllerDelegate {

    @IBOutlet weak var email_text: UITextField!
    @IBOutlet weak var selected_birthday_button: UIButton!
    @IBOutlet weak var cancel_button: UIButton!
    @IBOutlet weak var submit_button: UIButton!
    @IBOutlet weak var confirm_password: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var nick_name: UITextField!
    var selected_birthday:NSDate!
    var cropped_image: UIImage!
    var isBirthdaySelected = false
    
    // MARK: - Root view load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selected_birthday_button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        selected_birthday_button.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: UIControlState.Normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        self.tableView.addGestureRecognizer(tapGesture)
        
        submit_button.layer.cornerRadius = submit_button.frame.height / 2
        submit_button.clipsToBounds = true
        cancel_button.layer.cornerRadius = cancel_button.frame.height / 2
        cancel_button.clipsToBounds = true
        
        /*set the initial value for gender select*/
        gender.selectedSegmentIndex = 0
    }
    
    /*hide the keyboard when user touch somewhere out side the textfield*/
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nick_name.resignFirstResponder()
        password.resignFirstResponder()
        confirm_password.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Initial the navigation bar*/
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "只差最后一步了"
    }
    
    /*Hide keyboard when user finish editing*/
    func hideKeyboard() {
        tableView.endEditing(true)
    }

    /*Enable birthday selection*/
    @IBAction func birthday_selection(sender: AnyObject) {
        hideKeyboard()
        let datePicker = ActionSheetDatePicker(title: "请选择出生日期:", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            self.isBirthdaySelected = true
            self.selected_birthday = value as! NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.stringFromDate(self.selected_birthday)
            self.selected_birthday_button.setTitle(strDate, forState: .Normal)
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        
        
        let currentDate: NSDate = NSDate()
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar
        
        components.year = -100
        let minDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        components.year = +0
        let maxDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        datePicker.showActionSheetPicker()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        /*return the number of sections*/
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*return the number of rows*/
        switch section {
            case 0: return 3
            case 1: return 2
            case 2: return 1
            default: return 0
        }
    }
    
    /*this function will be trigered when user click submit button*/
    @IBAction func submit(sender: AnyObject) {
        
        /*setup the nickname*/
        let desStr_nick_name = self.nick_name.text! as NSString
        let num_n = desStr_nick_name.length
        
        /*Check the length of the nickname*/
        if(num_n <= 0 || num_n >= 8){
            
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_USERNAME, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        /*setup the password*/
        let desStr_password = self.password.text! as NSString
        let num_p = desStr_password.length
        
        /*check the password length*/
        if(num_p <= 7 || num_p >= 18){

            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_PASSWORD, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        
        /*check password is match or not*/
        if(password.text != confirm_password.text!){

            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_PASSWORD_NOT_MATCH, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }

        /*Check whether user has input a valid email address*/
        if(email_text.text?.isEmpty == false  && isValidEmail(email_text.text!) == false){

            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }

        /*setup alert for photo selection type menu (take photo or choose existing photo)*/
        let optionMenu = UIAlertController(title: nil, message: "上传头像", preferredStyle: .ActionSheet)
        
        /*Setup the photo picker*/
        let photoPickAction = UIAlertAction(title: "从相册中选择", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            /*initial the DKimage picker*/
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 1
            
            /*set action if user click cancel button*/
            pickerController.didCancel = { () in
                /*When user cancel the pickerController*/
            }
            
            /*set action if user do select photo*/
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                /*When user did select the images*/
                
                if(assets.count == 0){
                    self.recover_button()
                    return
                }
                
                /*photo upload*/
                let asset  = assets[0]
                
                /*Crop the image*/
                let imageCropVC = RSKImageCropViewController(image: asset.fullResolutionImage!)
                imageCropVC.cropMode = RSKImageCropMode.Square
                imageCropVC.delegate = self
                self.presentViewController(imageCropVC, animated: true, completion:nil)
                
            }
            
            /*present photo pick page*/
            self.presentViewController(pickerController, animated: true, completion:nil)
        })
        
        /*if user choose to take uew photo, this will be implemented in the future*/
        /*
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: {
        (alert: UIAlertAction!) -> Void in
        print("拍照")
        })
        */
        
        /*if user choose to cancel*/
        let NoPhotoAction = UIAlertAction(title: "暂不上传头像", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            //print("取消")
            self.hideKeyboard()
            self.cropped_image = UIImage(named: "空头像")
            self.signup()
            //self.recover_button()
        })
        
        /*if user choose to cancel*/
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("取消")
            self.recover_button()
        })
        
        /*add all actions*/
        optionMenu.addAction(photoPickAction)
        optionMenu.addAction(NoPhotoAction)
        //optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        /*present the option menu*/
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    /*do signup after pass the parse functions*/
    func signup(){
        
        /*Set up the loading screen*/
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*create new user*/
        let user = PFUser()
        user.username = phoneStringFinal
        user.password = password.text
        
        /*setup nick name*/
        user["nick_name"] = nick_name.text!

        /* set up the gender*/
        if(gender.selectedSegmentIndex == 0){
            user["gender"] = "M"
        }
        if(gender.selectedSegmentIndex == 1){
            user["gender"] = "F"
        }
        
        if(isBirthdaySelected == true){
            /*Set up the birthday*/
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.stringFromDate(selected_birthday)
            user["birthday"] = strDate
            user["birthday_data"] = selected_birthday
            user["age"] = Int(age_calc(selected_birthday))
        }else{
            
            /*If user didn't select birthday, user current date*/
            let currentDate: NSDate = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.stringFromDate(currentDate)
            user["birthday"] = strDate
            user["birthday_data"] = currentDate
            user["age"] = 0
        }
    
        /*set up the city*/
        user["city"] = "Toronto"
        
        /*Set up email*/
        if(email_text.text?.isEmpty == false){
            user.email = email_text.text!
        }
        
        /*Resize the image*/
        let size_fe = CGSizeMake(300.0,300.0)
        let imageData_t = UIImagePNGRepresentation((RBSquareImageTo((cropped_image! as UIImage), size: size_fe) as UIImage))
        let imageFile_t = PFFile (data:imageData_t!)
        user["featured_image"] = imageFile_t

        /*save the new user into Parse*/
        user.signUpInBackgroundWithBlock{(success: Bool ,error:NSError?) -> Void in
            if error == nil {
                
                /*Delete record in validation table*/
                PFCloud.callFunctionInBackground("deleteValidationRecord", withParameters: ["number":phoneStringFinal]) {
                    (response: AnyObject?, error: NSError?) -> Void in
                    
                    /*Call the function successfully*/
                    if(error == nil){
                        
                        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
                        SVProgressHUD.show()
   
                        /*Do login*/
                        PFUser.logInWithUsernameInBackground(user.username!, password: user.password!, block: { (User : PFUser?, Error: NSError?) -> Void in
                            
                            /*Call the function successfully*/
                            if(Error == nil){
                                
                                SVProgressHUD.dismiss()
                                /*Check whether user has bind the email address*/
                                if(self.email_text.text?.isEmpty == true){
                                    let alert = UIAlertController(title: "提示", message: "您的账号暂未绑定邮箱，您可以在“我的设置”中进行绑定。为了方便您更改或找回密码，请尽快绑定邮箱。", preferredStyle: UIAlertControllerStyle.Alert)
                                    let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.Default ,handler: self.go_to_main)
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }else{
                                    let alert = UIAlertController(title: "提示", message: "一封确认邮件已经发送到您的邮箱中，请您尽快查收并完成验证，如果没有收到邮件，请在“我的设置”中重新进行邮箱绑定。", preferredStyle: UIAlertControllerStyle.Alert)
                                    let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.Default ,handler: self.go_to_main )
                                    alert.addAction(action)
                                    
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            }else {
                                /*Pop up the alert*/
                                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_LOGIN_ERROR, actionButton: RETRY), animated: true, completion: nil)
                                self.recover_button()
                            }
                        })
                    }
                    else{
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        self.recover_button()
                    }
                }
            }
            else{
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_SIGNUP_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                self.recover_button()
            }
        }
    }
    
    /*Signup successful, do to main page*/
    func go_to_main(alert: UIAlertAction!){
        
        CleanUpLocalData()
        
        if(activationCode != ""){
            let params = ["activationcode": activationCode] as [NSObject:AnyObject]
            PFCloud.callFunctionInBackground("deleteActivationCodeRecord", withParameters: params) {
                (response: AnyObject?, error: NSError?) -> Void in
                activationCode = ""
                /*Request Token for RongCloud Login*/
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                appDelegate?.get_token()
                
                let home  = HomeTabViewController()
                
                /*disable the loading screen*/
                SVProgressHUD.dismiss()
                
                self.presentViewController(home, animated: true, completion: nil)
            }
        }else{
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.get_token()
            
            let home  = HomeTabViewController()
            
            /*disable the loading screen*/
            SVProgressHUD.dismiss()
            
            self.presentViewController(home, animated: true, completion: nil)
        }
    }
    
    /*Recover all buttons*/
    func recover_button(){
        /*disable loading screen*/
        SVProgressHUD.dismiss()
    }

    /*this function will be trigered when user type "cancel button"*/
    @IBAction func cancel(sender: AnyObject) {
        let alert = UIAlertController(title: ALERT, message: "亲，真的要放弃注册吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let action_cancel = UIAlertAction(title: "继续注册",style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action_cancel)
        let action_reselect = UIAlertAction(title: "放弃",style: UIAlertActionStyle.Default, handler: back_to_login)
        alert.addAction(action_reselect)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*back to login page*/
    func back_to_login (alert: UIAlertAction!) {
        let start : StartingPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("starting_page") as! StartingPageViewController
        self.presentViewController(start, animated: true, completion: nil)
    }
    
    //MARK: Image cropper delegate
    
    /*Get the cropped image*/
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        cropped_image = croppedImage
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        self.signup()
        
    }
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        recover_button()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        return
    }
}
