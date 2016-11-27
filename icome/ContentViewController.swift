//
//  ContentViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-10.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class ContentViewController: UIViewController {

    @IBOutlet weak var pageImage: UIImageView!
    @IBOutlet weak var startPage: UIButton!
    
    var imageName:String!
    var pageIndex:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPage.layer.cornerRadius = startPage.frame.height / 2
        
        if(pageIndex < 2){
            startPage.hidden = true
        }
        self.pageImage.image = UIImage(named: imageName)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*When user click start button*/
    @IBAction func start(sender: AnyObject) {
        if(PFUser.currentUser() != nil){
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.get_token()
            
            let home = HomeTabViewController()
            self.presentViewController(home, animated: true, completion: nil)
        }else{
            let start : StartingPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("starting_page") as! StartingPageViewController
            self.presentViewController(start, animated: true, completion: nil)
        }
    }
}
