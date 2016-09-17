//
//  FollowViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-19.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class FollowViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var TableView: UITableView!
    var followArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        GetData()

        // Do any additional setup after loading the view.
    }
    
    func GetData() {
        followArr = PFUser.currentUser()?.objectForKey("follow") as! Array
        TableView.dataSource = self
        TableView.delegate = self
        TableView.reloadData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followArr.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:FollowTableViewCell = TableView.dequeueReusableCellWithIdentifier("follow", forIndexPath: indexPath) as! FollowTableViewCell
        cell.FeaturedImage.layer.cornerRadius = cell.FeaturedImage.frame.height / 2
        cell.FeaturedImage.clipsToBounds = true
        
        let loadData = PFQuery(className:"_User")
        loadData.whereKey("objectId", equalTo: followArr[indexPath.row])
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                
                cell.Nickname.text = temp.firstObject?.objectForKey("nick_name") as? String
                cell.City.text = temp.firstObject?.objectForKey("city") as? String
                
                //let user = self.detail_obj.firstObject?.objectForKey("user") as! PFUser
                
                let gender_temp =  temp.firstObject?.objectForKey("gender") as? String
                if(gender_temp != nil){
                    if (gender_temp == "M"){
                        cell.GenderImage.image = UIImage(named: "性别男")
                    }
                    else if (gender_temp == "F"){
                        cell.GenderImage.image = UIImage(named: "性别女")
                    }else{
                        /*Should Never Reach Here!*/
                        NSLog("出现未知错误")
                    }
                }
                
                //load image
                let userImageFile = temp.firstObject?.objectForKey("featured_image")  as! PFFile
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.FeaturedImage.image = UIImage(data:imageData)
                        }else{
                            NSLog("头像格式转换失败")
                        }
                    }else{
                        NSLog("头像载入失败")
                    }
                }
            }
        
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        let loadData = PFQuery(className:"_User")
        loadData.whereKey("objectId", equalTo: followArr[indexPath.row])
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                
                let user = temp.firstObject as! PFUser
                
                let profile : ProfileViewController = self.storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
                
                profile.hidesBottomBarWhenPushed = true
                profile.SelectedUser = user
                SVProgressHUD.dismiss()
                self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.pushViewController(profile, animated: true)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        /*Leave it blank*/
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction  = UITableViewRowAction(style: .Default, title: "取消关注", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            self.followArr.removeAtIndex(indexPath.row)
            self.updateFollower()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        return [deleteAction]
    }
    
    func updateFollower(){
        /*Do update*/
        if let currentUser = PFUser.currentUser(){
            currentUser["follow"] = followArr
            //currentUser.saveInBackground()
            currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                if(error == nil){
                    NSLog("更新成功")
                }else{
                    NSLog("更新失败")
                }
            })
        }else{
            NSLog("出现未知错误")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
