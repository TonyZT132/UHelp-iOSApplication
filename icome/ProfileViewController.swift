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
    let WIDTH = UIScreen.main.bounds.width
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
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                
                for obj:AnyObject in objects!{
                    self.history_obj.add(obj)
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
        
        let TopView = UIView(frame: CGRect(x: 0, y: 0, width: WIDTH, height: TopViewHeight))
        TopView.layer.backgroundColor = UIColor.white.cgColor
        let TopImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: WIDTH, height: TopWidgetHeight))
        TopImageView.image = UIImage(named: "background")
        TopView.addSubview(TopImageView)
        
        FeaturedImageView = UIImageView(frame: CGRect(x: (WIDTH / 2 ) - FeaturedImageRadius, y: TopWidgetHeight - FeaturedImageRadius, width: FeaturedImageRadius * 2, height: FeaturedImageRadius * 2))
        FeaturedImageView!.image = UIImage(named: "空头像")
        FeaturedImageView!.layer.cornerRadius = FeaturedImageView!.frame.size.height/2
        FeaturedImageView!.clipsToBounds = true
        FeaturedImageView!.layer.borderColor = UIColor.white.cgColor
        FeaturedImageView!.layer.borderWidth = 2
        TopView.addSubview(FeaturedImageView!)
        LoadImage()
        
        let EditButton = UIButton(frame: CGRect(x: WIDTH/2 + FeaturedImageRadius / 2,y: TopWidgetHeight + FeaturedImageRadius / 2,width: FeaturedImageRadius / 2 ,height: FeaturedImageRadius / 2))
        EditButton.setImage(UIImage(named: "修改头像"), for: UIControlState())
        EditButton.layer.cornerRadius = EditButton.frame.size.height/2
        EditButton.clipsToBounds = true
        EditButton.addTarget(self, action: #selector(ProfileViewController.selected(_:)), for: .touchUpInside)
        TopView.addSubview(EditButton)
        
        if(SelectedUser?.objectId != PFUser.current()?.objectId){
            EditButton.isHidden = true
        }else{
            EditButton.isHidden = false
        }
        
        let NickName: String = (SelectedUser!.object(forKey: "nick_name") as? String)!
        
        let NickNameNSString: NSString = NickName as NSString
        let NickNameNSStringSize: CGSize = NickNameNSString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)])
        
        let NameLabel = UILabel(frame: CGRect(x: (WIDTH / 2) - (NickNameNSStringSize.width / 2), y: TopWidgetHeight + FeaturedImageRadius + 10, width: NickNameNSStringSize.width, height: NickNameNSStringSize.height))
        NameLabel.text = NickName
        NameLabel.font = UIFont.systemFont(ofSize: 16)
        let GenderImage = UIImageView (frame: CGRect(x: (WIDTH / 2)  + NickNameNSStringSize.width / 2 + 5, y: TopWidgetHeight + FeaturedImageRadius + 10 + (NickNameNSStringSize.height * 0.2) , width: NickNameNSStringSize.height * 0.6, height: NickNameNSStringSize.height * 0.6))
        
        
        let gender_temp = SelectedUser!.object(forKey: "gender") as? String
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
        
        let City: String = (SelectedUser!.object(forKey: "city") as? String)!
        
        let CityNSString: NSString = City as NSString
        let CityNSStringSize: CGSize = CityNSString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        
        let CityLabel = UILabel(frame: CGRect(x: (WIDTH / 2) - (CityNSStringSize.width / 2), y: TopWidgetHeight + FeaturedImageRadius + 10 + NickNameNSStringSize.height + 2, width: CityNSStringSize.width, height: CityNSStringSize.height))
        
        CityLabel.text = City
        CityLabel.textColor = UIColor(red: 173.0/255.0, green: 169.0/255.0, blue: 169.0/255.0, alpha:1.0)
        CityLabel.font = UIFont.systemFont(ofSize: 14)
        TopView.addSubview(CityLabel)
        
        
        let StatusView = UIView(frame: CGRect(x: 15, y: TopWidgetHeight * 2, width: WIDTH - 30, height: TopViewHeight - (TopWidgetHeight * 2)))
        StatusView.layer.backgroundColor = UIColor.white.cgColor
        
        let TopLine = UIView(frame: CGRect(x: 0,y: 0 ,width: StatusView.frame.width ,height: 0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.5).cgColor
        
        
        let FollowerLabel = UILabel(frame:CGRect(x: 0,y: 0, width: StatusView.frame.width / 2,height: StatusView.frame.height/2))
        
        let FollowerCountLabel = UILabel(frame:CGRect(x: 0,y: StatusView.frame.height/2, width: StatusView.frame.width / 2,height: StatusView.frame.height/2))
        
        FollowerLabel.text = "粉丝"
        FollowerLabel.textAlignment = .center
        FollowerLabel.font = UIFont.systemFont(ofSize: 14)
        FollowerCountLabel.isHidden = true
        FollowerCountLabel.text = "获取中..."
        countFollowers { (count, Error) -> Void in
            FollowerCountLabel.text = count
            FollowerCountLabel.isHidden = false
        }
        FollowerCountLabel.textAlignment = .center
        FollowerCountLabel.font = UIFont.systemFont(ofSize: 16)
        FollowerCountLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        
        let FollowingLabel = UILabel(frame:CGRect(x: StatusView.frame.width / 2,y: 0, width: StatusView.frame.width / 2,height: StatusView.frame.height/2))
        
        let FollowingCountLabel = UILabel(frame:CGRect(x: StatusView.frame.width / 2,y: StatusView.frame.height/2, width: StatusView.frame.width / 2,height: StatusView.frame.height/2))
        
        FollowingLabel.text = "关注"
        FollowingLabel.textAlignment = .center
        FollowingLabel.font = UIFont.systemFont(ofSize: 14)
        
        FollowingCountLabel.isHidden = true
        FollowingCountLabel.text = "获取中..."
        if(SelectedUser?.object(forKey: "follow") != nil){
            var FollowArr = [String]()
            FollowArr = SelectedUser?.object(forKey: "follow") as! Array
            FollowingCountLabel.text = String(FollowArr.count)
            
        }else{
            FollowingCountLabel.text = "0"
        }
        FollowingCountLabel.isHidden = false
        FollowingCountLabel.textAlignment = .center
        FollowingCountLabel.font = UIFont.systemFont(ofSize: 16)
        FollowingCountLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)

        
        StatusView.addSubview(FollowerLabel)
        StatusView.addSubview(FollowerCountLabel)
        StatusView.addSubview(FollowingLabel)
        StatusView.addSubview(FollowingCountLabel)
        StatusView.addSubview(TopLine)
        
        
        let HistoryWidget = UIView(frame: CGRect(x: 0, y: TopViewHeight + 10, width: WIDTH , height: 40))
        HistoryWidget.layer.backgroundColor = UIColor.white.cgColor
        
        
        let HistitoryTitleLabel = UILabel(frame:CGRect(x: 15,y: 0, width: HistoryWidget.frame.width - 30 ,height: HistoryWidget.frame.height))
        
        
        if(SelectedUser?.objectId == PFUser.current()?.objectId){
            HistitoryTitleLabel.text = "我的发布"
        }else{
            let gender_temp = SelectedUser!.object(forKey: "gender") as? String
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
        
        
        HistitoryTitleLabel.textAlignment = .left
        HistitoryTitleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let BotLine = UIView(frame: CGRect(x: 0,y: HistoryWidget.frame.height - 0.5 ,width: HistoryWidget.frame.width ,height: 0.5))
        BotLine.layer.backgroundColor =  UIColor.black.cgColor
        
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
    func countFollowers(_ completion:@escaping (_ count:String?, _ Error:String?) -> Void){
        let query = PFQuery(className:"_User")
        query.whereKey("follow", containsAllObjectsIn:["\((SelectedUser!.objectId)!)"])
        query.countObjectsInBackground {
            (count: Int32, error: NSError?) -> Void in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    completion(count: String(count),Error: nil)
                })
            }else{
                completion(count: nil,Error: "获取失败")
            }
        }
    }
    
    /*Update collection view*/
    func LoadCollectionView(){
        
        CollectionView?.isHidden = true
        ScrollView.contentSize = CGSize(width: WIDTH, height: TopViewHeight)
        
        let CellHeight = CGFloat(186)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: WIDTH, height: CellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        CollectionView = UICollectionView(frame: CGRect(x: 0, y: TopViewHeight, width: WIDTH, height: (CellHeight + layout.minimumLineSpacing) * CGFloat(history_obj.count - 1) + CellHeight), collectionViewLayout: layout)
        CollectionView!.dataSource = self
        CollectionView!.delegate = self
        
        CollectionView!.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        CollectionView!.backgroundColor = UIColor.clear
        CollectionView!.reloadData()
        ScrollViewHeight += CollectionView!.frame.height
        ScrollView.addSubview(CollectionView!)
        CollectionView!.isScrollEnabled = false
        ScrollView.contentSize = CGSize(width: WIDTH, height: ScrollViewHeight)
    }
    
    /*Load freatured image*/
    func LoadImage(){
        
        let userImageFile = SelectedUser!.object(forKey: "featured_image")  as! PFFile
        userImageFile.getDataInBackground {
            (imageData: Data?, error: NSError?) -> Void in
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:HomeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell)!
        
        let user = (history_obj[indexPath.row] as AnyObject).object(forKey: "user") as! PFUser
        cell.nickName.text = (user.object(forKey: "nick_name") as? String)! + " — " + ((history_obj[indexPath.row] as AnyObject).object(forKey: "title") as? String)!
        
        cell.price.text = "$" + ((history_obj[indexPath.row] as AnyObject).object(forKey: "price") as? String)! + "/" + ((history_obj[indexPath.row] as AnyObject).object(forKey: "unit") as? String)!
        cell.shortDescription.text = (history_obj[indexPath.row] as AnyObject).object(forKey: "description") as? String
        
        let TopLine = UIView(frame: CGRect(x: 0,y: 0,width: cell.shortDescription.frame.width,height: 0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.3).cgColor
        cell.shortDescription.addSubview(TopLine)

        let count = (history_obj[indexPath.row] as AnyObject).object(forKey: "view_count") as! Int
        cell.viewCount.text = String(count)
        cell.viewCountImage.image = UIImage(named: "点击数")
        
        let userImageFile = user.object(forKey: "featured_image")  as! PFFile
        userImageFile.getDataInBackground {
            (imageData: Data?, error: NSError?) -> Void in
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
        
        if((history_obj[indexPath.row] as AnyObject).object(forKey: "comments_count") != nil){
            let comments_count = (history_obj[indexPath.row] as AnyObject).object(forKey: "comments_count") as! Int
            cell.commentCount.text = String(comments_count)
        }else{
            cell.commentCount.text = "0"
        }
        cell.commectCountImage.image = UIImage(named: "回复数")
        
        
        cell.locationImage.image = UIImage(named: "位子")
        
        let gender_temp = user.object(forKey: "gender") as? String
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
        if((history_obj[indexPath.row] as AnyObject).object(forKey: "location") != nil){
            if(((history_obj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") != nil) && ((history_obj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") as! Bool) == true){
                let user_location = CLLocation(latitude: userLatitude, longitude: userLongitude)
                if let point = (history_obj[indexPath.row] as AnyObject).object(forKey: "location") as? PFGeoPoint{
                    let temp = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    let distance = user_location.distance(from: temp)
                    cell.location.text = (history_obj[indexPath.row] as AnyObject).object(forKey: "city") as! String + " · " + distance_calc(distance)
                }else{
                    cell.location.text = (history_obj[indexPath.row] as AnyObject).object(forKey: "city") as? String
                }
            }else{
                cell.location.text = (history_obj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }
        }else{
            if((history_obj[indexPath.row] as AnyObject).object(forKey: "city") != nil){
                cell.location.text = (history_obj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }else{
                cell.location.text = " "
            }

        }
        
        if(device() == 5 || device() == 4){
            cell.thumbnailImage3.isHidden = true
        }
        
        var thumnail_image_arr = [PFFile]()
        thumnail_image_arr = (history_obj[indexPath.row] as AnyObject).object(forKey: "thumbnail_image") as! Array
        if(thumnail_image_arr.count > 0 && thumnail_image_arr.count < 3){
            if(thumnail_image_arr.count == 1){
                
                cell.thumbnailImage1.image = UIImage(named: "载入中")
                cell.thumbnailImage2.isHidden = true
                cell.thumbnailImage3.isHidden = true

                thumnail_image_arr[0].getDataInBackground {
                    (imageData: Data?, error: NSError?) -> Void in
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
                cell.thumbnailImage3.isHidden = true
                
                thumnail_image_arr[0].getDataInBackground {
                    (imageData: Data?, error: NSError?) -> Void in
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
                
                thumnail_image_arr[1].getDataInBackground {
                    (imageData: Data?, error: NSError?) -> Void in
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

            thumnail_image_arr[0].getDataInBackground {
                (imageData: Data?, error: NSError?) -> Void in
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
            
            thumnail_image_arr[1].getDataInBackground {
                (imageData: Data?, error: NSError?) -> Void in
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
            
            thumnail_image_arr[2].getDataInBackground {
                (imageData: Data?, error: NSError?) -> Void in
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

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history_obj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //direct to new_post page
        
        if(SelectedUser == PFUser.current()){
            /*Add option menu*/
            let optionMenu = UIAlertController(title: nil, message: "请选择", preferredStyle: .actionSheet)
            let detail = UIAlertAction(title: "查看", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.show()
                
                /*Query from Parse class*/
                let loadData = PFQuery(className:dataClass)
                loadData.whereKey("objectId", equalTo:((self.history_obj[indexPath.row] as AnyObject).objectId as String!))
                loadData.findObjectsInBackground {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        let temp = NSMutableArray()
                        for obj:AnyObject in objects!{
                            temp.add(obj)
                        }
                        
                        if(temp.count > 0){
                            SVProgressHUD.dismiss()
                            let detail : DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
                            let user = self.history_obj[indexPath.row].object(forKey: "user") as! PFUser
                            
                            detail.objectId_detail = self.history_obj[indexPath.row].objectId as String!
                            detail.selected_nick_name = (user.object(forKey: "nick_name") as? String)!
                            detail.hidesBottomBarWhenPushed = true
                            self.navigationController!.navigationBar.tintColor = UIColor.white
                            self.navigationController?.pushViewController(detail, animated: true)
                        }else{
                            
                            self.present(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                            SVProgressHUD.dismiss()
                        }
                        
                    } else {
                        // Log details of the failure
                        NSLog("详情页面载入失败")
                        NSLog("Error: \(error!) \(error!.userInfo)")
                        self.present(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }
            })
            let edit = UIAlertAction(title: "编辑", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                /*Direct to new_post page*/
                let new_post : PostNewNavViewController = self.storyboard?.instantiateViewController(withIdentifier: "post_new_nav") as! PostNewNavViewController
                isUpdate = true
                objectId = (self.history_obj[indexPath.row] as AnyObject).objectId as String!
                self.present(new_post, animated: true, completion: nil)
            })
            let delete = UIAlertAction(title: "删除", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let query = PFQuery(className:dataClass)
                query.whereKey("objectId", equalTo:(self.history_obj[indexPath.row] as AnyObject).objectId as String!)
                query.findObjectsInBackground {
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
                        self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_POST_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                }
                
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(detail)
            optionMenu.addAction(edit)
            optionMenu.addAction(delete)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        
        }else{
            
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.show()
            
            /*Query from Parse class*/
            let loadData = PFQuery(className:dataClass)
            loadData.whereKey("objectId", equalTo:((self.history_obj[indexPath.row] as AnyObject).objectId as String!))
            loadData.findObjectsInBackground {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    let temp = NSMutableArray()
                    for obj:AnyObject in objects!{
                        temp.add(obj)
                    }
                    
                    if(temp.count > 0){
                        SVProgressHUD.dismiss()
                        let detail : DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
                        let user = self.history_obj[indexPath.row].object(forKey: "user") as! PFUser
                        
                        detail.objectId_detail = self.history_obj[indexPath.row].objectId as String!
                        detail.selected_nick_name = (user.object(forKey: "nick_name") as? String)!
                        detail.hidesBottomBarWhenPushed = true
                        self.navigationController!.navigationBar.tintColor = UIColor.white
                        self.navigationController?.pushViewController(detail, animated: true)
                    }else{
                        
                        self.present(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                        SVProgressHUD.dismiss()
                    }
                   
                } else {
                    // Log details of the failure
                    NSLog("详情页面载入失败")
                    NSLog("Error: \(error!) \(error!.userInfo)")
                    self.present(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    /*If the current user select to change the featred image*/
    func selected (_ sender: UIButton!) {
        update_featured_image()
    }
    
    /*Upload new feature image*/
    func update_featured_image(){
        //setup alert for photo selection type menu (take photo or choose existing photo)
        let optionMenu = UIAlertController(title: nil, message: "更换头像或查看编辑个人资料？", preferredStyle: .actionSheet)
        
        let photoPickAction = UIAlertAction(title: "更换头像", style: .default, handler: {
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
                imageCropVC.cropMode = RSKImageCropMode.square
                imageCropVC.delegate = self
                self.present(imageCropVC, animated: true, completion:nil)
            }
            
            //present photo pick page
            self.present(pickerController, animated: true, completion:nil)
        })
        
        let updateInfoAction = UIAlertAction(title: "个人资料", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let pinfo : EditInfoTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "edit_info") as! EditInfoTableViewController
            //let user = home_obj[indexPath.row].objectForKey("user") as! PFUser
           // print(PFUser.currentUser())
            
            pinfo.username = PFUser.current()!.object(forKey: "nick_name") as? String
            
            //print(Username)
            
            //pinfo.UserName.text = Username!
            let gender = PFUser.current()!.object(forKey: "gender") as? String
            if (gender == "M"){
                pinfo.usergender  = "汉子"
            }else{
                pinfo.usergender  = "妹子"
            
            }
            pinfo.birthday_string = PFUser.current()!.object(forKey: "birthday") as? String
            
            pinfo.hidesBottomBarWhenPushed = true
            self.navigationController!.navigationBar.tintColor = UIColor.white
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
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("取消")
        })
        
        //add all actions
        optionMenu.addAction(photoPickAction)
        optionMenu.addAction(updateInfoAction)
        //optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        //present the option menu
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    /*Update new iamge to Parse*/
    func do_update(){
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        
        /*Resize the image*/
        let size_fe = CGSize(width: 300.0,height: 300.0)
        let imageData_t = UIImagePNGRepresentation((RBSquareImageTo((cropped_image! as UIImage), size: size_fe) as UIImage))
        let imageFile_t = PFFile (data:imageData_t!)
        
        /*Do update*/
        if let currentUser = PFUser.current(){
            currentUser["featured_image"] = imageFile_t
            //currentUser.saveInBackground()
            currentUser.saveInBackground(block: { (success, error) -> Void in
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
            self.present(show_alert_one_button(ERROR_ALERT, message: ERROR_IMAGE_CHANGE_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
        }
    }
    
    //MARK: Image cropper delegate
    
    /*Get the cropped image*/
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        cropped_image = croppedImage
        self.navigationController?.dismiss(animated: true, completion: nil)
        //self.signup()
        self.do_update()
    }
    
    /*When user click cancel button*/
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        return
    }
}
