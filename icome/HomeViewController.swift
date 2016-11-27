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
    let SCREEN_WIDTH = UIScreen.main.bounds.width
    let TOP_VIEW_HEIGHT = (UIScreen.main.bounds.width / 5) + 10
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
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.show()
        }
        
        /*Inital collection view*/
        collectionView?.isHidden = true
        scrollView.layer.backgroundColor = UIColor.clear.cgColor
        let categoryView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: TOP_VIEW_HEIGHT))
        categoryView.layer.backgroundColor = UIColor.blue.cgColor
        scrollViewHeight += TOP_VIEW_HEIGHT
        scrollView.addSubview(categoryView)
        
        /*Add Top Button*/
        for i in 0 ... 4 {
            let x = (SCREEN_WIDTH / 5) * CGFloat(i)
            let iconView = UIView(frame: CGRect(x: x,y: 0,width: SCREEN_WIDTH/5,height: TOP_VIEW_HEIGHT))
            iconView.layer.backgroundColor = UIColor.white.cgColor
            
            /*Draw Top icon*/
            let iconWidth = (SCREEN_WIDTH / 5) - CGFloat(30)
            let iconButton = UIButton(frame: CGRect(x: (SCREEN_WIDTH/10) - (iconWidth/2), y: 12, width: iconWidth, height: iconWidth))
            iconButton.layer.cornerRadius = iconWidth/2
            iconButton.clipsToBounds = true
            iconButton.tag = i
            let imageName = getImageName(i)
            iconButton.setImage(UIImage(named: imageName), for: UIControlState())
            iconButton.addTarget(self, action: #selector(HomeViewController.selected(_:)), for: .touchUpInside)
            iconView.addSubview(iconButton)
            
            let categoryLabel = UILabel(frame: CGRect(x: 0, y: 18 + iconWidth, width: iconView.frame.width, height: 18))
            categoryLabel.text = pickerData[i]
            categoryLabel.textAlignment = .center
            
            /*Adjust font size for different devices*/
            if(device() == 5 || device() == 4 || device() == 0){
                categoryLabel.font = UIFont.systemFont(ofSize: 9)
            }else{
                categoryLabel.font = UIFont.systemFont(ofSize: 12)
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
        widgetImageView =  UIImageView(frame: CGRect(x: 0, y: TOP_VIEW_HEIGHT, width: SCREEN_WIDTH, height: IMAGE_VIEW_HEIGHT))
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
    func getImageName(_ index:Int) -> String {
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
    func selected (_ sender: UIButton!) {
        widgetImageView.image = UIImage(named: "image\(sender.tag + 1)")
        for i in 0 ... (pickerData.count - 1) {
            if(i == sender.tag){
                categoryArr[i].textColor =  UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)
            }else{
                categoryArr[i].textColor = UIColor.black
            }
        }
        SVProgressHUD.show(withStatus: "加载中")
        homeObj.removeAllObjects()
        searchByCategory = pickerData[sender.tag]
        loadData(searchByGender, cate: searchByCategory)
    }
    
    /*Load data from server*/
    func loadData(_ gender:String? , cate: String?){
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
        loadData.order(byDescending: "createdAt")
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                for obj:AnyObject in objects!{
                    homeObj.add(obj)
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
        
        collectionView?.isHidden = true
        scrollViewHeight = scrollHeaderHeight
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
        
        let cellHeight = CGFloat(186)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: SCREEN_WIDTH, height: cellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: TOP_VIEW_HEIGHT + IMAGE_VIEW_HEIGHT, width: SCREEN_WIDTH, height: (cellHeight + layout.minimumLineSpacing) * CGFloat(homeObj.count - 1) + cellHeight), collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        
        collectionView!.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.reloadData()
        scrollViewHeight += collectionView!.frame.height
        scrollView.addSubview(collectionView!)
        collectionView!.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
        
        //SVProgressHUD.dismiss()
    }
    
    
    /*Refreshing data*/
    func refreshData() {
        homeObj.removeAllObjects()
        collectionView?.isHidden = true
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
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi() {
                    NSLog("Reachable via WiFi")
                } else {
                    NSLog("Reachable via Cellular")
                }
            }
        }
        r!.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                NSLog("Not reachable")
                SVProgressHUD.dismiss()
                self.present(show_alert_one_button(ERROR_ALERT, message: "无法连接，请检查网络", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        /*Second check*/
        switch status {
        case .notDetermined:
            coreLocationManagerHome.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            coreLocationManagerHome.startUpdatingLocation()
            break
        case .authorizedAlways:
            coreLocationManagerHome.startUpdatingLocation()
            break
        case .restricted:
            enabledLocationHome = false
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
        if(authorization == CLAuthorizationStatus.notDetermined) {
            /*This shouldn't be run*/
            coreLocationManagerHome.requestWhenInUseAuthorization()
        }else if(authorization == CLAuthorizationStatus.authorizedWhenInUse || authorization == CLAuthorizationStatus.authorizedAlways){
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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:HomeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell)!
        
        if((homeObj[indexPath.row] as AnyObject).object(forKey: "comments_count") != nil){
            let comments_count = (homeObj[indexPath.row] as AnyObject).object(forKey: "comments_count") as! Int
            cell.commentCount.text = String(comments_count)
        }else{
            cell.commentCount.text = "0"
        }
        cell.commectCountImage.image = UIImage(named: "回复数")
        
        let view_count = (homeObj[indexPath.row] as AnyObject).object(forKey: "view_count") as! Int
        cell.viewCount.text = String(view_count)
        cell.viewCountImage.image = UIImage(named: "点击数")
        
        /*Load Post Owner's info*/
        let user = (homeObj[indexPath.row] as AnyObject).object(forKey: "user") as! PFUser
        cell.nickName.text = (user.object(forKey: "nick_name") as? String)! + "  " + ((homeObj[indexPath.row] as AnyObject).object(forKey: "title") as? String)!
        
        cell.price.text = "$" + ((homeObj[indexPath.row] as AnyObject).object(forKey: "price") as? String)! + "/" + ((homeObj[indexPath.row] as AnyObject).object(forKey: "unit") as? String)!

        cell.shortDescription.text = (homeObj[indexPath.row] as AnyObject).object(forKey: "description") as? String
        let TopLine = UIView(frame: CGRect(x: 0,y: 0,width: cell.shortDescription.frame.width,height: 0.5))
        TopLine.layer.backgroundColor =  UIColor(red: 154.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha:0.3).cgColor
        cell.shortDescription.addSubview(TopLine)
        
        cell.profileImage.image = UIImage(named: "空头像")

        /*Loading feature image*/
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
        if((homeObj[indexPath.row] as AnyObject).object(forKey: "location") != nil){
            if(((homeObj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") != nil) && ((homeObj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") as! Bool) == true){
                let user_location = CLLocation(latitude: userLatitude, longitude: userLongitude)
                if let point = (homeObj[indexPath.row] as AnyObject).object(forKey: "location") as? PFGeoPoint{
                    let temp = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    let distance = user_location.distance(from: temp)
                    cell.location.text = (homeObj[indexPath.row] as AnyObject).object(forKey: "city") as! String + " · " + distance_calc(distance)
                }else{
                    cell.location.text = (homeObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
                }
            }else{
                cell.location.text = (homeObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }
        }else{
            
            if((homeObj[indexPath.row] as AnyObject).object(forKey: "city") != nil){
                cell.location.text = (homeObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }else{
                cell.location.text = " "
            }
        }
        
        /*For iPhone 4 and iPhone 5, the third image should be hidden*/
        if(device() == 5 || device() == 4){
            cell.thumbnailImage3.isHidden = true
        }
        
        /*Load thumbnail image*/
        var thumnail_image_arr = [PFFile]()
        thumnail_image_arr = (homeObj[indexPath.row] as AnyObject).object(forKey: "thumbnail_image") as! Array
        
        /*if user upload 1 ~ 2 images*/
        if(thumnail_image_arr.count > 0 && thumnail_image_arr.count < 3){
            
            /*If user only upload one image*/
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
                /*If user upload 2 images*/
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
        }
        /*If user upload more than 3 images*/
        else if(thumnail_image_arr.count >= 3){
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
        return homeObj.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("objectId", equalTo:((homeObj[indexPath.row] as AnyObject).objectId as String!))
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.add(obj)
                }
                
                /*Check whether the selected post is still exist*/
                if(temp.count > 0){
                    
                    /*Direct to detail page*/
                    SVProgressHUD.dismiss()
                    let detail : DetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
                    let user = homeObj[indexPath.row].object(forKey: "user") as! PFUser
                    
                    detail.objectId_detail = homeObj[indexPath.row].objectId as String!
                    detail.selected_nick_name = (user.object(forKey: "nick_name") as? String)!
                    detail.hidesBottomBarWhenPushed = true
                    self.navigationController!.navigationBar.tintColor = UIColor.white
                    self.navigationController?.pushViewController(detail, animated: true)
                }else{
                    
                    /*The post has been deleted*/
                    self.present(show_alert_one_button(ERROR_ALERT, message: "该发布已被删除，请重新刷新", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            } else {
                /*Loading error*/
                NSLog("详情页面载入失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
                self.present(show_alert_one_button(ERROR_ALERT, message: "页面载入失败", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //MARK: UIButton Action
    
    @IBAction func newPost(_ sender: AnyObject) {
        /*Setup alert for photo selection type menu (take photo or choose existing photo)*/
        let optionMenu = UIAlertController(title: nil, message: "请先上传图片", preferredStyle: .actionSheet)
        
        /*If user choose to pick existing photo*/
        let photoPickAction = UIAlertAction(title: "选择图片（最多5张）", style: .default, handler: {
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
                    full_image_array.add(imageFile_t!)
                    
                    let size_t = CGSize(width: 150.0,height: 150.0)
                    thumbnail_image_array.add(RBSquareImageTo(((asset.fullScreenImage)! as UIImage), size: size_t) as UIImage)
                }
                
                /*Direct to new_post page*/
                let new_post : PostNewNavViewController = self.storyboard?.instantiateViewController(withIdentifier: "post_new_nav") as! PostNewNavViewController
                isUpdate = false
                objectId = ""
                self.present(new_post, animated: true, completion: nil)
            }
            
            /*Present photo pick page*/
            self.present(pickerController, animated: true, completion:nil)
        })
        
        /*If user choose to take uew photo (Will implement in future)*/
        /*
        let takePhotoAction = UIAlertAction(title: "拍照", style: .Default, handler: {
        (alert: UIAlertAction!) -> Void in
        NSLog("拍照")
        })
        */
        
        /*If user choose to cancel*/
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
            /*Do nothing here*/
            
        })
        
        /*Add all actions*/
        optionMenu.addAction(photoPickAction)
        //optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        /*Present the option menu*/
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func search(_ sender: AnyObject) {
        
        let search : SearchPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "search") as! SearchPageViewController
        search.hidesBottomBarWhenPushed = true
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController?.pushViewController(search, animated: true)
    }
}
