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
        followArr = PFUser.current()?.object(forKey: "follow") as! Array
        TableView.dataSource = self
        TableView.delegate = self
        TableView.reloadData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:FollowTableViewCell = TableView.dequeueReusableCell(withIdentifier: "follow", for: indexPath) as! FollowTableViewCell
        cell.FeaturedImage.layer.cornerRadius = cell.FeaturedImage.frame.height / 2
        cell.FeaturedImage.clipsToBounds = true
        
        let loadData = PFQuery(className:"_User")
        loadData.whereKey("objectId", equalTo: followArr[indexPath.row])
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.add(obj)
                }
                
                cell.Nickname.text = temp.firstObject?.object(forKey: "nick_name") as? String
                cell.City.text = temp.firstObject?.object(forKey: "city") as? String
                
                //let user = self.detail_obj.firstObject?.objectForKey("user") as! PFUser
                
                let gender_temp =  temp.firstObject?.object(forKey: "gender") as? String
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
                let userImageFile = temp.firstObject?.object(forKey: "featured_image")  as! PFFile
                userImageFile.getDataInBackground {
                    (imageData: Data?, error: NSError?) -> Void in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        
        let loadData = PFQuery(className:"_User")
        loadData.whereKey("objectId", equalTo: followArr[indexPath.row])
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.add(obj)
                }
                
                let user = temp.firstObject as! PFUser
                
                let profile : ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
                
                profile.hidesBottomBarWhenPushed = true
                profile.SelectedUser = user
                SVProgressHUD.dismiss()
                self.navigationController!.navigationBar.tintColor = UIColor.white
                self.navigationController?.pushViewController(profile, animated: true)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        /*Leave it blank*/
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction  = UITableViewRowAction(style: .default, title: "取消关注", handler: { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            
            self.followArr.remove(at: indexPath.row)
            self.updateFollower()
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        return [deleteAction]
    }
    
    func updateFollower(){
        /*Do update*/
        if let currentUser = PFUser.current(){
            currentUser["follow"] = followArr
            //currentUser.saveInBackground()
            currentUser.saveInBackground(block: { (success, error) -> Void in
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
