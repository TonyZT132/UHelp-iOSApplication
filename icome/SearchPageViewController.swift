//
//  SearchPageViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-24.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class SearchPageViewController: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var scrollViewHeight:CGFloat = 0
    
    let SCREEN_WIDTH = UIScreen.main.bounds.width
    
    /*Core Location Defination*/
    var coreLocationManagerSearch = CLLocationManager()
    var enabledLocationSearch = true
    var collectionView:UICollectionView?
    var searchObj:NSMutableArray = NSMutableArray()
    var timer: Timer? = nil
    
    /*SearchBar*/
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width - 100 , height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Initialize Search Bar*/
        searchBar.placeholder = "请输入关键字"
        searchBar.delegate = self
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        /*Load CollectionView*/
        loadCollectionView()
        
        /*Set up Location Manager*/
        coreLocationManagerSearch.delegate = self
        startUpdateLocation()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    func loadData(){
        searchObj.removeAllObjects()
        startUpdateLocation()
        
        /*Setup Query*/
        let skill = PFQuery(className:dataClass)
        skill.whereKey("skill", contains: searchBar.text!)
        
        let title = PFQuery(className:dataClass)
        title.whereKey("title", contains: searchBar.text!)
        
        let description = PFQuery(className:dataClass)
        description.whereKey("description", contains: searchBar.text!)

        let loadData = PFQuery.orQuery(withSubqueries: [skill,title,description])
        loadData.includeKey("user")
        loadData.order(byDescending: "createdAt")
        
        loadData.findObjectsInBackground {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                for obj:AnyObject in objects!{
                    self.searchObj.add(obj)
                }
                
                if(messageConnect == true){
                    SVProgressHUD.dismiss()
                }
                
                if(self.searchObj.count == 0){
                    self.present(show_alert_one_button("提示", message: "什么也没有找到，换个关键词试试吧", actionButton: "好的"), animated: true, completion: nil)
                    self.searchBar.resignFirstResponder()
                }
                
                self.loadCollectionView()
                /*Data loading finish, start updating collection view*/
                
            } else {
                // Log details of the failure
                NSLog("首页数据加载失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func loadCollectionView(){
        
        collectionView?.isHidden = true
        scrollViewHeight = 0
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)

        let titleWidget = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40))
        titleWidget.layer.backgroundColor = UIColor.white.cgColor
        let titleLabel = UILabel(frame:CGRect(x: 15,y: 0, width: titleWidget.frame.width - 30 ,height: titleWidget.frame.height))
        titleLabel.text = "搜索结果"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        let botLine = UIView(frame: CGRect(x: 0,y: titleWidget.frame.height - 0.5 ,width: titleWidget.frame.width ,height: 0.5))
        botLine.layer.backgroundColor =  UIColor.black.cgColor
        
        scrollViewHeight += titleWidget.frame.height
        titleWidget.addSubview(titleLabel)
        titleWidget.addSubview(botLine)
        scrollView.addSubview(titleWidget)
        
        let cellHeight = CGFloat(186)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: SCREEN_WIDTH, height: cellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: scrollViewHeight, width: SCREEN_WIDTH, height: (cellHeight + layout.minimumLineSpacing) * CGFloat(searchObj.count - 1) + cellHeight), collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        
        collectionView!.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.reloadData()
        scrollViewHeight += collectionView!.frame.height
        scrollView.addSubview(collectionView!)
        collectionView!.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: scrollViewHeight)
    }
   
    /*When User click search Button*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadPage()
    }
    
    /*Reload the Entire View*/
    func reloadPage(){
        searchObj.removeAllObjects()
        collectionView?.reloadData()
        if(searchBar.text != nil && searchBar.text != ""){
            loadData()
        }
    }
    
    // MARK: - Core Location
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        /*Second check*/
        switch status {
        case .notDetermined:
            coreLocationManagerSearch.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            coreLocationManagerSearch.startUpdatingLocation()
            break
        case .authorizedAlways:
            coreLocationManagerSearch.startUpdatingLocation()
            break
        case .restricted:
            enabledLocationSearch = false
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            enabledLocationSearch = false
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            /*Should never run this line*/
            enabledLocationSearch = false
            break
        }
    }
    
    /*Update the location*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocation = locations[locations.count-1]
        if((location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) && location.horizontalAccuracy > 0){
            userLatitude = location.coordinate.latitude
            userLongitude = location.coordinate.longitude
            coreLocationManagerSearch.stopUpdatingLocation()
        }else{
            coreLocationManagerSearch.startUpdatingLocation()
        }
    }
    
    /*Check Location Status*/
    func startUpdateLocation(){
        /*Check Authorization*/
        if(authorization == CLAuthorizationStatus.notDetermined) {
            /*This shouldn't be run*/
            coreLocationManagerSearch.requestWhenInUseAuthorization()
        }else if(authorization == CLAuthorizationStatus.authorizedWhenInUse || authorization == CLAuthorizationStatus.authorizedAlways){
            /*Do update*/
            coreLocationManagerSearch.startUpdatingLocation()
            enabledLocationSearch = true
        }else{
            enabledLocationSearch = false
        }
    }
    
    //MARK: CollectionView
    
    /*Loading collection view cell*/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:HomeCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell)!
        
        if((searchObj[indexPath.row] as AnyObject).object(forKey: "comments_count") != nil){
            let comments_count = (searchObj[indexPath.row] as AnyObject).object(forKey: "comments_count") as! Int
            cell.commentCount.text = String(comments_count)
        }else{
            cell.commentCount.text = "0"
        }
        cell.commectCountImage.image = UIImage(named: "回复数")
        
        let view_count = (searchObj[indexPath.row] as AnyObject).object(forKey: "view_count") as! Int
        cell.viewCount.text = String(view_count)
        cell.viewCountImage.image = UIImage(named: "点击数")
        
        /*Load Post Owner's info*/
        let user = (searchObj[indexPath.row] as AnyObject).object(forKey: "user") as! PFUser
        cell.nickName.text = (user.object(forKey: "nick_name") as? String)! + "  " + ((searchObj[indexPath.row] as AnyObject).object(forKey: "title") as? String)!
        
        cell.price.text = "$" + ((searchObj[indexPath.row] as AnyObject).object(forKey: "price") as? String)! + "/" + ((searchObj[indexPath.row] as AnyObject).object(forKey: "unit") as? String)!
        
        cell.shortDescription.text = (searchObj[indexPath.row] as AnyObject).object(forKey: "description") as? String
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
        if((searchObj[indexPath.row] as AnyObject).object(forKey: "location") != nil){
            if(((searchObj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") != nil) && ((searchObj[indexPath.row] as AnyObject).object(forKey: "enabledLocation_newPost") as! Bool) == true){
                let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
                if let point = (searchObj[indexPath.row] as AnyObject).object(forKey: "location") as? PFGeoPoint{
                    let temp = CLLocation(latitude: point.latitude, longitude: point.longitude)
                    let distance = userLocation.distance(from: temp)
                    cell.location.text = (searchObj[indexPath.row] as AnyObject).object(forKey: "city") as! String + " · " + distance_calc(distance)
                }else{
                    cell.location.text = (searchObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
                }
            }else{
                cell.location.text = (searchObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }
        }else{
            
            if((searchObj[indexPath.row] as AnyObject).object(forKey: "city") != nil){
                cell.location.text = (searchObj[indexPath.row] as AnyObject).object(forKey: "city") as? String
            }else{
                cell.location.text = " "
            }
        }
        
        /*For iPhone 4 and iPhone 5, the third image should be hidden*/
        if(device() == 5 || device() == 4){
            cell.thumbnailImage3.isHidden = true
        }
        
        /*Load thumbnail image*/
        var thumnailImageArr = [PFFile]()
        thumnailImageArr = (searchObj[indexPath.row] as AnyObject).object(forKey: "thumbnail_image") as! Array
        
        /*if user upload 1 ~ 2 images*/
        if(thumnailImageArr.count > 0 && thumnailImageArr.count < 3){
            
            /*If user only upload one image*/
            if(thumnailImageArr.count == 1){
                cell.thumbnailImage1.image = UIImage(named: "载入中")
                cell.thumbnailImage2.isHidden = true
                cell.thumbnailImage3.isHidden = true
                
                thumnailImageArr[0].getDataInBackground {
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
                
                thumnailImageArr[0].getDataInBackground {
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
                
                thumnailImageArr[1].getDataInBackground {
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
        else if(thumnailImageArr.count >= 3){
            cell.thumbnailImage1.image = UIImage(named: "载入中")
            cell.thumbnailImage2.image = UIImage(named: "载入中")
            cell.thumbnailImage3.image = UIImage(named: "载入中")
            
            thumnailImageArr[0].getDataInBackground {
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
            
            thumnailImageArr[1].getDataInBackground {
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
            
            thumnailImageArr[2].getDataInBackground {
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
        return searchObj.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
        searchBar.resignFirstResponder()
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("objectId", equalTo:((searchObj[indexPath.row] as AnyObject).objectId as String!))
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
                    let user = self.searchObj[indexPath.row].object(forKey: "user") as! PFUser
                    
                    detail.objectId_detail = self.searchObj[indexPath.row].objectId as String!
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
    
    /*When User Click Cancel Button*/
    @IBAction func BackToMain(_ sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
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
