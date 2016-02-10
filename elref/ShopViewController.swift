//
//  ShopViewController.swift
//  elref
//
//  Created by Dj Dance on 14.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var shopTable: UITableView!
    var json:JSON=nil
    var money=0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Призы и бонусы"
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)
        navigationItem.leftBarButtonItem = backButton
        if let m=NSUserDefaults.standardUserDefaults().stringForKey("money"){
            money=Int(m)!
        }
        //money=350 //debug

        shopTable.delegate=self
        shopTable.dataSource=self
        
        updateGifts(0)
    }

    func updateGifts(giftId: Int){
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getGifts.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&giftId=\(giftId)"
        //print("updateGifts запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                //self.myToast("Ошибка", msg:"Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Ошибка", message: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")", buttons: ["Повтор","Отмена"]) { (buttonPressed) -> Void in
                        if buttonPressed == "Повтор" {
                            self.updateGifts(giftId)
                        }
                    }
                })
            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("json: \(self.json), count=\(self.json.count)")
                if self.json != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.shopTable.reloadData()
                    })
                } else {
                    self.myToast("Ошибка", msg:"Сервер передал неверные данные3\nПопробуйте снова")
                }
            }
        }).resume()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue!")
        if segue.identifier == "giftSegue" {
            let giftDetailViewController = segue.destinationViewController as! GiftViewController
            if let selectedCell = sender as? ShopTableViewCell {
                let indexPath = shopTable.indexPathForCell(selectedCell)!
                let giftId = json[indexPath.row]["id"].intValue
                //print ("selected \(json[indexPath.row])")
                giftDetailViewController.giftId = giftId
                giftDetailViewController._title=json[indexPath.row]["title"].stringValue
                giftDetailViewController._desc=json[indexPath.row]["description"].stringValue
                giftDetailViewController._price=json[indexPath.row]["price"].stringValue
            }
        } else {
            //
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShopTableViewCell", forIndexPath: indexPath) as! ShopTableViewCell
        //var date=json[indexPath.row+1]["updated"].stringValue
        cell.title.text = json[indexPath.row]["title"].stringValue+" \n \n \n \n \n \n "
        cell.desc.text = json[indexPath.row]["description"].stringValue
        
        let priceS : String = json[indexPath.row]["price"].stringValue
        cell.price.text = priceS
        if let price=Int(priceS) {
            if money>=price {
                cell.price.backgroundColor=UIColor(red: 242.0/255.0, green: 206.0/255.0, blue: 0, alpha: 1)  //золотой
            } else {
                cell.price.backgroundColor=UIColor.lightGrayColor()
            }
        }
        cell.ico.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+json[indexPath.row]["pic"].stringValue)!)
        return cell
    }

    
    
    func myToast(title: String, msg: String){
        let alert = UIAlertView(title: title
            , message: msg
            , delegate: self
            , cancelButtonTitle: "OK")
        dispatch_async(dispatch_get_main_queue(), {
            alert.show()
        })
    }
    
    @IBAction func backButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
}
