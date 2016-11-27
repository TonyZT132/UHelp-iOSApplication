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
            startPage.isHidden = true
        }
        self.pageImage.image = UIImage(named: imageName)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*When user click start button*/
    @IBAction func start(_ sender: AnyObject) {
        if(PFUser.current() != nil){
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.get_token()
            
            let home = HomeTabViewController()
            self.present(home, animated: true, completion: nil)
        }else{
            let start : StartingPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "starting_page") as! StartingPageViewController
            self.present(start, animated: true, completion: nil)
        }
    }
}
