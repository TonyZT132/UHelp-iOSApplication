//
//  StartingPageViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-12-19.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit

class StartingPageViewController: UIViewController {

    @IBOutlet weak var subtiitle: UILabel!
    @IBOutlet weak var login_btn: UIButton!
    @IBOutlet weak var sign_up_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Set up Buttons*/
        login_btn.layer.cornerRadius = login_btn.frame.height / 2
        login_btn.clipsToBounds = true
        login_btn.layer.borderWidth = 1
        login_btn.layer.borderColor = UIColor.white.cgColor
        sign_up_btn.layer.cornerRadius = sign_up_btn.frame.height / 2
        sign_up_btn.clipsToBounds = true
        
        /*Set up Views*/
        let TopLine = UIView(frame: CGRect(x: 0,y: 0,width: subtiitle.frame.width,height: 1))
        TopLine.layer.backgroundColor =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha:1.0).cgColor
        subtiitle.addSubview(TopLine)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    
    /*Display Login Page*/
    @IBAction func do_login(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "login", sender: self)
    }

    /*Display Signup Page*/
    @IBAction func do_singup(_ sender: AnyObject) {
        let validation : ValidationNavViewController = self.storyboard?.instantiateViewController(withIdentifier: "validation_nav") as! ValidationNavViewController
        self.present(validation, animated: true, completion: nil)
    }
}
