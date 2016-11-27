//
//  SuggestionViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-14.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class SuggestionViewController: UIViewController {

    @IBOutlet weak var suggestion_button: UIButton!
    //@IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var back_button: UIButton!
    @IBOutlet weak var suggestion_content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        suggestion_button.layer.cornerRadius = suggestion_button.frame.height / 2
        suggestion_button.clipsToBounds = true
        back_button.layer.cornerRadius = back_button.frame.height / 2
        back_button.clipsToBounds = true
        suggestion_content.layer.borderColor = UIColor(red: 63.0/255.0, green: 31.0/255.0, blue: 105.0/255.0, alpha:1.0).cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        suggestion_content.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "意见反馈"
    }
    
    func recover_button(){
        //loading.hidden = true
        //loading.stopAnimating()
        //suggestion_button.hidden = false
        //back_button.hidden = false
        SVProgressHUD.dismiss()
    }
    
    /*Submit the report*/
    @IBAction func report(_ sender: AnyObject) {
        //loading.hidden = false
        //loading.startAnimating()
        //suggestion_button.hidden = true
        //back_button.hidden = true
        
        let report_from = PFUser.current()!.username
        let content = suggestion_content.text
        
        /*Check whether the input is empty*/
        if(content?.isEmpty == true || content == ""){
            
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_CONTENT, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        let desStr = content as NSString
        let num = desStr.length
        
        /*Check if char counts greater than 500*/
        if(num > 500){
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_TOO_MANY_WORDS, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        
        //upload data
        let reportPost = PFObject(className:"suggestion_table")
        reportPost["content"] = content
        reportPost["from"] = report_from
        
        //upload to Parse
        reportPost.saveInBackground {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                //print("success")
                reportedUser = ""
                
                SVProgressHUD.dismiss()
                
                let alert = UIAlertController(title: ALERT_SUCCESS, message: ALERT_THANKS_FOR_SUGGESTION, preferredStyle: UIAlertControllerStyle.alert)
                let action_cancel = UIAlertAction(title: ALERT_BACK_TO_SETTING,style: UIAlertActionStyle.default, handler: self.back_to_setting)
                alert.addAction(action_cancel)
                self.present(alert, animated: true, completion: nil)
                
                
                
            } else {
                // There was a problem, check error.description
                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_SEND_MESSAGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                self.recover_button()
            }
        }
    }
    
    //back to setting page
    func back_to_setting (_ alert: UIAlertAction!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: AnyObject) {
       back_to_setting(nil)
    }
}
