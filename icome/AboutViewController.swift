//
//  AboutViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-10-14.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "关于友帮"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    @IBAction func back(sender: AnyObject) {
        let setting : SettingNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier(SETTING_NAV) as! SettingNavViewController
        self.presentViewController(setting, animated: true, completion: nil)
    }

}
