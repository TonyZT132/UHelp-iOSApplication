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

        report_content.layer.borderColor = UIColor(red: 63.0/255.0, green: 31.0/255.0, blue: 105.0/255.0, alpha:1.0).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        report_content.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "举报"
    }
    
    func recover_button(){
        SVProgressHUD.dismiss()
    }

    /*Submit the report*/
    @IBAction func report(_ sender: AnyObject) {

        let report_from = PFUser.current()!.username
        let content = report_content.text
        
        if(content?.isEmpty == true || content == ""){
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_CONTENT, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            recover_button()
            return
        }
        
        let desStr = content as NSString
        let num = desStr.length
        
        if(num > 500){
            let alert = UIAlertController(title: ERROR_ALERT, message:"字数过多" , preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: ERROR_ALERT_ACTION, style: UIAlertActionStyle.default ,handler: nil )
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            recover_button()
            return
        }

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        
        //upload data
        let reportPost = PFObject(className:"report_table")
        reportPost["content"] = content
        reportPost["report_from"] = report_from
        reportPost["reported_user"] = reportedUser
        
        
        //upload to Parse
        reportPost.saveInBackground {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                reportedUser = ""
                
                let alert = UIAlertController(title: ALERT_SUCCESS, message:ALERT_REPORT_RECEIVED , preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: ALERT_BACK_TO_MAIN, style: UIAlertActionStyle.default ,handler: self.back_to_home)
                alert.addAction(action)
                
                SVProgressHUD.dismiss()
                self.present(alert, animated: true, completion: nil)
                
            } else {

                self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_SEND_MESSAGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                self.recover_button()
            }
        }
    }
    
    //back to home page
    func back_to_home (_ alert: UIAlertAction!) {

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back_to_main(_ sender: AnyObject) {
        reportedUser = ""
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
