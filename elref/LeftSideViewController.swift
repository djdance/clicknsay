//
//  LeftSideViewController.swift
//  elref
//
//  Created by Dj Dance on 04.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit
import RealmSwift


class LeftSideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuItemsTable: UITableView!
    
    var menuItems:[String] = ["START","My kids","Words","Howto","Settings","Buy","Newborn apps"];
    var menuIcons:[String] = ["\u{f046}","\u{f1ea}","\u{f06b}","\u{f158}","\u{f007}","\u{f013}","\u{f059}"];
    var kids : Results<Kids>!
    var currentKid = NSUserDefaults.standardUserDefaults().integerForKey("currentKid");

    override func viewDidLoad() {
        super.viewDidLoad()
        menuItemsTable.delegate=self
        menuItemsTable.dataSource=self
        //print("LeftSideViewController viewDidLoad")
        
        kids = uiRealm.objects(Kids)

    }

    override func viewDidAppear(animated: Bool) {
        currentKid = NSUserDefaults.standardUserDefaults().integerForKey("currentKid")
        menuItemsTable.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("rows: \(menuItems.count)")
        return menuItems.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let mycell = tableView.dequeueReusableCellWithIdentifier("drawerCell", forIndexPath: indexPath) as! drawerTableViewCell
        mycell.drawerItem.text = menuItems[indexPath.row]
        if indexPath.row==0 && currentKid>=0 {
            mycell.desc.text = kids[currentKid].name
        }
        mycell.ico.text=menuIcons[indexPath.row]//FontAwesome.Magic.rawValue;
        //String.fontAwesomeIconWithCode("fa-github")!
        //mycell.drawerItem.font=UIFont.fontAwesomeOfSize(50)
        return mycell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController

        switch indexPath.row {
        case 2:
            myViewController=self.storyboard?.instantiateViewControllerWithIdentifier("WordsViewController") as! WordsViewController
        case 4:
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        default: break
        }
        let myNavController = UINavigationController(rootViewController: myViewController)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = myNavController
        if indexPath.row != 4 {
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }

}
