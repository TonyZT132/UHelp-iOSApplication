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

func CheckMessage(_ User:PFUser!, completion:@escaping (_ count:Int, _ Error:String?) -> Void){
    /*Query from Parse class*/
    let query = PFQuery(className:"personal_info_table")
    query.whereKey("TargetId", equalTo: (User.objectId)!)
    query.findObjectsInBackground {
        (objects: [PFObject]?, error: NSError?) -> Void in
        if(error == nil){
            let temp = NSMutableArray()
            //var MessageCount = 0
            for obj:AnyObject in objects!{
                temp.add(obj)
            }
            
            var Data = [NSDictionary]()
            if(temp.count > 0 && temp.firstObject?.object(forKey: "personal_info") != nil){
                Data = temp.firstObject?.object(forKey: "personal_info") as! Array
            }
            
            if(Data.count > 0){
                for i in 0 ... Data.count - 1{
                    let Dict = Data[i] as NSDictionary
                    /*Store in Local*/
                    StoreMessage(Dict)
                }
                
                /*Query from Parse class*/
                let query = PFQuery(className:"personal_info_table")
                query.whereKey("TargetId", equalTo: (PFUser.current()?.objectId)!)
                query.findObjectsInBackground {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if(error == nil){
                        let temp = NSMutableArray()
                        for obj:AnyObject in objects!{
                            temp.add(obj)
                        }
                        if(temp.count > 0){
                            query.getObjectInBackground(withId: (temp.firstObject!.objectId)!!){
                                (record: PFObject?, error: NSError?) -> Void in
                                
                                if error != nil {
                                    /*Do Reset*/
                                    NSLog(error.debugDescription)
                                    SVProgressHUD.dismiss()
                                    completion(count: -1, Error: "更新失败")
                                } else if let record = record {
                                    
                                    /*Reset after finishing store data in local*/
                                    record["personal_info"] = []
                                    record.saveInBackground(block: { (success, error) in
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
func StoreMessage(_ Data:NSDictionary) {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    let row = NSEntityDescription.insertNewObject(forEntityName: "PersonalMessage", into: context)
    
    row.setValue(Data.value(forKey: "Link"), forKey: "link")
    row.setValue(Data.value(forKey: "Target"), forKey: "user")
    row.setValue(Data.value(forKey: "From"), forKey: "from")
    row.setValue(Data.value(forKey: "Date"), forKey: "date")
    row.setValue(Data.value(forKey: "Content"), forKey: "content")
    row.setValue((Data.value(forKey: "Read") as! Bool), forKey: "read")
    
    do {
        try context.save()
    } catch let error as NSError  {
        NSLog("Could not save \(error), \(error.userInfo)")
    }
}

func CountUnreadMessage() -> Int {
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonalMessage")
    do {
        let messageArr = try managedContext.fetch(fetchRequest)
        var count = 0
        if(messageArr.isEmpty == false){
            for message in messageArr {
                let isRead = (message as AnyObject).value(forKey: "read") as! Bool
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
        UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonalMessage")
    do {
        let messageArr = try managedContext.fetch(fetchRequest)
        for message in messageArr {
            managedContext.delete(message as! NSManagedObject)
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
