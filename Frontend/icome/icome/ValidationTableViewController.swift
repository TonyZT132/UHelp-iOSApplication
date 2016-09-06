//
//  ValidationTableViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-12-31.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class ValidationTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var counting_label: UILabel!
    @IBOutlet weak var submit_button: UIButton!
    @IBOutlet weak var activation_code_text: UITextField!
    @IBOutlet weak var validation_code: UITextField!
    @IBOutlet weak var phone_num: UITextField!
    @IBOutlet weak var get_validation_code_button: UIButton!
    
    var time_count = 40
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ValidationTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        self.tableView.addGestureRecognizer(tapGesture)
        
        /*Initalize the layout*/
        activation_code_text.delegate = self
        phone_num.delegate = self
        counting_label.hidden = true
        
        phone_num.keyboardType = UIKeyboardType.PhonePad
        validation_code.keyboardType = UIKeyboardType.PhonePad
        get_validation_code_button.layer.borderWidth = 1
        get_validation_code_button.layer.borderColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        get_validation_code_button.layer.cornerRadius = 5
        
        submit_button.layer.borderWidth = 1
        submit_button.layer.borderColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        submit_button.layer.cornerRadius = submit_button.frame.height / 2
        submit_button.clipsToBounds = true
        
        counting_label.layer.borderWidth = 1
        counting_label.layer.borderColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        counting_label.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*When user start editing, reset the button*/
    func textFieldDidBeginEditing(textField: UITextField) {
        get_validation_code_button.setTitle("获取验证码", forState:.Normal)
    }
    
    /*Initial the navigation bar*/
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "注册"
        get_validation_code_button.setTitle("获取验证码", forState:.Normal)
    }
    
    /*Hide keyboard when user finish editing*/
    func hideKeyboard() {
        tableView.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0: return 2
            case 1: return 1
            default: return 0
        }
    }

    @IBAction func get_validation_code(sender: AnyObject) {
        
        self.get_validation_code_button.setTitle("获取中", forState:.Normal)
        self.get_validation_code_button.enabled = false
        
        /*Check phone number input*/
        if(self.phone_num.text == nil || self.phone_num.text! == ""){
            self.get_validation_code_button.setTitle(ERROR_EMPTY_PHONENUMBER, forState:.Normal)
            self.get_validation_code_button.enabled = true
            return
        }
        
        /*Phone number validation*/
        let Pattern = "^\\d{10}$"
        let matcher = MyRegex(Pattern)
        if (matcher.match(phone_num.text!) == false) {
            /*Incorrect cell phone number*/
            self.get_validation_code_button.setTitle(ERROR_WRONG_TYPE_CELL_PHONE, forState:.Normal)
            self.get_validation_code_button.enabled = true
        } else {
            
            /*Request validation code*/
            PFCloud.callFunctionInBackground("sendCode", withParameters: ["number":self.phone_num.text!]) {
                (response: AnyObject?, error: NSError?) -> Void in
                /*Request Success*/
                if(error == nil){
                    /*Get the code*/
                    self.presentViewController(show_alert_one_button("获取成功", message: "验证码短信发送成功", actionButton: "好的"), animated: true, completion: nil)
                    self.initial_timer()
                }
                else{
                    self.get_validation_code_button.setTitle(error?.localizedDescription, forState:.Normal)
                    self.get_validation_code_button.enabled = true
                }
            }
        }
    }

    /*After user get the code, do the validation*/
    @IBAction func submit(sender: AnyObject) {
        
        /*Check activation code input*/
        if(activation_code_text.text != nil && activation_code_text.text! != ""){
            
            /*setup the actication code*/
            let desStr_activation = self.activation_code_text.text! as NSString
            let num_p = desStr_activation.length
            
            /*check the length*/
            if(num_p < 8){
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "邀请码错误", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            
            /*Check Activation code if user input it*/
            let params = ["activationcode": activation_code_text.text!] as [NSObject:AnyObject]
            PFCloud.callFunctionInBackground("ActivationCodeValidation", withParameters: params) {
                (response: AnyObject?, error: NSError?) -> Void in
                if(error == nil){
                    let isValid  = response as! Bool
                    if(isValid){
                        activationCode = self.activation_code_text.text!
                        
                        /*Check phone number input*/
                        if(self.phone_num.text == nil || self.phone_num.text! == ""){
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_PHONENUMBER, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            return
                        }
                        
                        if(self.validation_code.text == nil || self.validation_code.text! == ""){
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "验证码不能为空", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            return
                        }
                        
                        /*Checking rhw length of the validation code*/
                        let desStr = self.validation_code.text! as NSString
                        let num = desStr.length
                        
                        if(num == 4){
                            
                            /*Enable loading screen*/
                            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
                            SVProgressHUD.show()
                            
                            /*Call validation function on Parse Cloud Code*/
                            let params = ["number": self.phone_num.text!, "code": self.validation_code.text!] as [NSObject:AnyObject]
                            PFCloud.callFunctionInBackground("codeValidation", withParameters: params) {
                                (response: AnyObject?, error: NSError?) -> Void in
                                if(error == nil){
                                    let isValid = response as! Bool
                                    if(isValid){
                                        
                                        /*Validation successful, go to signup page*/
                                        phoneStringFinal = self.phone_num.text!
                                        let sign_up : SignUpViewController = self.storyboard?.instantiateViewControllerWithIdentifier(SIGN_UP_PROFILE) as! SignUpViewController
                                        
                                        /*disable loading screen*/
                                        SVProgressHUD.dismiss()
                                        self.presentViewController(sign_up, animated: true, completion: nil)
                                    }else{
                                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_VALIDATION_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                                        
                                        /*disable loading screen*/
                                        SVProgressHUD.dismiss()
                                    }
                                }else{
                                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                                    
                                    /*disable loading screen*/
                                    SVProgressHUD.dismiss()
                                }
                            }
                        }
                        else{
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_VALIDATION_CODE, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            SVProgressHUD.dismiss()
                            return
                        }

                    }else{
                        /*Incorrect Activation Code*/
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_VALIDATION_CODE, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }else{
                    
                    /*Request Failed*/
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
            
        }else{
            //User decide not to inout activation code
            /*Check phone number input*/
            if(phone_num.text == nil || phone_num.text! == ""){
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_PHONENUMBER, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            
            if(validation_code.text == nil || validation_code.text! == ""){
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "验证码不能为空", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            
            /*Checking the length of the validation code*/
            let desStr = self.validation_code.text! as NSString
            let num = desStr.length
            
            if(num == 4){
                
                /*Enable loading screen*/
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
                SVProgressHUD.show()
                
                /*Call validation function on Parse Cloud Code*/
                let params = ["number": phone_num.text!, "code": validation_code.text!] as [NSObject:AnyObject]
                PFCloud.callFunctionInBackground("codeValidation", withParameters: params) {
                    (response: AnyObject?, error: NSError?) -> Void in
                    if(error == nil){
                        let isValid = response as! Bool
                        if(isValid){
                            
                            /*Validation success, go to sign up page*/
                            phoneStringFinal = self.phone_num.text!
                            let sign_up : SignUpViewController = self.storyboard?.instantiateViewControllerWithIdentifier(SIGN_UP_PROFILE) as! SignUpViewController
                            
                            /*disable loading screen*/
                            SVProgressHUD.dismiss()
                            self.presentViewController(sign_up, animated: true, completion: nil)
                        }else{
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_VALIDATION_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            
                            /*disable loading screen*/
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        /*disable loading screen*/
                        SVProgressHUD.dismiss()
                    }
                }
            }
            else{
                
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_VALIDATION_CODE, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                SVProgressHUD.dismiss()
                return
            }
        
        }

    }
    
    /*Initial the timer*/
    func initial_timer(){
        counting_label.hidden = false
        get_validation_code_button.hidden = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ValidationTableViewController.counting), userInfo: nil, repeats: true)
    }
    
    /*enable the timer*/
    func counting(){
        time_count = time_count - 1
        self.get_validation_code_button.setTitle("请在\(time_count)秒之后重试", forState:.Normal)
        counting_label.text = "请在\(time_count)秒之后重试"
        
        /*If counter reached 0, show the button again*/
        if(time_count == 0){
            timer.invalidate()
            time_count = 40
            self.get_validation_code_button.setTitle("获取验证码", forState:.Normal)
            self.get_validation_code_button.enabled = true
            counting_label.hidden = true
            get_validation_code_button.hidden = false
        }
    }
    
    @IBAction func back_to_start(sender: AnyObject) {
        hideKeyboard() 
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
