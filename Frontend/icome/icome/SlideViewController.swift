//
//  SlideViewController.swift
//  icome
//
//  Created by Tuo Zhang on 2016-02-10.
//  Copyright © 2016 iCome. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    var pageViewController : UIPageViewController!
    var imageArr:NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        /*Request images*/
        imageArr = arrInit()
        
        /*Initialize the page controller*/
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("pagecontroll") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        /*Setup the starting point*/
        let start = self.viewControllerAtIndex(0)
        let viewControllers = NSArray (object: start)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0,0, self.view.frame.width, self.view.frame.height)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Request images for diffrent devices*/
    func arrInit () -> NSArray {
        switch device() {
            case 4 :
                return NSArray(objects: "p41","p42","p43")
            case 5,6,7:
                return NSArray(objects: "p1","p2","p3")
            default:
                return NSArray(objects: "p1","p2","p3")
        }
    
    }
    
    /*Sliding listener*/
    func viewControllerAtIndex (index:Int) -> ContentViewController
    {
        if((self.imageArr.count == 0) || (index >= self.imageArr.count)){
            return ContentViewController()
        }
        
        let vc : ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("content") as! ContentViewController
        
        vc.imageName = self.imageArr[index] as! String
        vc.pageIndex = index
        
        return vc
    }
    
    //MARK: PageViewController
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound){
            return nil
        }
        
        index = index - 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            return nil
        }
        
        index = index + 1
        
        if (index == self.imageArr.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.imageArr.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
