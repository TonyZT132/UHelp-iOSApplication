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
    var selected_birthday:Date!
    var cropped_image: UIImage!
    var isBirthdaySelected = false
    
    // MARK: - Root view load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selected_birthday_button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        selected_birthday_button.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), for: UIControlState())
        
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
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        nick_name.resignFirstResponder()
        password.resignFirstResponder()
        confirm_password.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Initial the navigation bar*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "只差最后一步了"
    }
    
    /*Hide keyboard when user finish editing*/
    func hideKeyboard() {
        tableView.endEditing(true)
    }

    /*Enable birthday selection*/
    @IBAction func birthday_selection(_ sender: AnyObject) {
        hideKeyboard()
        let datePicker = ActionSheetDatePicker(title: "请选择出生日期:", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
            picker, value, index in
            
            self.isBirthdaySelected = true
            self.selected_birthday = value as! Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.string(from: self.selected_birthday)
            self.selected_birthday_button.setTitle(strDate, for: UIControlState())
            
            return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        
        
        let currentDate: Date = Date()
        
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        var components: DateComponents = DateComponents()
        (components as NSDateComponents).calendar = calendar
        
        components.year = -100
        let minDate: Date = (calendar as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        
        components.year = +0
        let maxDate: Date = (calendar as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        
        datePicker?.maximumDate = maxDate
        datePicker?.minimumDate = minDate
        datePicker?.show()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        /*return the number of sections*/
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*return the number of rows*/
        switch section {
            case 0: return 3
            case 1: return 2
            case 2: return 1
            default: return 0
        }
    }
    
    /*this function will be trigered when user click submit button*/
    @IBAction func submit(_ sender: AnyObject) {
        
        /*setup the nickname*/
        let desStr_nick_name = self.nick_name.text! as NSString
        let num_n = desStr_nick_name.length
        
        /*Check the length of the nickname*/
        if(num_n <= 0 || num_n >= 8){
            
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_USERNAME, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        /*setup the password*/
        let desStr_password = self.password.text! as NSString
        let num_p = desStr_password.length
        
        /*check the password length*/
        if(num_p <= 7 || num_p >= 18){

            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_PASSWORD, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        
        /*check password is match or not*/
        if(password.text != confirm_password.text!){

            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_PASSWORD_NOT_MATCH, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }

        /*Check whether user has input a valid email address*/
        if(email_text.text?.isEmpty == false  && isValidEmail(email_text.text!) == false){

            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }

        /*setup alert for photo selection type menu (take photo or choose existing photo)*/
        let optionMenu = UIAlertController(title: nil, message: "上传头像", preferredStyle: .actionSheet)
        
        /*Setup the photo picker*/
        let photoPickAction = UIAlertAction(title: "从相册中选择", style: .default, handler: {
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
                imageCropVC.cropMode = RSKImageCropMode.square
                imageCropVC.delegate = self
                self.present(imageCropVC, animated: true, completion:nil)
                
            }
            
            /*present photo pick page*/
            self.present(pickerController, animated: true, completion:nil)
        })
        
        /*if user choose to take uew photo, this will be implemented in the future*/
        /*
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: {
        (alert: UIAlertAction!) -> Void in
        print("拍照")
        })
        */
        
        /*if user choose to cancel*/
        let NoPhotoAction = UIAlertAction(title: "暂不上传头像", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //print("取消")
            self.hideKeyboard()
            self.cropped_image = UIImage(named: "空头像")
            self.signup()
            //self.recover_button()
        })
        
        /*if user choose to cancel*/
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
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
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    /*do signup after pass the parse functions*/
    func signup(){
        
        /*Set up the loading screen*/
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.string(from: selected_birthday)
            user["birthday"] = strDate
            user["birthday_data"] = selected_birthday
            user["age"] = Int(age_calc(selected_birthday))
        }else{
            
            /*If user didn't select birthday, user current date*/
            let currentDate: Date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.string(from: currentDate)
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
        let size_fe = CGSize(width: 300.0,height: 300.0)
        let imageData_t = UIImagePNGRepresentation((RBSquareImageTo((cropped_image! as UIImage), size: size_fe) as UIImage))
        let imageFile_t = PFFile (data:imageData_t!)
        user["featured_image"] = imageFile_t

        /*save the new user into Parse*/
        user.signUpInBackground{(success: Bool ,error:NSError?) -> Void in
            if error == nil {
                
                /*Delete record in validation table*/
                PFCloud.callFunction(inBackground: "deleteValidationRecord", withParameters: ["number":phoneStringFinal]) {
                    (response: AnyObject?, error: NSError?) -> Void in
                    
                    /*Call the function successfully*/
                    if(error == nil){
                        
                        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                        SVProgressHUD.show()
   
                        /*Do login*/
                        PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (User : PFUser?, Error: NSError?) -> Void in
                            
                            /*Call the function successfully*/
                            if(Error == nil){
                                
                                SVProgressHUD.dismiss()
                                /*Check whether user has bind the email address*/
                                if(self.email_text.text?.isEmpty == true){
                                    let alert = UIAlertController(title: "提示", message: "您的账号暂未绑定邮箱，您可以在“我的设置”中进行绑定。为了方便您更改或找回密码，请尽快绑定邮箱。", preferredStyle: UIAlertControllerStyle.alert)
                                    let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.default ,handler: self.go_to_main)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                }else{
                                    let alert = UIAlertController(title: "提示", message: "一封确认邮件已经发送到您的邮箱中，请您尽快查收并完成验证，如果没有收到邮件，请在“我的设置”中重新进行邮箱绑定。", preferredStyle: UIAlertControllerStyle.alert)
                                    let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.default ,handler: self.go_to_main )
                                    alert.addAction(action)
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }else {
                                /*Pop up the alert*/
                                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_LOGIN_ERROR, actionButton: RETRY), animated: true, completion: nil)
                                self.recover_button()
                            }
                        })
                    }
                    else{
                        self.present(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        self.recover_button()
                    }
                }
            }
            else{
                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_SIGNUP_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                self.recover_button()
            }
        }
    }
    
    /*Signup successful, do to main page*/
    func go_to_main(_ alert: UIAlertAction!){
        
        CleanUpLocalData()
        
        if(activationCode != ""){
            let params = ["activationcode": activationCode] as [AnyHashable: Any]
            PFCloud.callFunction(inBackground: "deleteActivationCodeRecord", withParameters: params) {
                (response: AnyObject?, error: NSError?) -> Void in
                activationCode = ""
                /*Request Token for RongCloud Login*/
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.get_token()
                
                let home  = HomeTabViewController()
                
                /*disable the loading screen*/
                SVProgressHUD.dismiss()
                
                self.present(home, animated: true, completion: nil)
            }
        }else{
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.get_token()
            
            let home  = HomeTabViewController()
            
            /*disable the loading screen*/
            SVProgressHUD.dismiss()
            
            self.present(home, animated: true, completion: nil)
        }
    }
    
    /*Recover all buttons*/
    func recover_button(){
        /*disable loading screen*/
        SVProgressHUD.dismiss()
    }

    /*this function will be trigered when user type "cancel button"*/
    @IBAction func cancel(_ sender: AnyObject) {
        let alert = UIAlertController(title: ALERT, message: "亲，真的要放弃注册吗？", preferredStyle: UIAlertControllerStyle.alert)
        let action_cancel = UIAlertAction(title: "继续注册",style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action_cancel)
        let action_reselect = UIAlertAction(title: "放弃",style: UIAlertActionStyle.default, handler: back_to_login)
        alert.addAction(action_reselect)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*back to login page*/
    func back_to_login (_ alert: UIAlertAction!) {
        let start : StartingPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "starting_page") as! StartingPageViewController
        self.present(start, animated: true, completion: nil)
    }
    
    //MARK: Image cropper delegate
    
    /*Get the cropped image*/
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        cropped_image = croppedImage
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.signup()
        
    }
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        recover_button()
        self.navigationController?.dismiss(animated: true, completion: nil)
        return
    }
}
