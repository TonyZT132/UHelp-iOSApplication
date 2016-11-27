//
//  LoginTableViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-04.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class LoginTableViewController: UITableViewController {
    
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phone_num: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*Tap listener setup*/
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        self.tableView.addGestureRecognizer(tapGesture)
        
        /*Initialize*/
        phone_num.keyboardType = UIKeyboardType.phonePad
        
        /*Set the borderline and border colr for the buttom button*/
        login_button.layer.cornerRadius = login_button.frame.height / 2
        login_button.clipsToBounds = true
    }

    /*Hide keyboard*/
    func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Set up navigation bar*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "登陆"
        SVProgressHUD.dismiss()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    /*this function will be triggered when user type login*/
    @IBAction func login_button_types(_ sender: AnyObject) {
        
        if(PFUser.current() == nil){
            log_in()
        }else{
            
            /*Shouldn't be here*/
            PFUser.logOut()
            log_in()
        }
    }
    
    /*Do login*/
    func log_in(){
        let user = PFUser()
        user.username = phone_num.text
        user.password = password.text
        
        let desStr = self.phone_num.text! as NSString
        let num = desStr.length
        
        /*Input error checking*/
        if(user.username?.isEmpty == true || user.password?.isEmpty == true){
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_INPUT, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            //recover_button()
        }
        else if (num != 10){
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_CELL_PHONE, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            //recover_button()
            SVProgressHUD.dismiss()
        }
        else{
            
            /*set up loading screen*/
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.show()
        
            /*login in Parse and create session*/
            PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: {
                (User : PFUser?, Error: NSError?) -> Void in
                if(Error == nil){
                    
                    CleanUpLocalData()
                    /*Request tiken for chatting room*/
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.get_token()
                    //category_item = 0
                    //search_by_gender = "A"
                    let home = HomeTabViewController()
                    self.present(home, animated: true, completion: nil)
                }
                else{
                    self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_LOGIN_ERROR, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    //self.recover_button()
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
 
    /*Rquest reset password*/
    @IBAction func forget_password(_ sender: AnyObject) {
        
        /*1. Create the alert controller.*/
        let alert = UIAlertController(title: "找回密码", message: "请输入手机号码以及帐号所绑定的邮箱地址", preferredStyle: .alert)

        /*. Add the text field. You can configure it however you need.*/
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "请输入手机号码"
            textField.keyboardType = UIKeyboardType.phonePad
        })
        
        /*2. Add the text field. You can configure it however you need.*/
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "请输入邮箱地址"
        })
        
        /*3. Grab the value from the text field, and print it when the user clicks OK.*/
        alert.addAction(UIAlertAction(title: "提交", style: .default, handler: { (action) -> Void in
            let username = alert.textFields![0] as UITextField
            username.keyboardType = UIKeyboardType.phonePad
            let email = alert.textFields![1] as UITextField
            
            if(username.text?.isEmpty == true || username.text! == ""){
                
                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_PHONENUMBER, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            else if(email.text?.isEmpty == true || email.text! == ""){

                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
                
            }else if(email.text?.isEmpty == false  && isValidEmail(email.text!) == false){

                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_WRONG_TYPE_EMAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                return
            }
            self.do_reset(username.text!, email: email.text!)
        }))
        
        let action_cancel = UIAlertAction(title: "返回",style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action_cancel)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        SVProgressHUD.dismiss()
        //self.recover_button()

    }
    
    func do_reset(_ username:String, email:String!){
        
        // convert the email string to lower case
        let emailToLowerCase = email.lowercased()
        // remove any whitespaces before and after the email address
        let emailClean = emailToLowerCase.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let params = ["username": username, "email": emailClean] as [AnyHashable: Any]
        PFCloud.callFunction(inBackground: "checkEmailValidation", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            if(error == nil){
                let isValid = response as! Bool
                if(isValid){
                    PFUser.requestPasswordResetForEmail(inBackground: emailClean) { (success, error) -> Void in
                        if (error == nil) {
                            /*Request success, show alert*/
                            self.present(show_alert_one_button(ALERT, message: ALERT_DO_PASSWORD_RESET_SOON, actionButton: ALERT_ACTION), animated: false, completion: nil)
                            SVProgressHUD.dismiss()
                        }else {
 
                            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_FIND_PASSWORD_FAIL, actionButton: ERROR_ALERT_ACTION), animated: false, completion: nil)
                            SVProgressHUD.dismiss()
                        }
                    }
                }else{

                    self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_VALIDATION_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    //self.recover_button()
                    SVProgressHUD.dismiss()
                }
            }else{

                self.present(show_alert_one_button(ERROR_ALERT, message: error?.localizedDescription, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                //self.recover_button()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func back_to_start(_ sender: AnyObject) {
        hideKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
}
