//
//  DetailViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-13.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController,RCIMUserInfoDataSource, UITableViewDataSource, UITableViewDelegate,UITextViewDelegate  {
    
    @IBOutlet weak var KeyboardView: UIView!
    @IBOutlet weak var Comment_Submit: UIButton!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var CommentCount: UILabel!
    @IBOutlet weak var FeaturedImage: UIImageView!
    @IBOutlet weak var ViewCount: UILabel!
    @IBOutlet weak var ViewCountImage: UIImageView!
    @IBOutlet weak var GenderImage: UIImageView!
    @IBOutlet weak var Bottom_layout: NSLayoutConstraint!
    @IBOutlet weak var City: UILabel!
    @IBOutlet weak var NickName: UILabel!
    @IBOutlet weak var FollowButton: UIButton!
    @IBOutlet weak var BookButton: UIButton!
    @IBOutlet weak var Report_Button: UIBarButtonItem!
    @IBOutlet weak var CommentButton: UIButton!
    
    /*Entire ScrollView Height*/
    var ScrollViewHeight:CGFloat = 0
    
    /*Screen Width*/
    let WIDTH = UIScreen.mainScreen().bounds.width
    
    /*Follow Flag*/
    var isFollowed = false
    
    var detail_obj:NSMutableArray = NSMutableArray()
    var ImageViewArr = [UIButton]()
    var full_image_arr = [PFFile]()
    var objectId_detail = ""
    var selected_nick_name = ""
    
    /*Detail Page Height Without Comment Table*/
    var DetailViewHeight:CGFloat = 0
    
    /*All Comment's Data*/
    var CommentData:[AnyObject] = []
    
    /*ToUser*/
    var RepliedUser:PFUser?
    var RepliedUser_Name:String?
    
    var HostUserId:String?
    
    /*Mode Flag*/
    var ReplyMode = false
    var DeleteMode = false
    
    /*Comment Verification Flag*/
    var canSubmit = false
    
    /*Comment TableView Height*/
    var TableViewHeight:CGFloat = 0
    
    /*Comment TextView*/
    var CommentTextView:KMPlaceholderTextView?
    
    /*Commetn TableView*/
    var CommentTableView : UITableView?
    
    /*Label Comment Popup TextView*/
    var CommentTitleLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommentTextView = KMPlaceholderTextView(frame: CGRectMake(20, 40, WIDTH - 40, 60))
        CommentTextView!.layer.backgroundColor = UIColor.whiteColor().CGColor
        CommentTextView!.placeholder = "请输入留言内容"
        CommentTextView?.font = UIFont.systemFontOfSize(16)
        CommentTextView!.layer.cornerRadius = 3
        CommentTextView!.clipsToBounds = true
        CommentTextView?.delegate = self
        KeyboardView.addSubview(CommentTextView!)
        BookButton.hidden = true
        FollowButton.hidden = true
        FeaturedImage.layer.cornerRadius = FeaturedImage.frame.size.height/2
        FeaturedImage.clipsToBounds = true
        
        self.CommentButton.setTitle("留言", forState: .Normal)
        self.CommentButton.backgroundColor = UIColor.whiteColor()
        self.CommentButton.layer.cornerRadius = self.CommentButton.frame.height / 2
        self.CommentButton.clipsToBounds = true
        self.CommentButton.layer.borderWidth = 1
        self.CommentButton.layer.borderColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        
        /*Load Data*/
        loadData()
        
        /*Add one view count*/
        PFCloud.callFunctionInBackground("AddCount_Home", withParameters: ["objectid":objectId_detail])
    }
    
    override func viewWillAppear(animated: Bool) {
        KeyboardView.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DetailViewController.keyBoardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DetailViewController.keyBoardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /*Load data*/
    func loadData(){
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("objectId", equalTo:objectId_detail)
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                for obj:AnyObject in objects!{
                    self.detail_obj.addObject(obj)
                }
                
                if(self.detail_obj.firstObject?.objectForKey("view_count") != nil){
                    let count = self.detail_obj.firstObject?.objectForKey("view_count") as! Int
                    self.ViewCount.text = String(count)
                    
                }else{
                    self.ViewCount.text = "0"
                }
                
                
                self.City.text = (self.detail_obj.firstObject?.objectForKey("city") as! String) + " / " + (self.detail_obj.firstObject?.objectForKey("category") as! String)
                
                let user = self.detail_obj.firstObject?.objectForKey("user") as! PFUser
                self.HostUserId = user.objectId
                
                if((self.detail_obj.firstObject?.objectForKey("gender") as! String) == "F"){
                    self.FollowButton.setTitle("关注她", forState: .Normal)
                    self.BookButton.setTitle("联系她", forState: .Normal)
                }else{
                    self.FollowButton.setTitle("关注他", forState: .Normal)
                    self.BookButton.setTitle("联系他", forState: .Normal)
                }
                
                if(self.detail_obj.firstObject?.objectForKey("comments") != nil){
                    self.CommentData = self.detail_obj.firstObject?.objectForKey("comments") as! Array
                    self.CommentCount.text = String(self.CommentData.count)
                }else{
                    self.CommentCount.text = "0"
                }
                
                /*Check whether this person is followed by the user*/
                self.check_follower()
                
                self.FollowButton.layer.cornerRadius = self.FollowButton.frame.height / 2
                self.FollowButton.clipsToBounds = true
                self.BookButton.layer.cornerRadius = self.BookButton.frame.height / 2
                self.BookButton.clipsToBounds = true
                self.BookButton.layer.borderWidth = 1
                self.BookButton.layer.borderColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
                
                if(user.objectId == PFUser.currentUser()?.objectId){
                    self.FollowButton.hidden = true
                    self.BookButton.hidden = true
                }else{
                    self.BookButton.hidden = false
                }
                
                self.ViewCountImage.image = UIImage(named: "点击数")
                self.full_image_arr = self.detail_obj.firstObject!.objectForKey("full_image") as! Array
                self.updateView()
                
                self.NickName.text = user.objectForKey("nick_name") as? String
                let gender_temp = user.objectForKey("gender") as? String
                if(gender_temp != nil){
                    if (gender_temp == "M"){
                        self.GenderImage.image = UIImage(named: "性别男")
                    }
                    else if (gender_temp == "F"){
                        self.GenderImage.image = UIImage(named: "性别女")
                    }else{
                        /*Should Never Reach Here!*/
                        NSLog("出现未知错误")
                    }
                }
                
                let userImageFile = user.objectForKey("featured_image")  as! PFFile
                
                //print(userImageFile)
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            self.FeaturedImage.image = UIImage(data:imageData)
                            
                        }else{
                            NSLog("头像格式转换失败")
                        }
                    }else{
                        NSLog("头像载入失败")
                    }
                }
            } else {
                // Log details of the failure
                NSLog("详情页面载入失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        /*Update Count*/
        PFCloud.callFunctionInBackground("AddCount_Home", withParameters: ["objectid":objectId_detail, "tablename": dataClass])
    }

    /*Update the Scroll view*/
    func updateView(){
        
        let TopViewWidth = WIDTH - 34
        let TitleLabelHeight = CGFloat(14)
        let SkillTitleLabelHeight = CGFloat(14)
        
        let CateLabel = UILabel(frame : CGRectMake(10, 10, TopViewWidth/2 - 10, TitleLabelHeight))
        let PriceLabel = UILabel(frame : CGRectMake(TopViewWidth/2, 10, TopViewWidth/2 - 10, TitleLabelHeight))
        
        CateLabel.text = self.detail_obj.firstObject!.objectForKey("title") as? String
        CateLabel.textAlignment = .Left
        CateLabel.font = UIFont.systemFontOfSize(14)
        PriceLabel.text = "$" + (self.detail_obj.firstObject!.objectForKey("price") as? String)! + "/" + (self.detail_obj.firstObject!.objectForKey("unit") as? String)!
        PriceLabel.textAlignment = .Right
        PriceLabel.font = UIFont.systemFontOfSize(14)
        
        let SkillNameLabel = UILabel(frame : CGRectMake(10, 20 + CateLabel.frame.height , TopViewWidth/2 - 10, SkillTitleLabelHeight))
        SkillNameLabel.text = "技能描述"
        SkillNameLabel.textAlignment = .Left
        SkillNameLabel.font = UIFont.systemFontOfSize(12)
        SkillNameLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        let skill_text = self.detail_obj.firstObject!.objectForKey("skill") as? String
        let skill_line_hight = CGFloat(getStringHeight(skill_text!, fontSize: 12, width: TopViewWidth - 18))
        let skill_line = Int(skill_line_hight/12)
        let Skill = UILabel(frame: CGRectMake(10, 34 + SkillNameLabel.frame.height + 5, TopViewWidth - 18, skill_line_hight))
        Skill.text = skill_text
        Skill.textColor = UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:1.0)
        Skill.font = UIFont.systemFontOfSize(12)
        Skill.lineBreakMode = .ByWordWrapping
        Skill.numberOfLines = skill_line + 1
        
        let temp = CGFloat(30 + CateLabel.frame.height + SkillTitleLabelHeight + skill_line_hight)
        
        let ServiceNameLabel = UILabel(frame : CGRectMake(10, temp + 5 , TopViewWidth/2 - 10, SkillTitleLabelHeight))
        
        ServiceNameLabel.text = "服务描述"
        ServiceNameLabel.textAlignment = .Left
        ServiceNameLabel.font = UIFont.systemFontOfSize(12)
        ServiceNameLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        let des = detail_obj.firstObject?.objectForKey("description") as! String
        
        let line_hight = CGFloat(getStringHeight(des, fontSize: 12, width: TopViewWidth - 18))
        let description_line = Int(line_hight/12)
        let DescriptionViewHeight = line_hight
        let Description = UILabel(frame: CGRectMake(10, temp + ServiceNameLabel.frame.height + 10 ,TopViewWidth - 18, DescriptionViewHeight))
        
        Description.text = des
        Description.textColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:1.0)
        Description.font = UIFont.systemFontOfSize(12)
        Description.lineBreakMode = .ByWordWrapping
        Description.numberOfLines = description_line + 1
        
        let TopLine = UIView(frame: CGRectMake(10, 15 + CateLabel.frame.height ,TopViewWidth - 20 ,0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.3).CGColor
        
        let TopViewHeight = CGFloat(temp + 15 + DescriptionViewHeight + ServiceNameLabel.frame.height)
        let TopView = UIView(frame: CGRectMake((WIDTH - TopViewWidth) / 2, 10, TopViewWidth, TopViewHeight))
        TopView.layer.backgroundColor = UIColor.greenColor().CGColor
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = TopView.frame
        rectShape.position = TopView.center
        rectShape.path = UIBezierPath(roundedRect: TopView.bounds, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], cornerRadii: CGSize(width: 7, height: 7)).CGPath
        
        TopView.layer.backgroundColor = UIColor.whiteColor().CGColor
        TopView.layer.mask = rectShape
        
        TopView.addSubview(CateLabel)
        TopView.addSubview(PriceLabel)
        TopView.addSubview(SkillNameLabel)
        TopView.addSubview(ServiceNameLabel)
        TopView.addSubview(Description)
        TopView.addSubview(Skill)
        TopView.addSubview(TopLine)
        ScrollView.addSubview(TopView)
        
        let ImageViewWidth = TopViewWidth
        var ImageListHeight = TopViewHeight + 10
        
        var image_size_arr = [NSDictionary]()
        image_size_arr = self.detail_obj.firstObject!.objectForKey("image_size") as! Array
        
        for i in 0 ... image_size_arr.count - 1{
            /*Gap for Image*/
            ImageListHeight += 5
            let ImageHeight = CGFloat(getImageHeight(image_size_arr[i], image_width: ImageViewWidth))
            
            
            let FullImage = UIButton(frame: CGRectMake((WIDTH - TopViewWidth) / 2, ImageListHeight, ImageViewWidth, ImageHeight))
            
            FullImage.setImage(UIImage(named: "载入中"), forState: .Normal)
            
            ImageViewArr.append(FullImage)
            FullImage.tag = i
            FullImage.addTarget(self, action: #selector(DetailViewController.selected(_:)), forControlEvents: .TouchUpInside)
            ImageListHeight += ImageHeight
            ScrollView.addSubview(FullImage)
        }
        
        for i in 0 ... ImageViewArr.count - 1 {
            LoadImage(i)
        }
        
        ScrollViewHeight += ImageListHeight
        
        /*Add commment table here*/
        let CommentWidget = UIView(frame: CGRectMake(0, ScrollViewHeight, WIDTH , 40))
        CommentWidget.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        CommentTitleLabel = UILabel(frame:CGRectMake(15,0, CommentWidget.frame.width - 30 ,CommentWidget.frame.height))
        
        CommentTitleLabel!.text = "留言板（\(self.CommentData.count)）"
        
        CommentTitleLabel!.textAlignment = .Left
        CommentTitleLabel!.font = UIFont.systemFontOfSize(14)
        let BotLine = UIView(frame: CGRectMake(0,CommentWidget.frame.height - 0.5 ,CommentWidget.frame.width ,0.5))
        BotLine.layer.backgroundColor =  UIColor.blackColor().CGColor
        CommentWidget.addSubview(CommentTitleLabel!)
        CommentWidget.addSubview(BotLine)
        ScrollViewHeight += CommentWidget.frame.height
        ScrollView.addSubview(CommentWidget)
        
        DetailViewHeight = ScrollViewHeight
        
        if(CommentData.count > 0){
           LoadCommentTable()
        }else{
            ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
        }
    }
    
    /*Load the full image*/
    func LoadImage(index:Int){
        let ImageFile = full_image_arr[index]
        ImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.ImageViewArr[index].setImage(UIImage(data:imageData), forState: .Normal)
                }else{
                    NSLog("详情页图片格式转换失败")
                }
            }else{
                NSLog("详情页图片载入失败")
            }
        }
    }
    
    /*Get the full image size*/
    func getImageHeight(size:NSDictionary , image_width:CGFloat) -> Double {
        
        let image_size = size
        let height = image_size["height"] as! CGFloat
        let width = image_size["width"] as! CGFloat
        let index = Double(height/width)
        let Height = Double(image_width) * index
        return Height
    }
    
    /*When user select the full image*/
    func selected (sender: UIButton!) {
        let userImageFile = full_image_arr[sender.tag] 
        let fullImage : FullImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("full_image") as! FullImageViewController
        fullImage.imageFile = userImageFile
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(fullImage, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Calculate the question label height based on the question string*/
    func getStringHeight(mytext: String, fontSize: CGFloat, width: CGFloat)->CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSizeMake(width,CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        let text = mytext as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    /*This function will be triggered when user*/
    @IBAction func book_tapped(sender: AnyObject) {
        
        let user = detail_obj[0].objectForKey("user") as! PFUser
        usernameTarget = user.objectForKey("username") as? String
        nicknameTarget = user.objectForKey("nick_name") as? String
        
        let conv : ConversationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("conversation") as! ConversationViewController
        
        self.navigationController?.pushViewController(conv, animated: true)
    }
    
    /*Get user info for the priviate conversation*/
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        let userInfo = RCUserInfo()
        userInfo.userId = userId
        userInfo.name = "友帮用户"
        
        let loadAllData:PFQuery = PFQuery(className: "_User")
        loadAllData.whereKey("username", equalTo:userId)
        loadAllData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let temp = NSMutableArray()
                // Do something with the found objects
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                userInfo.name = temp.firstObject!.objectForKey("nick_name") as? String
                let image_file = temp.firstObject!.objectForKey("featured_image") as? PFFile
                userInfo.portraitUri = image_file?.url
                completion(userInfo)
            } else {
                // Log details of the failure
                NSLog("数据载入")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    /*Check whether the current person is followed by the user*/
    func check_follower(){
        var follower_arr:[String] = [String]()
        if(PFUser.currentUser()?.objectForKey("follow") != nil){
            follower_arr = PFUser.currentUser()?.objectForKey("follow") as! Array
            
            let user = detail_obj.firstObject!.objectForKey("user") as! PFUser
            let id_temp = user.objectId
            for id in follower_arr {
                if (id == (id_temp!)){
                    isFollowed = true
                    FollowButton.setTitle("已关注", forState: .Normal)
                    FollowButton.backgroundColor = UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:1.0)
                }
            }
        }else{
            NSLog("not found, list is undefined")
        }
        self.FollowButton.hidden = false
    }
    
    /*This function will be triggered when user touch report button*/
    @IBAction func report(sender: AnyObject) {
        let report : ReportNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier(REPORT_NAV) as! ReportNavViewController
        
        let user = detail_obj[0].objectForKey("user") as! PFUser
        
        reportedUser = (user.objectForKey("username") as? String)!
        self.presentViewController(report, animated: true, completion: nil)
    }
    
    /*When user click the follow button*/
    @IBAction func follow(sender: AnyObject) {
        
        if(isFollowed == false){
            add_follower()
            isFollowed = true
            check_follower()
        }
    }
    
    /*Add the current person to user's follow list*/
    func add_follower(){
        
        var follower_arr = [String]()
        if(PFUser.currentUser()?.objectForKey("follow") != nil){
            follower_arr = PFUser.currentUser()?.objectForKey("follow") as! Array
        }
        let user = detail_obj.firstObject!.objectForKey("user") as! PFUser
        let id = user.objectId
        follower_arr.append(id!)
        
        if let currentUser = PFUser.currentUser(){
            currentUser["follow"] = follower_arr
            currentUser.saveInBackground()
        }
    }
    
    
    //MARK: TableView: Comment Table
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CommentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment_cell") as! CommentTableViewCell
        cell.selectionStyle = .None
        
        cell.Featured_Image.layer.cornerRadius = cell.Featured_Image.frame.height / 2
        cell.clipsToBounds = true
        
        /*Get FromUser info */
        let CommentItemData = self.CommentData[indexPath.row] as! NSDictionary
        let FromUser = CommentItemData["From"] as! PFUser
        let queryfrom = PFQuery(className:"_User")
        
        queryfrom.getObjectInBackgroundWithId(FromUser.objectId!) {
            (user_from: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let user_from = user_from {
                
                /*Define ToUser*/
                var ToUser:PFUser?
                let CommentItemDataInside = self.CommentData[indexPath.row] as! NSDictionary
                ToUser = CommentItemDataInside["To"] as? PFUser
                
                if(ToUser != nil){
                    /*This is a Reply Comment, Load Both FromUser and ToUser Names*/
                    cell.Usernames.text = (user_from.objectForKey("nick_name") as? String)! + " 回复 " + (CommentItemDataInside["To_Name"] as? String)!
                    ToUser = nil
                }else{
                    
                    /*Load From User Only*/
                    cell.Usernames.text = user_from.objectForKey("nick_name") as? String
                }
                
                let userImageFile = user_from.objectForKey("featured_image")  as! PFFile
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
        
        /*Load Comment Content*/
        cell.Content.text = CommentItemData["Content"] as? String
        
        /*Load Post Date*/
        let date = CommentItemData["Date"] as! NSDate
        
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
        
        /*Get ToUser Info*/
        let CommentItemData = CommentData[indexPath.row] as! NSDictionary
        RepliedUser = CommentItemData["From"] as? PFUser
        RepliedUser_Name = CommentItemData["From_Name"] as? String
        
        if(RepliedUser != PFUser.currentUser()){
            
            /*If the ToUser is not the CurrentUser, enable Reply Mode*/
            ReplyMode = true
            CommentTextView!.placeholder = "回复\(RepliedUser_Name!)"
            self.Comment_Submit.setTitleColor(UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha:1.0), forState: .Normal)
            CommentTextView?.becomeFirstResponder()
        }else{
            
            /*If the ToUser is the CurrentUser, Enable Delete Mode*/
            DeleteMode = true
            let optionMenu = UIAlertController(title: nil, message: "是否删除回复", preferredStyle: .ActionSheet)
            let DeleteAction = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.CommentData.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                self.UpdateComments()
            })
            let CancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(DeleteAction)
            optionMenu.addAction(CancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    //MARK: Keyboard Handler
    
    func keyBoardWillShow(note:NSNotification)
    {
        KeyboardView.hidden = false
        let userInfo  = note.userInfo!
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        var _ = self.view.convertRect(keyBoardBounds, toView:nil)
        var _ = KeyboardView.frame
        let deltaY = keyBoardBounds.size.height
        let animations:(() -> Void) = {
            self.KeyboardView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    func keyBoardWillHide(note:NSNotification)
    {
        let userInfo = note.userInfo!
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations:(() -> Void) = {
            self.KeyboardView.transform = CGAffineTransformIdentity
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
        KeyboardView.hidden = true
    }

    
    //MARK: Comment Controll
    
    /*When User Click Comment Button*/
    @IBAction func post_comment(sender: AnyObject) {
        ReplyMode = false
        CommentTextView!.placeholder = "请输入留言内容"
        RepliedUser = nil
        self.Comment_Submit.setTitleColor(UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha:1.0), forState: .Normal)
        CommentTextView?.becomeFirstResponder()
    }
    
    @IBAction func cancel_comment(sender: AnyObject) {
        CommentTextView?.resignFirstResponder()
    }
    
    @IBAction func submit_comment(sender: AnyObject) {
        
        /*Safety Check, block empty post*/
        if(CommentTextView?.text == nil || CommentTextView?.text == ""){
            return
        }
        
        /*If the comment is valid, do submit*/
        if(canSubmit == true){
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            SVProgressHUD.show()
        
            var CommentInfo = [String : AnyObject]()
            CommentInfo["From"] = PFUser.currentUser()!
            CommentInfo["From_Name"] = PFUser.currentUser()!.objectForKey("nick_name")
        
            if(RepliedUser != nil){
                
                /*Generate Personal Message for the Replied User*/
                CommentInfo["To"] = RepliedUser
                CommentInfo["To_Name"] = RepliedUser_Name
                var InfoData = [String:AnyObject]()
                InfoData["From"] = PFUser.currentUser()!.objectId!
                InfoData["Content"] = "回复了您"
                InfoData["Date"] = NSDate()
                InfoData["Read"] = false
                InfoData["Link"] = objectId_detail
                InfoData["Target"] = RepliedUser!.objectId!
                
                let Info = InfoData as NSDictionary
                self.Generate_Info(RepliedUser!.objectId!,Dict: Info)
                RepliedUser = nil
                
            }else{
                CommentInfo["To"] = nil
                CommentInfo["To_Name"] = nil
                
                var InfoData = [String:AnyObject]()
                InfoData["From"] = PFUser.currentUser()!.objectId!
                InfoData["Content"] = "评论了您"
                InfoData["Date"] = NSDate()
                InfoData["Read"] = false
                InfoData["Link"] = objectId_detail
                InfoData["Target"] = HostUserId!
                
                let Info = InfoData as NSDictionary
                self.Generate_Info(HostUserId!,Dict: Info)
            }
            CommentInfo["Content"] = CommentTextView?.text
            CommentInfo["Date"] = NSDate()
            
            let CommetnInfo_Data = CommentInfo as NSDictionary
            CommentData.insert(CommetnInfo_Data, atIndex: 0)
            //CommentData.append(CommetnInfo_Data)
            
            /*Update Comment Table*/
            UpdateComments()
        }
    }
    
    func Generate_Info(Target:String, Dict:NSDictionary){
        let query = PFQuery(className:"personal_info_table")
        query.whereKey("TargetId", equalTo: Target)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if(error == nil){
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                if(temp.count > 0){
                    var info = [NSDictionary]()
                    info = temp.firstObject!.objectForKey("personal_info") as! Array
                    info.insert(Dict, atIndex: 0)
                    
                    query.getObjectInBackgroundWithId((temp.firstObject!.objectId)!!){
                        (record: PFObject?, error: NSError?) -> Void in
                        
                        if error != nil {
                            /*Do Reset*/
                            NSLog(error.debugDescription)
                            
                        } else if let record = record {
                            record["personal_info"] = info
                            record.saveInBackground()
                        }
                    }
                }else{
                    /*upload data*/
                    let newRecord = PFObject(className:"personal_info_table")
                    newRecord["TargetId"] = Target
                    var info = [NSDictionary]()
                    info.append(Dict)
                    newRecord["personal_info"] = info
                    newRecord.saveInBackground()
                }
            }else{
                NSLog(error.debugDescription)
            }
        }
    }
    
    /*Update Comment Table*/
    func UpdateComments(){
        let query = PFQuery(className:dataClass)
        query.getObjectInBackgroundWithId(detail_obj.firstObject!.objectId!!) {
            (detail: PFObject?, error: NSError?) -> Void in
            if error != nil {
                /*Do Reset*/
                NSLog(error.debugDescription)
                SVProgressHUD.dismiss()
                self.CommentTextView?.text = ""
                self.CommentTextView?.resignFirstResponder()
            
            } else if let detail = detail {
                /*Do Update*/
                detail["comments"] = self.CommentData
                detail["comments_count"] = self.CommentData.count
                detail.saveInBackground()
                self.ReloadTableVIew()
            }
        }
    }
    
    func ReloadTableVIew(){
        
        self.CommentTextView?.text = ""
        self.CommentTextView?.resignFirstResponder()
        SVProgressHUD.dismiss()
        
        /*Update Count*/
        self.CommentTitleLabel!.text = "留言板（\(self.CommentData.count)）"
        self.CommentCount.text = String(self.CommentData.count)
        
        /*Reload TableView*/
        if(DeleteMode == false){
            self.LoadCommentTable()
        }else{
            self.LoadCommentTableDeleteMode()
            DeleteMode = false
        }
        
        
    }
    
    func LoadCommentTableDeleteMode(){
        /*Reset the ScrollViewHeight*/
        ScrollViewHeight = DetailViewHeight
        CommentTableView!.reloadData()
        
        /*Calculate the real cell height*/
        for cell in (CommentTableView?.visibleCells)! {
            TableViewHeight += cell.frame.height
        }
        
        /*Reset Table Size*/
        CommentTableView!.frame = CGRectMake(0, ScrollViewHeight, WIDTH , TableViewHeight + 10)
        ScrollViewHeight += CommentTableView!.frame.height
        //ScrollView.addSubview(CommentTableView!)
        ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
        CommentTableView!.reloadData()
        TableViewHeight = 0
    }
    
    
    func LoadCommentTable(){
        
        /*Reset the ScrollViewHeight*/
        ScrollView.contentSize = CGSize(width: WIDTH, height: DetailViewHeight)
        ScrollViewHeight = DetailViewHeight
        
        /*If TableView is not nil, free TableView*/
        if(CommentTableView != nil){
            CommentTableView?.removeFromSuperview()
        }
        CommentTableView = nil
        
        /*Add Table*/
        CommentTableView = UITableView()
        
        /*Initialize*/
        CommentTableView!.dataSource = self
        CommentTableView!.delegate = self
        CommentTableView!.estimatedRowHeight = 150
        CommentTableView!.rowHeight = UITableViewAutomaticDimension
        
        /*Set Table size with estimated data*/
        CommentTableView!.frame = CGRectMake(0, ScrollViewHeight, WIDTH , CGFloat(150 * CommentData.count))
        CommentTableView!.backgroundColor = UIColor.whiteColor()
        CommentTableView!.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "comment_cell")
        CommentTableView?.scrollEnabled = false
        CommentTableView!.reloadData()
        
        /*Calculate the real cell height*/
        for cell in (CommentTableView?.visibleCells)! {
            TableViewHeight += cell.frame.height
        }
        
        /*Reset Table Size*/
        CommentTableView!.frame = CGRectMake(0, ScrollViewHeight, WIDTH , TableViewHeight + 10)
        ScrollViewHeight += CommentTableView!.frame.height
        ScrollView.addSubview(CommentTableView!)
        ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
        CommentTableView!.reloadData()
        TableViewHeight = 0
    }
    
    /*Scroll to Bottom*/
    func SetPosition(){
        let bottomOffset = CGPointMake(0, self.ScrollView.contentSize.height - self.TableViewHeight);
        
        //print(bottomOffset)
        self.ScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    //MARK: Comment TextView
    
    /*Text view listener*/
    func textViewDidChange(textView: UITextView) {
        let desStr = self.CommentTextView!.text as NSString
        let num = desStr.length
        if (num >= 100 || num < 1) {
            if(num>=100){
                self.Comment_Submit.setTitle("字数过多", forState: .Normal)
            }else{
                self.Comment_Submit.setTitle("发送", forState: .Normal)
            }
            self.Comment_Submit.setTitleColor(UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha:1.0), forState: .Normal)
            canSubmit = false
        }else{
            self.Comment_Submit.setTitle("发送", forState: .Normal)
            self.Comment_Submit.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: .Normal)
            canSubmit = true
        }
    }
}
