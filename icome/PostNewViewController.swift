//
//  PostNewViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-15.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit
import Parse

class PostNewViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate ,CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var scrollViewHeight:CGFloat = 0
    let WIDTH = UIScreen.mainScreen().bounds.width
    
    var GallaryViewHeight:CGFloat = 150
    var InputViewHeight:CGFloat = 55
    var Gap:CGFloat = 5
    var DesViewHeight:CGFloat = 100
    var category_string = ""
    var isCategorySelected = false

    
    var TitleInput:UITextField?
    var DesTextView:KMPlaceholderTextView?
    var SkillTextView:KMPlaceholderTextView?
    var PriceInput:UITextField?
    var UnitInput:UITextField?
    var tapGesture:UITapGestureRecognizer?
    var Count:UILabel?
    var choice:UIButton?
    var Reselect:UIButton?
    var Submit:UIButton?
    var Cancel:UIButton?
    
    var CollectionView:UICollectionView?
    
    /*Default Content info*/
    var Title_Content = ""
    var Des_Content = ""
    var Price_Content = ""
    var Unit_Content = ""
    var Cate_Content = ""
    var Skill_Content = ""
    var CommentData:[AnyObject] = []
    var CommentCount = 0
    var view_count:Int = 0
    
    /*Core Location Define*/
    let coreLocationManager_newPost = CLLocationManager()
    var enabledLocation_newPost = true
    var latitude:Double = 0
    var longitude:Double = 0
    var city:String = ""
    
    var full_image_arr = [PFFile]()
    var thumbnail_image_arr = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Check the location*/
        location_update()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostNewViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture!)
        
        /*Check if this is a edit or new post*/
        if(isUpdate == false){
            UpdateView()
        }else{
            loadData()
        }
    }
    
    /*For editing mode only*/
    func loadData(){
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        /*Reset all image array*/
        thumbnail_image_array.removeAllObjects()
        full_image_array.removeAllObjects()
        full_image_view_array.removeAllObjects()
        
        /*Query from Parse class*/
        let loadData = PFQuery(className:dataClass)
        loadData.whereKey("objectId", equalTo: objectId)
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                
                let temp = NSMutableArray()
                for obj:AnyObject in objects!{
                    temp.addObject(obj)
                }
                
                if(temp.count > 0){
                    
                    /*Update content*/
                    self.Title_Content = temp.firstObject!.objectForKey("title") as! String
                    self.Des_Content = temp.firstObject!.objectForKey("description") as! String
                    self.Skill_Content = temp.firstObject!.objectForKey("skill") as! String
                    self.Price_Content = temp.firstObject!.objectForKey("price") as! String
                    self.Unit_Content = temp.firstObject!.objectForKey("unit") as! String
                    self.Cate_Content = temp.firstObject!.objectForKey("category") as! String
                    self.view_count = temp.firstObject!.objectForKey("view_count") as! Int
                    self.CommentCount = temp.firstObject!.objectForKey("comments_count") as! Int
                    self.CommentData = temp.firstObject!.objectForKey("comments") as! Array
                    self.full_image_arr = temp.firstObject!.objectForKey("full_image") as! Array
                    self.thumbnail_image_arr = temp.firstObject!.objectForKey("thumbnail_image") as! Array
                    
                    for i in 0 ... self.full_image_arr.count - 1 {
                        full_image_view_array.addObject(UIImage(named: "载入中")!)
                        let imageData: NSData = UIImagePNGRepresentation(UIImage(named: "载入中")!)!
                        let imageFile_t = PFFile (data:imageData)
                        full_image_array.addObject(imageFile_t!)
                        thumbnail_image_array.addObject(UIImage(named: "载入中")!)
                        self.LoadImage(i)
                    }
                    
                    SVProgressHUD.dismiss()
                    self.UpdateView()
                }else{
                    SVProgressHUD.dismiss()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                // Log details of the failure
                NSLog("详情页面载入失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
                SVProgressHUD.dismiss()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func UpdateView(){
        
        /*Update Title input view*/
        let TitleView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, InputViewHeight))
        TitleView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        TitleInput = UITextField(frame: CGRectMake(20, 10, WIDTH - 40, InputViewHeight - 20))
        TitleInput!.layer.backgroundColor = UIColor.whiteColor().CGColor
        TitleInput!.placeholder = "标题，例如：课程辅导，教健身"
        TitleInput?.font =  UIFont.systemFontOfSize(16)
        TitleInput!.text = Title_Content
        TitleInput!.layer.cornerRadius = 3
        TitleInput!.clipsToBounds = true
        
        TitleView.addSubview(TitleInput!)
        
        scrollViewHeight += InputViewHeight + Gap
        scrollView.addSubview(TitleView)
        
        
        /*Update Description Input View*/
        let DesView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, DesViewHeight))
        DesView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        DesTextView = KMPlaceholderTextView(frame: CGRectMake(20, 10, WIDTH - 40, 60))
        DesTextView!.layer.backgroundColor = UIColor.whiteColor().CGColor
        DesTextView!.placeholder = "描述你可以提供的服务内容／项目"
        DesTextView?.font = UIFont.systemFontOfSize(16)
        DesTextView!.text = Des_Content
        DesTextView!.layer.cornerRadius = 3
        DesTextView!.clipsToBounds = true
        
        DesTextView?.delegate = self
        
        /*Word count for description input view*/
        let Des_NSString = Des_Content as NSString
        Count = UILabel(frame: CGRectMake(WIDTH/2 , 15 + (DesTextView?.frame.height)!, WIDTH/2 - 20, 20))
        Count!.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)
        Count!.text = "您还可以输入\(300 - Des_NSString.length)字"
        Count!.textAlignment  = .Right
        Count!.font = UIFont.systemFontOfSize(12)
        
        
        DesView.addSubview(DesTextView!)
        DesView.addSubview(Count!)
        
        scrollViewHeight += DesViewHeight + Gap
        scrollView.addSubview(DesView)
        
        /*Update Skill input view*/
        let SkillView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, DesViewHeight))
        SkillView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        SkillTextView = KMPlaceholderTextView(frame: CGRectMake(20, 10, WIDTH - 40, 60))
        SkillTextView!.layer.backgroundColor = UIColor.whiteColor().CGColor
        SkillTextView!.placeholder = "描述你的技能／职业，例如：我是专业健身教练，XX专业毕业生"
        SkillTextView?.font = UIFont.systemFontOfSize(16)
        SkillTextView!.text = Skill_Content
        SkillTextView!.layer.cornerRadius = 3
        SkillTextView!.clipsToBounds = true
        
        SkillView.addSubview(SkillTextView!)
        
        scrollViewHeight += DesViewHeight + Gap
        scrollView.addSubview(SkillView)
        
        
        /*Update price input view*/
        let PriceView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, InputViewHeight))
        PriceView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        PriceInput = UITextField(frame: CGRectMake(20, 10, WIDTH / 2 - 30, InputViewHeight - 20))
        PriceInput!.layer.backgroundColor = UIColor.whiteColor().CGColor
        PriceInput!.placeholder = "价格 0 - 999"
        PriceInput?.font = UIFont.systemFontOfSize(16)
        PriceInput?.keyboardType = .PhonePad
        PriceInput!.text = Price_Content
        
        PriceInput!.layer.cornerRadius = 3
        PriceInput!.clipsToBounds = true
        
        /*Update unit input view*/
        UnitInput = UITextField(frame: CGRectMake(WIDTH / 2 + 10, 10, WIDTH / 2 - 30, InputViewHeight - 20 ))
        UnitInput!.layer.backgroundColor = UIColor.whiteColor().CGColor
        UnitInput!.placeholder = "单位，例如“每次”“每小时”"
        UnitInput?.font = UIFont.systemFontOfSize(16)
        
        UnitInput!.text = Unit_Content
        UnitInput!.layer.cornerRadius = 3
        UnitInput!.clipsToBounds = true
        
        PriceView.addSubview(PriceInput!)
        PriceView.addSubview(UnitInput!)
        
        scrollViewHeight += InputViewHeight + Gap
        scrollView.addSubview(PriceView)
        
        /*Update Category selection view*/
        let CateView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, InputViewHeight))
        CateView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        let CateInputView  =  UIView(frame: CGRectMake(20, 10, WIDTH - 40, InputViewHeight - 20))
        CateInputView.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        CateInputView.layer.cornerRadius = 3
        CateInputView.clipsToBounds = true
        
        /*Update category title label*/
        let title = UILabel(frame: CGRectMake(0, 0, WIDTH/2, CateInputView.frame.height))
        title.text = "服务类型"
        title.textColor = UIColor.lightGrayColor()
        title.font = UIFont.systemFontOfSize(16)
        
        /*Update category picker*/
        choice = UIButton(frame: CGRectMake(0, 0, CateInputView.frame.width - 5, CateInputView.frame.height))
        
        if(Cate_Content == ""){
            choice!.setTitle("请选择", forState: .Normal)
        }else{
            category_string = Cate_Content
            isCategorySelected = true
            choice!.setTitle(Cate_Content, forState: .Normal)
        }
        
        choice!.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: .Normal)
        choice!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        choice!.titleLabel!.font =  UIFont.systemFontOfSize(16)
        
        choice!.addTarget(self, action: #selector(PostNewViewController.select_cate(_:)), forControlEvents: .TouchUpInside)
        
        CateInputView.addSubview(choice!)
        CateInputView.addSubview(title)
        
        CateView.addSubview(CateInputView)
        
        scrollViewHeight += InputViewHeight + Gap
        scrollView.addSubview(CateView)
        
        
        /*Update Thumbnail image gallary*/
        let GallaryView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, GallaryViewHeight))
        GallaryView.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha:1.0).CGColor
        
        let CellHeight = CGFloat(90)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: CellHeight, height: CellHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Horizontal
        
        /*Initialize collection view*/
        CollectionView = UICollectionView(frame: CGRectMake(20, 20, WIDTH - 40, CellHeight), collectionViewLayout: layout)
        CollectionView!.dataSource = self
        CollectionView!.delegate = self
        
        CollectionView!.registerNib(UINib(nibName: "PostNewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "post_cell")
        CollectionView!.backgroundColor = UIColor.clearColor()
        CollectionView!.reloadData()
        
        CollectionView!.scrollEnabled = true
        GallaryView.addSubview(CollectionView!)
        
        
        /*Setup reselect image button*/
        let Reselect = UIButton(frame: CGRectMake(20 , 20 + (CollectionView?.frame.height)! + 10, WIDTH/2 - 20, 20))
        
        Reselect.setTitle("重新选择图片", forState: .Normal)
        Reselect.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        Reselect.titleLabel!.font =  UIFont.systemFontOfSize(12)
        Reselect.addTarget(self, action: #selector(PostNewViewController.reselect_image(_:)), forControlEvents: .TouchUpInside)
        Reselect.setTitleColor(UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0), forState: .Normal)
        GallaryView.addSubview(Reselect)
        
        scrollViewHeight += GallaryViewHeight
        scrollView.addSubview(GallaryView)
        
        
        /*Update submit and cancel button view*/
        let ButtonView = UIView(frame: CGRectMake(0, scrollViewHeight, WIDTH, 130))
        ButtonView.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        Submit = UIButton(frame: CGRectMake(50 , 40 , 100, 30))
        Submit!.setTitle("提交", forState: .Normal)
        Submit!.layer.backgroundColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        Submit!.titleLabel!.font =  UIFont.systemFontOfSize(16)
        Submit!.layer.cornerRadius = Submit!.frame.height / 2
        Submit!.clipsToBounds = true
        Submit!.addTarget(self, action: #selector(PostNewViewController.submit(_:)), forControlEvents: .TouchUpInside)
        
        
        Cancel = UIButton(frame: CGRectMake(WIDTH - 150 , 40 , 100, 30))
        
        Cancel!.setTitle("放弃", forState: .Normal)
        Cancel!.layer.backgroundColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0).CGColor
        Cancel!.titleLabel!.font =  UIFont.systemFontOfSize(16)
        Cancel!.layer.cornerRadius = Cancel!.frame.height / 2
        Cancel!.clipsToBounds = true
        Cancel!.addTarget(self, action: #selector(PostNewViewController.quit(_:)), forControlEvents: .TouchUpInside)
        
        ButtonView.addSubview(Submit!)
        ButtonView.addSubview(Cancel!)
        scrollViewHeight += 130
        scrollView.addSubview(ButtonView)
        
        scrollView.contentSize = CGSize(width: WIDTH, height: scrollViewHeight)
    
    }
    
    /*Hide keyboard when tag outside the input views*/
    func tap(gesture: UITapGestureRecognizer) {
        TitleInput!.resignFirstResponder()
        DesTextView!.resignFirstResponder()
        PriceInput!.resignFirstResponder()
        UnitInput!.resignFirstResponder()
        SkillTextView!.resignFirstResponder()
    }
    
    /*Hide keyboard*/
    func hideKeyboard() {
        TitleInput!.resignFirstResponder()
        DesTextView!.resignFirstResponder()
        PriceInput!.resignFirstResponder()
        UnitInput!.resignFirstResponder()
        SkillTextView!.resignFirstResponder()
    }
    
    /*Text view listener*/
    func textViewDidChange(textView: UITextView) {
        let desStr = self.DesTextView!.text as NSString
        var num = desStr.length
        if (num >= 300) {
            //self.para.text! = desStr.substringToIndex(60)
            num = 0
            self.Count!.text = "达到字数限制！"
            self.Count!.textColor = UIColor.redColor()
        }else{
            self.Count!.textColor = UIColor(red: 248.0/255.0, green: 143.0/255.0, blue: 51.0/255.0, alpha:1.0)
            self.Count!.text = "您还可以输入\(300-num)字"
        }
    }
    
    //MARK: Collection view
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(thumbnail_image_array.count > 0){
            return (thumbnail_image_array.count)
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:PostNewCollectionViewCell = (collectionView.dequeueReusableCellWithReuseIdentifier("post_cell", forIndexPath: indexPath) as? PostNewCollectionViewCell)!
        
        cell.layer.cornerRadius = 3
        cell.clipsToBounds = true
        
        if(isUpdate == false){
            if(thumbnail_image_array.count > 0){
                cell.Timage.image = thumbnail_image_array[indexPath.row] as? UIImage
                return cell
            }
        }else{
            if(thumbnail_image_array.count > 0 ){
                
                cell.Timage.image = UIImage(named: "载入中")
                let TImageFile = thumbnail_image_arr[indexPath.row]
                TImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            cell.Timage.image = UIImage(data: imageData)
                        }else{
                            NSLog("详情页图片格式转换失败")
                        }
                    }else{
                        NSLog("详情页图片载入失败")
                    }
                }
            }
        }
        return cell
    }
    
    /*Load the full image*/
    func LoadImage(index:Int){
        let ImageFile = full_image_arr[index]
        ImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    full_image_view_array.replaceObjectAtIndex(index, withObject: UIImage(data: imageData)!)
                    let imageData: NSData = UIImagePNGRepresentation(UIImage(data: imageData)!)!
                    let imageFile_t = PFFile (data:imageData)
                    full_image_array[index] = imageFile_t!
                }else{
                    NSLog("详情页图片格式转换失败")
                }
            }else{
                NSLog("详情页图片载入失败")
            }
        }
        
        let TImageFile = thumbnail_image_arr[index]
        TImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    thumbnail_image_array.replaceObjectAtIndex(index, withObject: UIImage(data: imageData)!)
                }else{
                    NSLog("详情页图片格式转换失败")
                }
            }else{
                NSLog("详情页图片载入失败")
            }
        }
    }

    /*Start select category*/
    func select_cate (sender: UIButton!) {
        hideKeyboard()
        ActionSheetMultipleStringPicker.showPickerWithTitle("请选择类别", rows: [
            pickerData,
            ], initialSelection: [0], doneBlock: {
                picker, values, indexes in
                
                self.choice!.setTitle(pickerData[Int(values[0] as! NSNumber)], forState: .Normal)
                self.category_string = pickerData[Int(values[0] as! NSNumber)]
                self.isCategorySelected = true
                return
                
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
    }
    
    /*Re-select image*/
    func reselect_image (sender: UIButton!) {
        image_assets?.removeAll()
        full_image_array.removeAllObjects()
        thumbnail_image_array.removeAllObjects()
        isUpdate = false
        
        /*Set up the picker view*/
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 5
        
        /*set action if user click cancel button*/
        pickerController.didCancel = { () in
            NSLog("didCancelled")
        }
        
        /*set action if user do select photo*/
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            NSLog("didSelectedAssets")
            
            /*If user does not choose any image, dsimiss the controller*/
            if(assets.count == 0){
                return
            }
            
            /*pass to a global array for thumbnail photo upload*/
            image_assets = assets
            
            /*pass to a global array for fullsize photo upload (translate to PFFile)*/
            for i in 0 ... ((image_assets?.count)!-1){
                let asset  = assets[i]
                
                let imageData_t = UIImageJPEGRepresentation((asset.fullScreenImage)! as UIImage, 0.1)
                
                let imageFile_t = PFFile (data:imageData_t!)
                full_image_array.addObject(imageFile_t!)
                
                let size_t = CGSizeMake(150.0,150.0)
                thumbnail_image_array.addObject(RBSquareImageTo(((asset.fullScreenImage)! as UIImage), size: size_t) as UIImage)
                
            }
            self.CollectionView!.reloadData()
        }
        self.presentViewController(pickerController, animated: true, completion:nil)
    
    }
    
    /*Update location info*/
    func location_update(){
        /*Enable location*/
        coreLocationManager_newPost.delegate = self
        coreLocationManager_newPost.desiredAccuracy = kCLLocationAccuracyBest
        
        /*Check Authorization*/
        if(authorization == CLAuthorizationStatus.NotDetermined) {
            /*This shouldn't be run*/
            coreLocationManager_newPost.requestWhenInUseAuthorization()
        }else if(authorization == CLAuthorizationStatus.AuthorizedWhenInUse || authorization == CLAuthorizationStatus.AuthorizedAlways){
            /*Do update*/
            coreLocationManager_newPost.startUpdatingLocation()
            enabledLocation_newPost = true
        }else{
            enabledLocation_newPost = false
        }
    }
    
    /*Submit the post*/
    func submit (sender: UIButton!) {
        location_update()
        
        /*Validate input*/
        let titleStr = self.TitleInput!.text! as NSString
        let num_titleStr = titleStr.length
        
        if(TitleInput!.text?.isEmpty == true || TitleInput!.text == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "标题不能为空", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
            
        }
        
        if(num_titleStr > 8){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "标题过长", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        /*Error checking*/
        if(PriceInput!.text?.isEmpty == true || PriceInput!.text == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_PRICE, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        let Pattern = "^\\d{1,3}$"
        let matcher = MyRegex(Pattern)
        if (matcher.match(PriceInput!.text!) == false) {
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "价格输入错误", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        if(UnitInput!.text?.isEmpty == true || UnitInput!.text == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_UNIT, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
            
        }
        
        let desStr = self.UnitInput!.text! as NSString
        let num = desStr.length
        
        if(num > 4){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "单位过长", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        if(DesTextView!.text?.isEmpty == true || DesTextView!.text == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_DESCRIPTION, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        if(SkillTextView!.text?.isEmpty == true || SkillTextView!.text == ""){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_EMPTY_DESCRIPTION, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        let desStr_para = self.DesTextView!.text! as NSString
        let num_para = desStr_para.length
        
        if(num_para > 300){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "服务描述过长", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        let skillStr_para = self.SkillTextView!.text! as NSString
        let num_skill = skillStr_para.length
        
        if(num_skill > 300){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "技能描述过长", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        if(isCategorySelected == false) {
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_PLEASE_SELECT_CATEGORY, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
            SVProgressHUD.dismiss()
            return
        }
        
        /*Do submit*/
        submit_new()
        
    }
    
    /*this function will check the existing post by the current user in Parse and delete it*/
    func submit_new (){
        let query = PFQuery(className:dataClass)
        query.includeKey("user")
        query.whereKey("user", equalTo:(PFUser.currentUser())!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for obj in objects! {
                    obj.deleteInBackground()
                }
                self.update_new()
            } else {
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_POST_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    /*Do the update*/
    func update_new(){
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        SVProgressHUD.show()
        
        let description = DesTextView!.text
        let price_new = PriceInput!.text
        let unit_new = UnitInput!.text
        let skill = SkillTextView!.text
        
        /*upload data*/
        let newPost = PFObject(className:dataClass)
        
        /*Upload city*/
        if(authorization == CLAuthorizationStatus.AuthorizedWhenInUse || authorization == CLAuthorizationStatus.AuthorizedAlways){
            
            let point = PFGeoPoint(latitude: latitude, longitude: longitude)
            newPost["location"] = point
            
            if(city != ""){
                newPost["city"] = city
            }else {
                newPost["city"] = PFUser.currentUser()?.valueForKey("city")
            }
        }else{
            newPost["city"] = PFUser.currentUser()?.valueForKey("city")
        }
        
        newPost["title"] = TitleInput!.text
        newPost["enabledLocation_newPost"] = enabledLocation_newPost
        newPost["gender"] = PFUser.currentUser()?.valueForKey("gender")
        newPost["user"] = PFUser.currentUser()
        newPost["description"] = description
        newPost["skill"] = skill
        newPost["price"] = price_new
        newPost["unit"] = unit_new
        newPost["category"] = category_string
        newPost["view_count"] = view_count
        newPost["comments"] = CommentData
        newPost["comments_count"] = CommentCount
        
        var thumbnail_data_arr = [PFFile]()
        var full_data_arr = [PFFile]()
        var image_size_arr = [NSDictionary]()
        
        /*If is a edit, reupload the old images*/
        if(isUpdate == true){
            for i in 0 ... full_image_view_array.count - 1 {
               var image_size = [String: CGFloat]()
                let image = full_image_view_array[i] as! UIImage
                image_size["height"] = image.size.height
                image_size["width"] = image.size.width
                image_size_arr.append(image_size as NSDictionary)
                
                let imageData_t = UIImagePNGRepresentation((thumbnail_image_array[i] as! UIImage))
                let imageFile_t = PFFile (data:imageData_t!)
                thumbnail_data_arr.append(imageFile_t!)
                full_data_arr.append(full_image_array[i] as! PFFile)
            }
        }else{
            /*If is a new post, do the new upload*/
            /*transfer image to PFFile*/
            for  i in 0 ... ((image_assets?.count)!-1){
                var image_size = [String: CGFloat]()
                let asset  = image_assets![i]
                
                let image = asset.fullScreenImage as UIImage!
                image_size["height"] = image.size.height
                image_size["width"] = image.size.width
                image_size_arr.append(image_size as NSDictionary)
                
                let imageData_t = UIImagePNGRepresentation((thumbnail_image_array[i] as! UIImage))
                let imageFile_t = PFFile (data:imageData_t!)
                thumbnail_data_arr.append(imageFile_t!)
                full_data_arr.append(full_image_array[i] as! PFFile)
            }
        }
        
        newPost["thumbnail_image"] = thumbnail_data_arr
        newPost["full_image"] = full_data_arr
        newPost["image_size"] = image_size_arr
        
        /*upload to Parse*/
        newPost.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                /*Reset everything and dismiss the controller*/
                image_assets?.removeAll()
                full_image_array.removeAllObjects()
                thumbnail_image_array.removeAllObjects()
                SVProgressHUD.dismiss()
                isUpdate = false
                objectId = ""
                self.dismissViewControllerAnimated(true, completion: nil)
                
            } else {
                self.presentViewController(show_alert_one_button(ERROR_ALERT, message: ERROR_POST_FAIL, actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
    }

    // MARK: - Core Location
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        /*Second check*/
        switch status {
        case .NotDetermined:
            coreLocationManager_newPost.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse:
            coreLocationManager_newPost.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            coreLocationManager_newPost.startUpdatingLocation()
            break
        case .Restricted:
            enabledLocation_newPost = false
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            enabledLocation_newPost = false
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            /*Should never run this line*/
            enabledLocation_newPost = false
            break
        }
    }
    
    /*Update location*/
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1]
        if((location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) && location.horizontalAccuracy > 0){
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            /*Request the city info*/
            CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
                if (error != nil) {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    self.city = "Unknown"
                    return
                }
                if placemarks!.count != 0 {
                    let pm = placemarks![0] as CLPlacemark
                    self.getLocationInfo(pm)
                } else {
                    print("Problem with the data received from geocoder")
                    self.city = "Unknown"
                }
            })
            coreLocationManager_newPost.stopUpdatingLocation()
        }else{
            coreLocationManager_newPost.startUpdatingLocation()
        }
        
    }
    
    /*Get the city info*/
    func getLocationInfo(placemark: CLPlacemark) {
        coreLocationManager_newPost.stopUpdatingLocation()
        if(placemark.locality != nil){
            city = placemark.locality!
        }else {
            city = "Unknown"
        }
    }
    
    /*this function will be triggered when user click quit button*/
    func quit(sender: UIButton!) {
        let alert = UIAlertController(title: ALERT, message: "亲，真的要放弃吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let action_reselect = UIAlertAction(title: "放弃",style: UIAlertActionStyle.Default, handler: back_to_main)
        alert.addAction(action_reselect)
        let action_cancel = UIAlertAction(title: "继续发布",style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action_cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*back to main page*/
    func back_to_main (alert: UIAlertAction!) {
        thumbnail_image_array.removeAllObjects()
        full_image_array.removeAllObjects()
        image_assets?.removeAll()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
