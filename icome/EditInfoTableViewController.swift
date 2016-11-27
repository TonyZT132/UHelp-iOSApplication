//
//  EditInfoTableViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-03-06.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class EditInfoTableViewController: UITableViewController {

    @IBOutlet weak var UpdateButton: UIButton!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var selected_birthday_button: UIButton!
    
    var selected_birthday:NSDate!
    var birthday_string:String?
    var isBirthdaySelected = false
    var username:String?
    var usergender:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Gender.text = usergender!
        UserName.text = username!
        
        selected_birthday_button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        selected_birthday_button.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: UIControlState.Normal)
        self.selected_birthday_button.setTitle(birthday_string, forState: .Normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditInfoTableViewController.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        self.tableView.addGestureRecognizer(tapGesture)
        
        self.UpdateButton.layer.cornerRadius = self.UpdateButton.frame.height / 2
        self.UpdateButton.clipsToBounds = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Hide keyboard when user finish editing*/
    func hideKeyboard() {
        tableView.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0: return 2
            case 1: return 1
            default: return 0
        }
    }

    @IBAction func SelectBirthday(sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: "请选择出生日期:", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            self.isBirthdaySelected = true
            self.selected_birthday = value as! NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let strDate = dateFormatter.stringFromDate(self.selected_birthday)
            self.birthday_string = strDate
            self.selected_birthday_button.setTitle(self.birthday_string, forState: .Normal)
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        
        
        let currentDate: NSDate = NSDate()
        
        
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        // let calendar: NSCalendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone(name: "UTC")!
        
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar
        
        components.year = -100
        let minDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        components.year = +0
        let maxDate: NSDate = calendar.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        datePicker.showActionSheetPicker()
        
    }
    
    @IBAction func Update(sender: AnyObject) {
        hideKeyboard()
        if(isBirthdaySelected == true){
            /*Set up the loading screen*/
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            SVProgressHUD.show()
            
            /*Do update*/
            if let currentUser = PFUser.currentUser(){
                currentUser["birthday"] = birthday_string
                currentUser["birthday_data"] = selected_birthday
                currentUser["age"] = age_calc(selected_birthday)
                currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if(error == nil){
                        SVProgressHUD.dismiss()
                        self.navigationController?.popViewControllerAnimated(true)
                    }else{
                        NSLog("更新失败")
                        SVProgressHUD.dismiss()
                    }
                    
                })
                
            }else{
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "更新失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            }

            
        }else{
            self.presentViewController(show_alert_one_button("提示", message: "未更改任何资料", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
