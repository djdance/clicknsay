//
//  LeftSideViewController.swift
//  elref
//
//  Created by Dj Dance on 04.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class LeftSideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuItemsTable: UITableView!
    
    var menuItems:[String] = ["Опросы","Новости","Призы","Мои баллы","Мой профиль","Настройки","Справка","Отзыв"];
    var menuIcons:[String] = ["\u{f046}","\u{f1ea}","\u{f06b}","\u{f158}","\u{f007}","\u{f013}","\u{f059}","\u{f003}"];

    override func viewDidLoad() {
        super.viewDidLoad()
        menuItemsTable.delegate=self
        menuItemsTable.dataSource=self
        //print("LeftSideViewController viewDidLoad")
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("rows: \(menuItems.count)")
        return menuItems.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let mycell = tableView.dequeueReusableCellWithIdentifier("drawerCell", forIndexPath: indexPath) as! drawerTableViewCell
        mycell.drawerItem.text = menuItems[indexPath.row]
        mycell.ico.text=menuIcons[indexPath.row]//FontAwesome.Magic.rawValue;
        //String.fontAwesomeIconWithCode("fa-github")!
        //mycell.drawerItem.font=UIFont.fontAwesomeOfSize(50)
        return mycell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        var myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController

        switch indexPath.row {
        case 0:
            (myViewController as! RootViewController).Vid=1
        case 1:
            (myViewController as! RootViewController).Vid = -1
        case 2:
            myViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ShopViewController") as! ShopViewController
        case 3:
            myViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ScoreViewController") as! ScoreViewController
        case 4:
            myViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        case 5:
            if #available(iOS 8.0, *) {
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            } else {
                // Fallback on earlier versions
                let sendMailErrorAlert = UIAlertView(title: "Ошибка"
                    , message: "У вас старая система, настройки недоступны. Обновитесь"
                    , delegate: self
                    , cancelButtonTitle: "OK")
                sendMailErrorAlert.show()
            }

        case 6:
            myViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TermsViewController") as! TermsViewController
        case 7:
            myViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        default: break
        }
        let myNavController = UINavigationController(rootViewController: myViewController)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = myNavController
        if indexPath.row != 5 {
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        }
    }

}
