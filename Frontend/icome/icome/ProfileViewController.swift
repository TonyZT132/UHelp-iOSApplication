//
//  ProfileViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-14.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,RSKImageCropViewControllerDelegate {

    @IBOutlet weak var ScrollView: UIScrollView!
    var CollectionView:UICollectionView?
    var history_obj:NSMutableArray = NSMutableArray()
    var ScrollViewHeight:CGFloat = 0
    let WIDTH = UIScreen.mainScreen().bounds.width
    var TopViewHeight:CGFloat = 270
    var TopWidgetHeight:CGFloat = 110
    var FeaturedImageRadius:CGFloat = 50
    var SelectedUser:PFUser?
    var FeaturedImageView:UIImageView?
    var cropped_image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func LoadData(){
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("user", equalTo: SelectedUser!)
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                for obj:AnyObject in objects!{
                    self.history_obj.addObject(obj)
                }
                self.UpdateView()
                
            } else {
                // Log details of the failure
                NSLog("详情页面载入失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    /*Update scrollview*/
    func UpdateView() {
        
        let TopView = UIView(frame: CGRectMake(0, 0, WIDTH, TopViewHeight))
        TopView.layer.backgroundColor = UIColor.whiteColor().CGColor
        let TopImageView = UIImageView(frame: CGRectMake(0, 0, WIDTH, TopWidgetHeight))
        TopImageView.image = UIImage(named: "background")
        TopView.addSubview(TopImageView)
        
        FeaturedImageView = UIImageView(frame: CGRectMake((WIDTH / 2 ) - FeaturedImageRadius, TopWidgetHeight - FeaturedImageRadius, FeaturedImageRadius * 2, FeaturedImageRadius * 2))
        FeaturedImageView!.image = UIImage(named: "空头像")
        FeaturedImageView!.layer.cornerRadius = FeaturedImageView!.frame.size.height/2
        FeaturedImageView!.clipsToBounds = true
        FeaturedImageView!.layer.borderColor = UIColor.whiteColor().CGColor
        FeaturedImageView!.layer.borderWidth = 2
        TopView.addSubview(FeaturedImageView!)
        LoadImage()
        
        let EditButton = UIButton(frame: CGRectMake(WIDTH/2 + FeaturedImageRadius / 2,TopWidgetHeight + FeaturedImageRadius / 2,FeaturedImageRadius / 2 ,FeaturedImageRadius / 2))
        EditButton.setImage(UIImage(named: "修改头像"), forState: .Normal)
        EditButton.layer.cornerRadius = EditButton.frame.size.height/2
        EditButton.clipsToBounds = true
        EditButton.addTarget(self, action: #selector(ProfileViewController.selected(_:)), forControlEvents: .TouchUpInside)
        TopView.addSubview(EditButton)
        
        if(SelectedUser?.objectId != PFUser.currentUser()?.objectId){
            EditButton.hidden = true
        }else{
            EditButton.hidden = false
        }
        
        let NickName: String = (SelectedUser!.objectForKey("nick_name") as? String)!
        
        let NickNameNSString: NSString = NickName as NSString
        let NickNameNSStringSize: CGSize = NickNameNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16.0)])
        
        let NameLabel = UILabel(frame: CGRectMake((WIDTH / 2) - (NickNameNSStringSize.width / 2), TopWidgetHeight + FeaturedImageRadius + 10, NickNameNSStringSize.width, NickNameNSStringSize.height))
        NameLabel.text = NickName
        NameLabel.font = UIFont.systemFontOfSize(16)
        let GenderImage = UIImageView (frame: CGRectMake((WIDTH / 2)  + NickNameNSStringSize.width / 2 + 5, TopWidgetHeight + FeaturedImageRadius + 10 + (NickNameNSStringSize.height * 0.2) , NickNameNSStringSize.height * 0.6, NickNameNSStringSize.height * 0.6))
        
        
        let gender_temp = SelectedUser!.objectForKey("gender") as? String
        if(gender_temp != nil){
            if (gender_temp == "M"){
                GenderImage.image = UIImage(named: "性别男")
            }
            else if (gender_temp == "F"){
                GenderImage.image = UIImage(named: "性别女")
            }else{
                /*Should Never Reach Here!*/
                NSLog("出现未知错误")
            }
        }
        
        TopView.addSubview(NameLabel)
        TopView.addSubview(GenderImage)
        
        let City: String = (SelectedUser!.objectForKey("city") as? String)!
        
        let CityNSString: NSString = City as NSString
        let CityNSStringSize: CGSize = CityNSString.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        
        let CityLabel = UILabel(frame: CGRectMake((WIDTH / 2) - (CityNSStringSize.width / 2), TopWidgetHeight + FeaturedImageRadius + 10 + NickNameNSStringSize.height + 2, CityNSStringSize.width, CityNSStringSize.height))
        
        CityLabel.text = City
        CityLabel.textColor = UIColor(red: 173.0/255.0, green: 169.0/255.0, blue: 169.0/255.0, alpha:1.0)
        CityLabel.font = UIFont.systemFontOfSize(14)
        TopView.addSubview(CityLabel)
        
        
        let StatusView = UIView(frame: CGRectMake(15, TopWidgetHeight * 2, WIDTH - 30, TopViewHeight - (TopWidgetHeight * 2)))
        StatusView.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        let TopLine = UIView(frame: CGRectMake(0,0 ,StatusView.frame.width ,0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.5).CGColor
        
        
        let FollowerLabel = UILabel(frame:CGRectMake(0,0, StatusView.frame.width / 2,StatusView.frame.height/2))
        
        let FollowerCountLabel = UILabel(frame:CGRectMake(0,StatusView.frame.height/2, StatusView.frame.width / 2,StatusView.frame.height/2))
        
        FollowerLabel.text = "粉丝"
        FollowerLabel.textAlignment = .Center
        FollowerLabel.font = UIFont.systemFontOfSize(14)
        FollowerCountLabel.hidden = true
        FollowerCountLabel.text = "获取中..."
        countFollowers { (count, Error) -> Void in
            FollowerCountLabel.text = count
            FollowerCountLabel.hidden = false
        }
        FollowerCountLabel.textAlignment = .Center
        FollowerCountLabel.font = UIFont.systemFontOfSize(16)
        FollowerCountLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        
        let FollowingLabel = UILabel(frame:CGRectMake(StatusView.frame.width / 2,0, StatusView.frame.width / 2,StatusView.frame.height/2))
        
        let FollowingCountLabel = UILabel(frame:CGRectMake(StatusView.frame.width / 2,StatusView.frame.height/2, StatusView.frame.width / 2,StatusView.frame.height/2))
        
        FollowingLabel.text = "关注"
        FollowingLabel.textAlignment = .Center
        FollowingLabel.font = UIFont.systemFontOfSize(14)
        
        FollowingCountLabel.hidden = true
        FollowingCountLabel.text = "获取中..."
        if(SelectedUser?.objectForKey("follow") != nil){
            var FollowArr = [String]()
            FollowArr = SelectedUser?.objectForKey("follow") as! Array
            FollowingCountLabel.text = String(FollowArr.count)
            
        }else{
            FollowingCountLabel.text = "0"
        }
        FollowingCountLabel.hidden = false
        FollowingCountLabel.textAlignment = .Center
        FollowingCountLabel.font = UIFont.systemFontOfSize(16)
        FollowingCountLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        
        StatusView.addSubview(FollowerLabel)
        StatusView.addSubview(FollowerCountLabel)
        StatusView.addSubview(FollowingLabel)
        StatusView.addSubview(FollowingCountLabel)
        StatusView.addSubview(TopLine)
        
        
        let HistoryWidget = UIView(frame: CGRectMake(0, TopViewHeight + 10, WIDTH , 40))
        HistoryWidget.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        
        let HistitoryTitleLabel = UILabel(frame:CGRectMake(15,0, HistoryWidget.frame.width - 30 ,HistoryWidget.frame.height))
        
        
        if(SelectedUser?.objectId == PFUser.currentUser()?.objectId){
            HistitoryTitleLabel.text = "我的发布"
        }else{
            let gender_temp = SelectedUser!.objectForKey("gender") as? String
            if(gender_temp != nil){
                if (gender_temp == "M"){
                    HistitoryTitleLabel.text = "他的发布"
                }
                else if (gender_temp == "F"){
                    HistitoryTitleLabel.text = "她的发布"
                }else{
                    /*Should Never Reach Here!*/
                    NSLog("出现未知错误")
                }
            }
        }
        
        
        HistitoryTitleLabel.textAlignment = .Left
        HistitoryTitleLabel.font = UIFont.systemFontOfSize(14)
        
        let BotLine = UIView(frame: CGRectMake(0,HistoryWidget.frame.height - 0.5 ,HistoryWidget.frame.width ,0.5))
        BotLine.layer.backgroundColor =  UIColor.blackColor().CGColor
        
        HistoryWidget.addSubview(HistitoryTitleLabel)
        HistoryWidget.addSubview(BotLine)
        TopViewHeight += 50
        ScrollView.addSubview(HistoryWidget)
        
        TopView.addSubview(StatusView)
        ScrollViewHeight += TopViewHeight
        ScrollView.addSubview(TopView)
        ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
        LoadCollectionView()
        
    }
    
    /*Count fans for selected user*/
    func countFollowers(completion:(count:String?, Error:String?) -> Void){
        let query = PFQuery(className:"_User")
        query.whereKey("follow", containsAllObjectsInArray:["\((SelectedUser!.objectId)!)"])
        query.countObjectsInBackgroundWithBlock {
            (count: Int32, error: NSError?) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(),{
                    completion(count: String(count),Error: nil)
                })
            }else{
                completion(count: nil,Error: "获取失败")
            }
        }
    }
    
    /*Update collection view*/
    func LoadCollectionView(){
        
        CollectionView?.hidden = true
        ScrollView.contentSize = CGSize(width: WIDTH, height: TopViewHeight)
        
        let CellHeight = CGFloat(186)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: WIDTH, height: CellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        CollectionView = UICollectionView(frame: CGRectMake(0, TopViewHeight, WIDTH, (CellHeight + layout.minimumLineSpacing) * CGFloat(history_obj.count - 1) + CellHeight), collectionViewLayout: layout)
        CollectionView!.dataSource = self
        CollectionView!.delegate = self
        
        CollectionView!.registerNib(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        CollectionView!.backgroundColor = UIColor.clearColor()
        CollectionView!.reloadData()
        ScrollViewHeight += CollectionView!.frame.height
        ScrollView.addSubview(CollectionView!)
        CollectionView!.scrollEnabled = false
        ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
    }
    
    /*Load freatured image*/
    func LoadImage(){
        
        let userImageFile = SelectedUser!.objectForKey("featured_image")  as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    //self.FeaturedImage.image = UIImage(data:imageData)
                    self.FeaturedImageView?.image = UIImage(data:imageData)
                }else{
                    NSLog("头像格式转换失败")
                }
            }else{
                NSLog("头像载入失败")
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:HomeCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? HomeCollectionViewCell)!
        
        let user = history_obj[indexPath.row].objectForKey("user") as! PFUser
        cell.nickName.text = (user.objectForKey("nick_name") as? String)! + " — " + (history_obj[indexPath.row].objectForKey("title") as? String)!
        
        cell.price.text = "$" + (history_obj[indexPath.row].objectForKey("price") as? String)! + "/" + (history_obj[indexPath.row].objectForKey("unit") as? String)!
        cell.shortDescription.text = history_obj[indexPath.row].objectForKey("description") as? String
        
        let TopLine = UIView(frame: CGRectMake(0,0,cell.shortDescription.frame.width,0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.3).CGColor
        cell.shortDescription.addSubview(TopLine)

        let count = history_obj[indexPath.row].objectForKey("view_count") as! Int
        cell.viewCount.text = String(count)
        cell.viewCountImage.image = UIImage(named: "点击数")
        
        let userImageFile = user.objectForKey("featured_image")  as! PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.profileImage.image = UIImage(data:imageData)
                }else{
                    NSLog("图片格式转换失败")
                }
            }else{
                NSLog("图片加载失败")
            }
        }
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2
        cell.profileImage.clipsToBounds = true
        
        if(history_obj[indexPath.row].objectForKey("comments_count") != nil){
            let comments_count = history_obj[indexPath.row].objectForKey("comments_count") as! Int
            cell.commentCount.text = String(comments_count)
        }else{
            cell.commentCount.text = "0"
        }
        cell.commectCountImage.image = UIImage(named: "回复数")
        
        
        cell.locationImage.image = UIImage(named: "位子")
        
        let gender_temp = user.objectForKey("gender") as? String
        if(gender_temp != nil){
            if (gender_temp == "M"){
                cell.genderImage.image = UIImage(named: "性别男")
            }
            else if (gender_temp == "F"){
                cell.genderImage.image = UIImage(named: "性别女")
            }else{
                /*Should Never Reach Here!*/
                NSLog("出现未知错误")
            }
        }
        
        /*Load location info*/
        if(history_obj[indexPath.row].objectForKey("location") != nil){
            if((history_obj[indexPath.row].objectForKey("enabledLocation_newPost") != nil) && (history_obj[indexPath.row].objectForKey("enabledLocation_newPost") as! Bool) == true){
                let user_location = CLLocation(latitude: userLatitude, longitude: userLongitude)
                if let point = history_obj[indexPath.row].objectForKey("location") as? PFGeoPoint{
                    let temp = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    let distance = user_location.distanceFromLocation(temp)
                    cell.location.text = history_obj[indexPath.row].objectForKey("city") as! String + " · " + distance_calc(distance)
                }else{
                    cell.location.text = history_obj[indexPath.row].objectForKey("city") as? String
                }
            }else{
                cell.location.text = history_obj[indexPath.row].objectForKey("city") as? String
            }
        }else{
            if(history_obj[indexPath.row].objectForKey("city") != nil){
                cell.location.text = history_obj[indexPath.row].objectForKey("city") as? String
            }else{
                cell.location.text = " "
            }

        }
        
        if(device() == 5 || device() == 4){
            cell.thumbnailImage3.hidden = true
        }
        
        var thumnail_image_arr = [PFFile]()
        thumnail_image_arr = history_obj[indexPath.row].objectForKey("thumbnail_image") as! Array
        if(thumnail_image_arr.count > 0 && thumnail_image_arr.count < 3){
            if(thumnail_image_arr.count == 1){
                
                cell.thumbnailImage1.image = UIImage(named: "载入中")
                cell.thumbnailImage2.hidden = true
                cell.thumbnailImage3.hidden = true

                thumnail_image_arr[0].getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.thumbnailImage1.image = UIImage(data:imageData)
                        }else{
                            NSLog("Thumbnail图片格式转换失败")
                        }
                    }else{
                        NSLog("Thumbnail图片加载失败")
                    }
                }
            }else{
                cell.thumbnailImage1.image = UIImage(named: "载入中")
                cell.thumbnailImage2.image = UIImage(named: "载入中")
                cell.thumbnailImage3.hidden = true
                
                thumnail_image_arr[0].getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.thumbnailImage1.image = UIImage(data:imageData)
                        }else{
                            NSLog("Thumbnail图片格式转换失败")
                        }
                    }else{
                        NSLog("Thumbnail图片加载失败")
                    }
                }
                
                thumnail_image_arr[1].getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.thumbnailImage2.image = UIImage(data:imageData)
                        }else{
                            NSLog("Thumbnail图片格式转换失败")
                        }
                    }else{
                        NSLog("Thumbnail图片加载失败")
                    }
                }
            }
        }else if(thumnail_image_arr.count >= 3){
            
            cell.thumbnailImage1.image = UIImage(named: "载入中")
            cell.thumbnailImage2.image = UIImage(named: "载入中")
            cell.thumbnailImage3.image = UIImage(named: "载入中")

            thumnail_image_arr[0].getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.thumbnailImage1.image = UIImage(data:imageData)
                    }else{
                        NSLog("Thumbnail图片格式转换失败")
                    }
                }else{
                    NSLog("Thumbnail图片加载失败")
                }
            }
            
            thumnail_image_arr[1].getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.thumbnailImage2.image = UIImage(data:imageData)
                    }else{
                        NSLog("Thumbnail图片格式转换失败")
                    }
                }else{
                    NSLog("Thumbnail图片加载失败")
                }
            }
            
            thumnail_image_arr[2].getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.thumbnailImage3.image = UIImage(data:imageData)
                    }else{
                        NSLog("Thumbnail图片格式转换失败")
                    }
                }else{
                    NSLog("Thumbnail图片加载失败")
                }
            }
        }
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history_obj.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //direct to new_post page
        
        if(SelectedUser == PFUser.currentUser()){
            /*Add option menu*/
            let optionMenu = UIAlertController(title: nil, message: "请选择", preferredStyle: .ActionSheet)
            let detail = UIAlertAction(title: "查看", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
                SVProgressHUD.show()
                
                /*Query from Parse class*/
                let loadData = PFQuery(className:dataClass)
                loadData.whereKey("objectId", equalTo:(self.history_obj[indexPath.row].objectId as String!))
                loadData.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        let temp = NSMutableArray()
                        for obj:AnyObject in objects!{
                            temp.addObject(obj)
                        }
                        
                        if(temp.count > 0){
                            SVProgressHUD.dismiss()
                            let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
                            let user = self.history_obj[indexPath.row].objectForKey("user") as! PFUser
                            
                            detail.objectId_detail = self.history_obj[indexPath.row].objectId as String!
                            detail.selected_nick_name = (user.objectForKey("nick_name") as? String)!
                            detail.hidesBottomBarWhenPushed = true
                            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                            self.navigationController?.pushViewController(detail, animated: true)
                        }else{
                            
                            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            SVProgressHUD.dismiss()
                        }
                        
                    } else {
                        // Log details of the failure
                        NSLog("详情页面载入失败")
                        NSLog("Error: \(error!) \(error!.userInfo)")
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }
            })
            let edit = UIAlertAction(title: "编辑", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                /*Direct to new_post page*/
                let new_post : PostNewNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier("post_new_nav") as! PostNewNavViewController
                isUpdate = true
                objectId = self.history_obj[indexPath.row].objectId as String!
                self.presentViewController(new_post, animated: true, completion: nil)
            })
            let delete = UIAlertAction(title: "删除", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let query = PFQuery(className:dataClass)
                query.whereKey("objectId", equalTo:self.history_obj[indexPath.row].objectId as String!)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        for obj in objects! {
                            obj.deleteInBackground()
                        }
                        self.ScrollViewHeight = 0
                        self.history_obj.removeAllObjects()
                        self.TopViewHeight = 270
                        self.TopWidgetHeight = 110
                        self.FeaturedImageRadius = 50
                        self.LoadData()
                    } else {
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_POST_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }
                
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(detail)
            optionMenu.addAction(edit)
            optionMenu.addAction(delete)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        
        }else{
            
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            SVProgressHUD.show()
            
            /*Query from Parse class*/
            let loadData = PFQuery(className:dataClass)
            loadData.whereKey("objectId", equalTo:(self.history_obj[indexPath.row].objectId as String!))
            loadData.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    let temp = NSMutableArray()
                    for obj:AnyObject in objects!{
                        temp.addObject(obj)
                    }
                    
                    if(temp.count > 0){
                        SVProgressHUD.dismiss()
                        let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
                        let user = self.history_obj[indexPath.row].objectForKey("user") as! PFUser
                        
                        detail.objectId_detail = self.history_obj[indexPath.row].objectId as String!
                        detail.selected_nick_name = (user.objectForKey("nick_name") as? String)!
                        detail.hidesBottomBarWhenPushed = true
                        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                        self.navigationController?.pushViewController(detail, animated: true)
                    }else{
                        
                        self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                   
                } else {
                    // Log details of the failure
                    NSLog("详情页面载入失败")
                    NSLog("Error: \(error!) \(error!.userInfo)")
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    /*If the current user select to change the featred image*/
    func selected (sender: UIButton!) {
        update_featured_image()
    }
    
    /*Upload new feature image*/
    func update_featured_image(){
        //setup alert for photo selection type menu (take photo or choose existing photo)
        let optionMenu = UIAlertController(title: nil, message: "更换头像或查看编辑个人资料？", preferredStyle: .ActionSheet)
        
        let photoPickAction = UIAlertAction(title: "更换头像", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("上传")
            
            //initial the DKimage picker
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 1
            
            //set action if user click cancel button
            pickerController.didCancel = { () in
                //print("didCancelled")
            }
            
            //set action if user do select photo
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                //print("didSelectedAssets")
                
                if(assets.count == 0){
                    return
                }
                
                //pass to a global array for thumbnail photo upload
                let asset = assets[0]
                
                /*Crop the image*/
                let imageCropVC = RSKImageCropViewController(image: asset.fullResolutionImage!)
                imageCropVC.cropMode = RSKImageCropMode.Square
                imageCropVC.delegate = self
                self.presentViewController(imageCropVC, animated: true, completion:nil)
            }
            
            //present photo pick page
            self.presentViewController(pickerController, animated: true, completion:nil)
        })
        
        let updateInfoAction = UIAlertAction(title: "个人资料", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let pinfo : EditInfoTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("edit_info") as! EditInfoTableViewController
            //let user = home_obj[indexPath.row].objectForKey("user") as! PFUser
           // print(PFUser.currentUser())
            
            pinfo.username = PFUser.currentUser()!.objectForKey("nick_name") as? String
            
            //print(Username)
            
            //pinfo.UserName.text = Username!
            let gender = PFUser.currentUser()!.objectForKey("gender") as? String
            if (gender == "M"){
                pinfo.usergender  = "汉子"
            }else{
                pinfo.usergender  = "妹子"
            
            }
            pinfo.birthday_string = PFUser.currentUser()!.objectForKey("birthday") as? String
            
            pinfo.hidesBottomBarWhenPushed = true
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationController?.pushViewController(pinfo, animated: true)
            
        })
        
        /*
        //if user choose to take uew photo
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: {
        (alert: UIAlertAction!) -> Void in
        print("拍照")
        })
        */
        
        //if user choose to cancel
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("取消")
        })
        
        //add all actions
        optionMenu.addAction(photoPickAction)
        optionMenu.addAction(updateInfoAction)
        //optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //present the option menu
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    /*Update new iamge to Parse*/
    func do_update(){
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*Resize the image*/
        let size_fe = CGSizeMake(300.0,300.0)
        let imageData_t = UIImagePNGRepresentation((RBSquareImageTo((cropped_image! as UIImage), size: size_fe) as UIImage))
        let imageFile_t = PFFile (data:imageData_t!)
        
        /*Do update*/
        if let currentUser = PFUser.currentUser(){
            currentUser["featured_image"] = imageFile_t
            //currentUser.saveInBackground()
            currentUser.saveInBackgroundWithBlock({ (success, error) -> Void in
                if(error == nil){
                    
                    /*Reset the layout*/
                    self.FeaturedImageView?.image = self.cropped_image
                    self.history_obj.removeAllObjects()
                    self.TopViewHeight = 270
                    self.TopWidgetHeight = 110
                    self.FeaturedImageRadius = 50
                    self.ScrollViewHeight = 0
                    SVProgressHUD.dismiss()
                    self.LoadData()
                }else{
                    NSLog("更换头像失败")
                    SVProgressHUD.dismiss()
                }
                
            })
            
        }else{
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_IMAGE_CHANGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
        }
    }
    
    //MARK: Image cropper delegate
    
    /*Get the cropped image*/
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        cropped_image = croppedImage
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        //self.signup()
        self.do_update()
    }
    
    /*When user click cancel button*/
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        return
    }
}
