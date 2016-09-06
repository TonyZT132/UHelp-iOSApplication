//
//  PersonalInfoViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-29.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse
import CoreData

class PersonalInfoViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var TableView: UITableView!
    
    /*All Info's Data*/
    var InfoData:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.delegate = self
        TableView.dataSource = self
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            self.InfoData = try managedContext.executeFetchRequest(fetchRequest)
            if(self.InfoData.count<=0){
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "未收到任何信息", actionButton: ERROR_ALERT_ACTION), animated: true, completion:
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                })
            }else{
                TableView.reloadData()
            }
        } catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "读取失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion:
            {
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.TableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InfoData.count
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personal_info_cell") as! PersonalInfoTableViewCell
        cell.selectionStyle = .None
        
        /*Get FromUser info */
        let PersonalInfoData = self.InfoData[indexPath.row] as! NSManagedObject
        
        let ReadStatus = PersonalInfoData.valueForKey("read") as! Bool
        
        if(ReadStatus == false){
            cell.Status.text = "未读"
        }else{
            cell.Status.text = "已读"
            cell.Status.textColor = UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:1.0)
        }

        let UserID = PersonalInfoData.valueForKey("from") as! String
        let query = PFQuery(className:"_User")
        
        query.getObjectInBackgroundWithId(UserID) {
            (user_info: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let user_info = user_info {
                
                cell.NickName.text = user_info.objectForKey("nick_name") as? String
                
                let userImageFile = user_info.objectForKey("featured_image")  as! PFFile
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    
                    if error == nil {
                        if let imageData = imageData {
                            cell.Featured_Image.image = UIImage(data:imageData)
                        }else{
                            NSLog("头像格式转换失败")
                        }
                    }else{
                        NSLog("头像载入失败")
                    }
                }
            }
        }
        
        cell.Content.text = PersonalInfoData.valueForKey("content") as? String
        
        /*Load Post Date*/
        let date = PersonalInfoData.valueForKey("date") as! NSDate
        
        /*Get Current Date*/
        let CurrentDate = NSDate()
        
        /*Calculate the Different between Current Date and Post Date*/
        let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date, toDate: CurrentDate, options: NSCalendarOptions.init(rawValue: 0))
        
        if(diffDateComponents.year != 0 || diffDateComponents.month != 0 || diffDateComponents.day != 0){
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.stringFromDate(date)
            cell.Date.text = strDate
        }else{
            if(diffDateComponents.hour != 0 ){
                cell.Date.text = String(diffDateComponents.hour) + "小时前"
            }else if (diffDateComponents.minute != 0){
                cell.Date.text = String(diffDateComponents.minute) + "分钟前"
            }else{
                cell.Date.text = "刚刚"
            }
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let PersonalInfoData = self.InfoData[indexPath.row] as! NSManagedObject
        PersonalInfoData.setValue(true, forKey: "read")
        do{
            let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
            detail.objectId_detail = PersonalInfoData.valueForKey("link") as! String
            detail.hidesBottomBarWhenPushed = true
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
            try PersonalInfoData.managedObjectContext?.save()
            self.navigationController?.pushViewController(detail, animated: true)
        }catch let error as NSError {
            NSLog("Could not fetch \(error), \(error.userInfo)")
        }
        
        
//        var Dict = [String:AnyObject]()
//        
//        Dict["From"] = PersonalInfoData.valueForKey("From")
//        Dict["Content"] = PersonalInfoData.valueForKey("Content")
//        Dict["Date"] = PersonalInfoData.valueForKey("Date")
//        Dict["Read"] = true
//        Dict["Link"] = PersonalInfoData.valueForKey("Link")
//        Dict["Target"] = PersonalInfoData.valueForKey("Target")
//        
//        let NSDict = Dict as NSDictionary
//        self.InfoData[indexPath.row] = NSDict
//        
//        /*Update CoreData*/
//        //self.UpdatePersonalInfo()
//        
//        self.TableView.reloadData()
//        
//        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
//        SVProgressHUD.show()
//        
//        /*Query from Parse class*/
//        let loadData = PFQuery(className:DataClass)
//        loadData.whereKey("objectId", equalTo:(PersonalInfoData.valueForKey("Link") as! String))
//        loadData.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                let temp = NSMutableArray()
//                for obj:AnyObject in objects!{
//                    temp.addObject(obj)
//                }
//                
//                /*Check whether the selected post is still exist*/
//                if(temp.count > 0){
//                    /*Direct to detail page*/
//                    SVProgressHUD.dismiss()
//                    let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
//                    //let user = home_obj[indexPath.row].objectForKey("user") as! PFUser
//                    
//                    detail.objectId_detail = PersonalInfoData.valueForKey("Link") as! String
//                    detail.hidesBottomBarWhenPushed = true
//                    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
//                    self.navigationController?.pushViewController(detail, animated: true)
//                }else{
//                    
//                    /*The post has been deleted*/
//                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
//                    SVProgressHUD.dismiss()
//                }
//                
//            } else {
//                /*Loading error*/
//                NSLog("详情页面载入失败")
//                NSLog("Error: \(error!) \(error!.userInfo)")
//                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
//                SVProgressHUD.dismiss()
//            }
//        }

    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        /*Leave it blank*/
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction  = UITableViewRowAction(style: .Default, title: "删除", handler: { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            self.InfoData.removeAtIndex(indexPath.row)
            
            /*Update coreData*/
            //self.UpdatePersonalInfo()
            
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
            do {
                let messageArr = try managedContext.executeFetchRequest(fetchRequest)
                managedContext.deleteObject(messageArr[indexPath.row] as! NSManagedObject)
                do {
                    try managedContext.save()
                    
//                    let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
//                    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
//                    let sortDescriptors = [sortDescriptor]
//                    fetchRequest.sortDescriptors = sortDescriptors
//                    do {
//                        self.InfoData = try managedContext.executeFetchRequest(fetchRequest)
//                    
//                    } catch let error as NSError {
//                        NSLog("Could not fetch \(error), \(error.userInfo)")
//                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "读取失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion:
//                            {
//                                self.navigationController?.popViewControllerAnimated(true)
//                        })
//                    }
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }

            
            
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        return [deleteAction]
    }
    
//    func UpdatePersonalInfo(){
//        /*Query from Parse class*/
//        let query = PFQuery(className:"personal_info_table")
//        query.whereKey("TargetId", equalTo: (PFUser.currentUser()?.objectId)!)
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if(error == nil){
//                let temp = NSMutableArray()
//                for obj:AnyObject in objects!{
//                    temp.addObject(obj)
//                }
//                
//                if(temp.count > 0){
//                    query.getObjectInBackgroundWithId((temp.firstObject!.objectId)!!){
//                        (record: PFObject?, error: NSError?) -> Void in
//                        
//                        if error != nil {
//                            /*Do Reset*/
//                            NSLog(error.debugDescription)
//                            
//                        } else if let record = record {
//                            record["personal_info"] = self.InfoData
//                            record.saveInBackground()
//                        }
//                    }
//                }
//            }else{
//                /*Do Reset*/
//                NSLog(error.debugDescription)
//            }
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
