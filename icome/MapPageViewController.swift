//
//  MapPageViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2015-12-25.
//  Copyright © 2015 iCome. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapPageViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let map_obj = NSMutableArray()
    
    /*Initialize laititude and longitude*/
    var latitude:Double = 0
    var longitude:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*Set up Delegate*/
        mapView.delegate = self
        
        latitude = userLatitude
        longitude = userLongitude
        
        /*Check whether the variables have been passed in*/
        if(longitude == 0.0 && latitude == 0.0){
            self.presentViewController(show_alert_one_button(ERROR_ALERT, message: "获取地理位置信息失败，请稍后重试", actionButton: ERROR_ALERT_ACTION), animated: true, completion: nil)
        }else{
            /*Set up Region*/
            setRegion()
            
            LoadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        /*Setup the navigation bar*/
        navigationItem.title = "附近的人"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Load data from server*/
    func LoadData(){
        
        let loadData = PFQuery(className:dataClass)
        loadData.includeKey("user")
        loadData.orderByDescending("createdAt")
        loadData.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                for obj:AnyObject in objects!{
                    self.map_obj.addObject(obj)
                }
                
                self.updateMap()
            } else {
                // Log details of the failure
                NSLog("首页数据加载失败")
                NSLog("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    /*Set user's location*/
    func setRegion(){
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude,longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.05,longitudeDelta: 0.05)), animated: true)
    }
    
    /*Update map annotations*/
    func updateMap(){
        for obj in map_obj {
            if(obj.objectForKey("location") != nil){
                
                let user = obj.objectForKey("user") as! PFUser
                let ImageFile = user.objectForKey("featured_image")  as! PFFile
                ImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            let temp_annotation = JPSThumbnail()
                            
                            temp_annotation.image = UIImage(data:imageData)
                            temp_annotation.title = obj.objectForKey("title") as! String
                            temp_annotation.subtitle = obj.objectForKey("description") as! String
                            
                            let point = obj.objectForKey("location") as! PFGeoPoint
                            temp_annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                            temp_annotation.disclosureBlock = {
          
                                //direct to detail page
                                let detail : DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("detail") as! DetailViewController
                                detail.objectId_detail = obj.objectId as String!
                                detail.selected_nick_name = (user.objectForKey("nick_name") as? String)!
                                detail.hidesBottomBarWhenPushed = true
                                self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
                                self.navigationController?.pushViewController(detail, animated: true)
                            }
                            self.mapView.addAnnotation(JPSThumbnailAnnotation(thumbnail: temp_annotation))
                        }else{
                            NSLog("图片格式转换失败")
                        }
                    }else{
                        NSLog("图片加载失败")
                    }
                }
            }
        }
    }

    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        (view as? JPSThumbnailAnnotationViewProtocol)?.didSelectAnnotationViewInMap(mapView)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        (view as? JPSThumbnailAnnotationViewProtocol)?.didDeselectAnnotationViewInMap(mapView)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return (annotation as? JPSThumbnailAnnotationProtocol)?.annotationViewInMap(mapView)
    }

}
