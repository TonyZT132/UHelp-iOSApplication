//
//  ReportViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-14.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import Parse

class ReportViewController: UIViewController {

    @IBOutlet weak var report_button: UIButton!
    //@IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var back_button: UIButton!
    @IBOutlet weak var report_content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        report_button.layer.cornerRadius = report_button.frame.height / 2
        report_button.clipsToBounds = true
        back_button.layer.cornerRadius = back_button.frame.height / 2
        back_button.clipsToBounds = true

        report_content.layer.borderColor = UIColor(red: 63.0/255.0, green: 31.0/255.0, blue: 105.0/255.0, alpha:1.0).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        report_content.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "举报"
    }
    
    func recover_button(){
        SVProgressHUD.dismiss()
    }

    /*Submit the report*/
    @IBAction func report(sender: AnyObject) {

        let report_from = PFUser.currentUser()!.username
        let content = report_content.text
        
        if(content.isEmpty == true || content == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_CONTENT, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        let desStr = content as NSString
        let num = desStr.length
        
        if(num > 500){
            let alert = UIAlertController(title: ERROR_ALERT, message:"字数过多" , preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.Default ,handler: nil )
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            recover_button()
            return
        }

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        //upload data
        let reportPost = PFObject(className:"report_table")
        reportPost["content"] = content
        reportPost["report_from"] = report_from
        reportPost["reported_user"] = reportedUser
        
        
        //upload to Parse
        reportPost.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                reportedUser = ""
                
                let alert = UIAlertController(title: ALERT_SUCCESS, message:ALERT_REPORT_RECEIVED , preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: ALERT_BACK_TO_MAIN, style: UIAlertActionStyle.Default ,handler: self.back_to_home)
                alert.addAction(action)
                
                SVProgressHUD.dismiss()
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {

                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_SEND_MESSAGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                self.recover_button()
            }
        }
    }
    
    //back to home page
    func back_to_home (alert: UIAlertAction!) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func back_to_main(sender: AnyObject) {
        reportedUser = ""
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
