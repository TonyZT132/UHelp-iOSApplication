//
//  MessageCheck.swift
//  icome
//
//  Created by Tuo Zhang on 2016-03-01.
//  Copyright © 2016 iCome. All rights reserved.
//

import Foundation
import Parse
import CoreData

func CheckMessage(User:PFUser!, completion:(count:Int, Error:String?) -> Void){
    /*Query from Parse class*/
    let query = PFQuery(className:"personal_info_table")
    query.whereKey("TargetId", equalTo: (User.objectId)!)
    query.findObjectsInBackgroundWithBlock {
        (objects: [PFObject]?, error: NSError?) -> Void in
        if(error == nil){
            let temp = NSMutableArray()
            //var MessageCount = 0
            for obj:AnyObject in objects!{
                temp.addObject(obj)
            }
            
            var Data = [NSDictionary]()
            if(temp.count > 0 && temp.firstObject?.objectForKey("personal_info") != nil){
                Data = temp.firstObject?.objectForKey("personal_info") as! Array
            }
            
            if(Data.count > 0){
                for i in 0 ... Data.count - 1{
                    let Dict = Data[i] as NSDictionary
                    /*Store in Local*/
                    StoreMessage(Dict)
                }
                
                /*Query from Parse class*/
                let query = PFQuery(className:"personal_info_table")
                query.whereKey("TargetId", equalTo: (PFUser.currentUser()?.objectId)!)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if(error == nil){
                        let temp = NSMutableArray()
                        for obj:AnyObject in objects!{
                            temp.addObject(obj)
                        }
                        if(temp.count > 0){
                            query.getObjectInBackgroundWithId((temp.firstObject!.objectId)!!){
                                (record: PFObject?, error: NSError?) -> Void in
                                
                                if error != nil {
                                    /*Do Reset*/
                                    NSLog(error.debugDescription)
                                    SVProgressHUD.dismiss()
                                    completion(count: -1, Error: "更新失败")
                                } else if let record = record {
                                    
                                    /*Reset after finishing store data in local*/
                                    record["personal_info"] = []
                                    record.saveInBackgroundWithBlock({ (success, error) in
                                        if error == nil{
                                            
                                            /*Success*/
                                            completion(count: CountUnreadMessage(), Error: nil)
                                        }else{
                                            /*Do Reset*/
                                            NSLog(error.debugDescription)
                                            SVProgressHUD.dismiss()
                                            completion(count: -1, Error: "更新失败")
                                        }
                                    })
                                }else{
                                    SVProgressHUD.dismiss()
                                    completion(count: -1, Error: "读取失败")
                                }
                            }
                        }
                    }else{
                        /*Do Reset*/
                        NSLog(error.debugDescription)
                        SVProgressHUD.dismiss()
                        completion(count: -1, Error: "读取失败")
                    }
                }
            }else{
                SVProgressHUD.dismiss()
                completion(count: CountUnreadMessage(), Error: nil)
            }
        }else{
            //error
            SVProgressHUD.dismiss()
            completion(count: -1, Error: "读取失败")
        }
    }
}

/*Receive message from server and store in local database*/
func StoreMessage(Data:NSDictionary) {
    
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let row = NSEntityDescription.insertNewObjectForEntityForName("PersonalMessage", inManagedObjectContext: context)
    
    row.setValue(Data.valueForKey("Link"), forKey: "link")
    row.setValue(Data.valueForKey("Target"), forKey: "user")
    row.setValue(Data.valueForKey("From"), forKey: "from")
    row.setValue(Data.valueForKey("Date"), forKey: "date")
    row.setValue(Data.valueForKey("Content"), forKey: "content")
    row.setValue((Data.valueForKey("Read") as! Bool), forKey: "read")
    
    do {
        try context.save()
    } catch let error as NSError  {
        NSLog("Could not save \(error), \(error.userInfo)")
    }
}

func CountUnreadMessage() -> Int {
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
    do {
        let messageArr = try managedContext.executeFetchRequest(fetchRequest)
        var count = 0
        if(messageArr.isEmpty == false){
            for message in messageArr {
                let isRead = message.valueForKey("read") as! Bool
                if(isRead == false){
                    count = count + 1
                }
            }
        }
        return count
    } catch let error as NSError {
        NSLog("Could not fetch \(error), \(error.userInfo)")
        return -1
    }
}

/*Use During Login and Logout*/
func CleanUpLocalData(){
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "PersonalMessage")
    do {
        let messageArr = try managedContext.executeFetchRequest(fetchRequest)
        for message in messageArr {
            managedContext.deleteObject(message as! NSManagedObject)
            do {
                try managedContext.save()
            } catch let error as NSError  {
                NSLog("Could not save \(error), \(error.userInfo)")
            }
        }
    } catch let error as NSError {
        NSLog("Could not fetch \(error), \(error.userInfo)")
    }
}