//
//  HomeViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-01-12.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,CLLocationManagerDelegate {
    
    /*Set up bounds*/
    let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
    let TOP_VIEW_HEIGHT = (UIScreen.mainScreen().bounds.width / 5) + 10
    let IMAGE_VIEW_HEIGHT:CGFloat = 150
    
    let header = MJRefreshNormalHeader()

    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollViewHeight:CGFloat = 0
    var collectionView:UICollectionView?
    var categoryArr = [UILabel]()
    var widgetImageView = UIImageView()
    
    /*Core Location Defination*/
    var coreLocationManagerHome = CLLocationManager()
    var enabledLocationHome = true
    
    var scrollHeaderHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Initialaize the searching data*/
        searchByCategory = "学术辅导"
        dataClass = "home_table_u"
        pickerData = CATEGORY_DATA

        /*Check Connection*/
        if(messageConnect == false){
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            SVProgressHUD.show()
        }
        
        /*Inital collection view*/
        collectionView?.hidden = true
        scrollView.layer.backgroundColor = UIColor.clearColor().CGColor
        let categoryView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, TOP_VIEW_HEIGHT))
        categoryView.layer.backgroundColor = UIColor.blueColor().CGColor
        scrollViewHeight += TOP_VIEW_HEIGHT
        scrollView.addSubview(categoryView)
        
        /*Add Top Button*/
        for i in 0 ... 4 {
            let x = (SCREEN_WIDTH / 5) * CGFloat(i)
            let iconView = UIView(frame: CGRectMake(x,0,SCREEN_WIDTH/5,TOP_VIEW_HEIGHT))
            iconView.layer.backgroundColor = UIColor.whiteColor().CGColor
            
            /*Draw Top icon*/
            let iconWidth = (SCREEN_WIDTH / 5) - CGFloat(30)
            let iconButton = UIButton(frame: CGRectMake((SCREEN_WIDTH/10) - (iconWidth/2), 12, iconWidth, iconWidth))
            iconButton.layer.cornerRadius = iconWidth/2
            iconButton.clipsToBounds = true
            iconButton.tag = i
            let imageName = getImageName(i)
            iconButton.setImage(UIImage(named: imageName), forState: .Normal)
            iconButton.addTarget(self, action: #selector(HomeViewController.selected(_:)), forControlEvents: .TouchUpInside)
            iconView.addSubview(iconButton)
            
            let categoryLabel = UILabel(frame: CGRectMake(0, 18 + iconWidth, iconView.frame.width, 18))
            categoryLabel.text = pickerData[i]
            categoryLabel.textAlignment = .Center
            
            /*Adjust font size for different devices*/
            if(device() == 5 || device() == 4 || device() == 0){
                categoryLabel.font = UIFont.systemFontOfSize(9)
            }else{
                categoryLabel.font = UIFont.systemFontOfSize(12)
            }
            
            /*Initialize the first category*/
            if(i == 0){
                categoryLabel.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)
            }
            categoryArr.append(categoryLabel)
            iconView.addSubview(categoryLabel)
            categoryView.addSubview(iconView)
        }
        
        /*Set up Widget ImageView*/
        widgetImageView =  UIImageView(frame: CGRectMake(0, TOP_VIEW_HEIGHT, SCREEN_WIDTH, IMAGE_VIEW_HEIGHT))
        widgetImageView.image = UIImage(named: "image1")
        scrollView.addSubview(widgetImageView)
        scrollViewHeight += IMAGE_VIEW_HEIGHT
        scrollHeaderHeight = scrollViewHeight
        header.setRefreshingTarget(self, refreshingAction: #selector(HomeViewController.refreshData))
        scrollView.addSubview(header)
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
        
        /*Set up Location Manager*/
        coreLocationManagerHome.delegate = self
        startUpdateLocation()
        
        /*Start loading datab*/
        loadData(searchByGender, cate: searchByCategory)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Get iCon*/
    func getImageName(index:Int) -> String {
        switch index {
            case 0: return "学术辅导"
            case 1: return "运动健身"
            case 2: return "美妆丽人"
            case 3: return "美食私厨"
            case 4: return "生活服务"
            default: return ""
        }
    }
    
    /*When user select one of the category icon*/
    func selected (sender: UIButton!) {
        widgetImageView.image = UIImage(named: "image\(sender.tag + 1)")
        for i in 0 ... (pickerData.count - 1) {
            if(i == sender.tag){
                categoryArr[i].textColor =  UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)
            }else{
                categoryArr[i].textColor = UIColor.blackColor()
            }
        }
        SVProgressHUD.showWithStatus("加载中")
        homeObj.removeAllObjects()
        searchByCategory = pickerData[sender.tag]
        loadData(searchByGender, cate: searchByCategory)
    }
    
    /*Load data from server*/
    func loadData(gender:String? , cate: String?){
        homeObj.removeAllObjects()
        startUpdateLocation()
        let loadData = PFQuery(className:dataClass)
        if(gender != "A" && gender != nil){
            loadData.whereKey("gender", equalTo: gender!)
        }
        if(cate != "A" && cate != "T" && cate != nil){
            loadData.whereKey("category", equalTo: cate!)
        }
        loadData.includeKey("user")
        loadData.orderByDescending("createdAt")
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                for obj:AnyObject in objects!{
                    homeObj.addObject(obj)
                }
                self.header.endRefreshing()
                if(messageConnect == true){
                    SVProgressHUD.dismiss()
                }
                
                /*Data loading finish, start updating collection view*/
                self.loadCollectionView()
            } else {
                // Log details of the failure
                NSLog("首页数据加载失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        checkConnection()
    }
    
    /*Start loading collection view*/
    func loadCollectionView(){
        
        collectionView?.hidden = true
        scrollViewHeight = scrollHeaderHeight
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
        
        let cellHeight = CGFloat(186)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: SCREEN_WIDTH, height: cellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: CGRectMake(0, TOP_VIEW_HEIGHT + IMAGE_VIEW_HEIGHT, SCREEN_WIDTH, (cellHeight + layout.minimumLineSpacing) * CGFloat(homeObj.count - 1) + cellHeight), collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        
        collectionView!.registerNib(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.reloadData()
        scrollViewHeight += collectionView!.frame.height
        scrollView.addSubview(collectionView!)
        collectionView!.scrollEnabled = false
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
        
        //SVProgressHUD.dismiss()
    }
    
    
    /*Refreshing data*/
    func refreshData() {
        homeObj.removeAllObjects()
        collectionView?.hidden = true
        if(searchByGender == "M"){
            self.loadData(searchByGender, cate: searchByCategory)
        }else if(searchByGender == "F"){
            self.loadData(searchByGender, cate: searchByCategory)
        }else{
            self.loadData(searchByGender, cate: searchByCategory)
        }
    }
    
    /*Check if the device has been successfully connect to the Internet*/
    func checkConnection(){
        var r:Reachability?
        do {
            r = try Reachability.reachabilityForInternetConnection()
        } catch {
            NSLog("Unable to create Reachability")
        }
        r!.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    NSLog("Reachable via WiFi")
                } else {
                    NSLog("Reachable via Cellular")
                }
            }
        }
        r!.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("Not reachable")
                SVProgressHUD.dismiss()
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "无法连接，请检查网络", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            }
        }
        do {
            try r!.startNotifier()
        } catch {
            NSLog("Unable to start notifier")
        }
        r!.stopNotifier()
    }

    // MARK: - Core Location
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        /*Second check*/
        switch status {
        case .NotDetermined:
            coreLocationManagerHome.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            coreLocationManagerHome.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            coreLocationManagerHome.startUpdatingLocation()
            break
        case .Restricted:
            enabledLocationHome = false
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            enabledLocationHome = false
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            /*Should never run this line*/
            enabledLocationHome = false
            break
        }
    }
    
    /*Update the location*/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocation = locations[locations.count-1]
        if((location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) && location.horizontalAccuracy > 0){
            userLatitude = location.coordinate.latitude
            userLongitude = location.coordinate.longitude
            coreLocationManagerHome.stopUpdatingLocation()
        }else{
            coreLocationManagerHome.startUpdatingLocation()
        }
    }
    
    /*Check Location Status*/
    func startUpdateLocation(){
        /*Check Authorization*/
        if(authorization == CLAuthorizationStatus.NotDetermined) {
            /*This shouldn't be run*/
            coreLocationManagerHome.requestWhenInUseAuthorization()
        }else if(authorization == CLAuthorizationStatus.AuthorizedWhenInUse || authorization == CLAuthorizationStatus.AuthorizedAlways){
            /*Do update*/
            coreLocationManagerHome.startUpdatingLocation()
            enabledLocationHome = true
        }else{
            enabledLocationHome = false
        }
        
        /*Register Push Notification*/
        register_notification()
    }
    
    // MARK: - CollectionView
    
    /*Loading collection view cell*/
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:HomeCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? HomeCollectionViewCell)!
        
        if(homeObj[indexPath.row].objectForKey("comments_count") != nil){
            let comments_count = homeObj[indexPath.row].objectForKey("comments_count") as! Int
            cell.commentCount.text = String(comments_count)
        }else{
            cell.commentCount.text = "0"
        }
        cell.commectCountImage.image = UIImage(named: "回复数")
        
        let view_count = homeObj[indexPath.row].objectForKey("view_count") as! Int
        cell.viewCount.text = String(view_count)
        cell.viewCountImage.image = UIImage(named: "点击数")
        
        /*Load Post Owner's info*/
        let user = homeObj[indexPath.row].objectForKey("user") as! PFUser
        cell.nickName.text = (user.objectForKey("nick_name") as? String)! + "  " + (homeObj[indexPath.row].objectForKey("title") as? String)!
        
        cell.price.text = "$" + (homeObj[indexPath.row].objectForKey("price") as? String)! + "/" + (homeObj[indexPath.row].objectForKey("unit") as? String)!

        cell.shortDescription.text = homeObj[indexPath.row].objectForKey("description") as? String
        let TopLine = UIView(frame: CGRectMake(0,0,cell.shortDescription.frame.width,0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.3).CGColor
        cell.shortDescription.addSubview(TopLine)
        
        cell.profileImage.image = UIImage(named: "空头像")

        /*Loading feature image*/
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
        if(homeObj[indexPath.row].objectForKey("location") != nil){
            if((homeObj[indexPath.row].objectForKey("enabledLocation_newPost") != nil) && (homeObj[indexPath.row].objectForKey("enabledLocation_newPost") as! Bool) == true){
                let user_location = CLLocation(latitude: userLatitude, longitude: userLongitude)
                if let point = homeObj[indexPath.row].objectForKey("location") as? PFGeoPoint{
                    let temp = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    let distance = user_location.distanceFromLocation(temp)
                    cell.location.text = homeObj[indexPath.row].objectForKey("city") as! String + " · " + distance_calc(distance)
                }else{
                    cell.location.text = homeObj[indexPath.row].objectForKey("city") as? String
                }
            }else{
                cell.location.text = homeObj[indexPath.row].objectForKey("city") as? String
            }
        }else{
            
            if(homeObj[indexPath.row].objectForKey("city") != nil){
                cell.location.text = homeObj[indexPath.row].objectForKey("city") as? String
            }else{
                cell.location.text = " "
            }
        }
        
        /*For iPhone 4 and iPhone 5, the third image should be hidden*/
        if(device() == 5 || device() == 4){
            cell.thumbnailImage3.hidden = true
        }
        
        /*Load thumbnail image*/
        var thumnail_image_arr = [PFFile]()
        thumnail_image_arr = homeObj[indexPath.row].objectForKey("thumbnail_image") as! Array
        
        /*if user upload 1 ~ 2 images*/
        if(thumnail_image_arr.count > 0 && thumnail_image_arr.count < 3){
            
            /*If user only upload one image*/
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
                /*If user upload 2 images*/
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
        }
        /*If user upload more than 3 images*/
        else if(thumnail_image_arr.count >= 3){
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
        return homeObj.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("objectId", equalTo:(homeObj[indexPath.row].objectId as String!))
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                
                /*Check whether the selected post is still exist*/
                if(temp.count > 0){
                    
                    /*Direct to detail page*/
                    SVProgressHUD.dismiss()
                    let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
                    let user = homeObj[indexPath.row].objectForKey("user") as! PFUser
                    
                    detail.objectId_detail = homeObj[indexPath.row].objectId as String!
                    detail.selected_nick_name = (user.objectForKey("nick_name") as? String)!
                    detail.hidesBottomBarWhenPushed = true
                    self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                    self.navigationController?.pushViewController(detail, animated: true)
                }else{
                    
                    /*The post has been deleted*/
                    self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            } else {
                /*Loading error*/
                NSLog("详情页面载入失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //MARK: UIButton Action
    
    @IBAction func newPost(sender: AnyObject) {
        /*Setup alert for photo selection type menu (take photo or choose existing photo)*/
        let optionMenu = UIAlertController(title: nil, message: "请先上传图片", preferredStyle: .ActionSheet)
        
        /*If user choose to pick existing photo*/
        let photoPickAction = UIAlertAction(title: "选择图片（最多5张）", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            /*Initial the DKimage picker*/
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 5
            
            /*Set action if user click cancel button*/
            pickerController.didCancel = { () in
                /*Cancel the action*/
            }
            
            /*Set action if user do select photo*/
            pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                
                /*If user does not choose any photo, dismiss the controller*/
                if(assets.count == 0){
                    return
                }
                
                /*Reset all the image arrays*/
                thumbnail_image_array.removeAllObjects()
                full_image_array.removeAllObjects()
                image_assets?.removeAll()
                
                /*Pass to a global array for thumbnail photo upload*/
                image_assets = assets
                
                /*Pass to a global array for fullsize photo upload (translate to PFFile)*/
                for i in 0 ... ((image_assets?.count)!-1){
                    let asset  = assets[i]
                    
                    /*Convert the image to JPEG Mode*/
                    let imageData_t = UIImageJPEGRepresentation((asset.fullScreenImage)! as UIImage, 0.1)
                    
                    let imageFile_t = PFFile (data:imageData_t!)
                    full_image_array.addObject(imageFile_t!)
                    
                    let size_t = CGSizeMake(150.0,150.0)
                    thumbnail_image_array.addObject(RBSquareImageTo(((asset.fullScreenImage)! as UIImage), size: size_t) as UIImage)
                }
                
                /*Direct to new_post page*/
                let new_post : PostNewNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier("post_new_nav") as! PostNewNavViewController
                isUpdate = false
                objectId = ""
                self.presentViewController(new_post, animated: true, completion: nil)
            }
            
            /*Present photo pick page*/
            self.presentViewController(pickerController, animated: true, completion:nil)
        })
        
        /*If user choose to take uew photo (Will implement in future)*/
        /*
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: {
        (alert: UIAlertAction!) -> Void in
        NSLog("拍照")
        })
        */
        
        /*If user choose to cancel*/
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
            /*Do nothing here*/
            
        })
        
        /*Add all actions*/
        optionMenu.addAction(photoPickAction)
        //optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        /*Present the option menu*/
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    @IBAction func search(sender: AnyObject) {
        
        let search : SearchPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("search") as! SearchPageViewController
        search.hidesBottomBarWhenPushed = true
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(search, animated: true)
    }
}
