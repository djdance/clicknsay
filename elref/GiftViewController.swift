//
//  GiftViewController.swift
//  elref
//
//  Created by Dj Dance on 15.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class GiftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var шапка: UINavigationItem!
    @IBOutlet weak var theTable: UITableView!
    var giftId=0
    var _title=""
    var _price=""
    var _desc=""
    var _ico=""
    var _banner=""
    var _bannerUrl=""
    var _instr=""
    var cell1height:CGFloat=300
    var cell2height:CGFloat=50
    var cell3height:CGFloat=50
    var cell4height:CGFloat=300
    var orderButtonEnabled=true

    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)

        theTable.delegate=self
        theTable.dataSource=self
        theTable.rowHeight = UITableViewAutomaticDimension
        theTable.estimatedRowHeight = 150.0;

        /*
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "orderGiftButton:" as Selector,
            name: "orderGiftButton",
            object: nil)// */
        
        шапка.title="Выбрать вознаграждение"//_title
        updateGifts(giftId)
        loadAd(giftId)
    }
    
    /*
    //NSNotificationCenter.defaultCenter().postNotificationName("orderGiftButton", object: nil)
    //func orderGiftButton(notification: NSNotification){}
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "orderGiftButton", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self) // Remove from all notifications being observed
        super.viewDidDisappear(animated)
    }// */
    
    func submitOrder(cell:UITableViewCell) {
        let cell=cell as! Gift3TableViewCell
        if cell.fio.text?.characters.count<=4 {
            myToast("Ошибка", msg: "Введите ФИО, имя или псевдоним")
            return
        }
        if cell.email.text?.characters.count<=4 {
            myToast("Ошибка", msg: "Введите email")
            return
        }
        if cell.pinEdit.text?.characters.count<4 {
            myToast("Ошибка", msg: "Введите пин-код")
            return
        }

        var q=JSON([:])
        q["giftId"].int=giftId
        q["fio"].string=cell.fio.text
        q["email"].string=cell.email.text
        q["pass"].string=cell.pinEdit.text
        
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/buyGift.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod="POST"
        do {
            try request.HTTPBody = q.rawData()
            //try request.HTTPBody =  NSJSONSerialization.dataWithJSONObject(q.dictionaryObject!)
        } catch {
            myToast("Ошибка",msg: "неизвестная ошибка 123")
            return
        }
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        orderButtonEnabled=false
        cell.submit.enabled=false
        //theTable.reloadData()
        NSUserDefaults.standardUserDefaults().setObject(cell.fio.text, forKey: "giftUsername")
        NSUserDefaults.standardUserDefaults().setObject(cell.email.text, forKey: "giftEmail")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //print("updateUser.php completed, data=\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil  || data == nil {
                self.myToast("Ошибка",msg: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                var  s=NSString(data: data!, encoding: NSUTF8StringEncoding)!
                s=s.stringByReplacingOccurrencesOfString("\n",withString: "")
                s=s.stringByReplacingOccurrencesOfString("'",withString: "\"")
                q = JSON.parse(s as String)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("q=\(q), data=\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                if q == nil {
                    self.myToast("Ошибка",msg: "Невозможно передать данные\nПопробуйте позже или измените поля")
                } else if !q["error"].isExists() {
                    self.myToast("Успешно!", msg: "Сертификат оформлен и отправлен вам на email")
                    let money=NSUserDefaults.standardUserDefaults().integerForKey("money")
                    if let price=Int(self._price){
                        NSUserDefaults.standardUserDefaults().setInteger(money-price , forKey: "money")
                    }
                } else if q["error"].stringValue.containsString("money"){
                    self.myToast("Нет баллов!",msg: "У вас недостаточно средств\nНадо \(self._price) быллов, а у вас оставалось \(NSUserDefaults.standardUserDefaults().stringForKey("money")!)")
                } else {
                    self.myToast("Ошибка",msg: "Невозможно передать данные\nПопробуйте позже или измените поля\n\n\(q["error"].string!)")
                }
            }
        }).resume()

    }
    
    func orderGiftButton(){//notification: NSNotification){
        //print("orderGiftButton")
        if cell3height<200 {
            cell3height=500
        } else {
            cell3height=50
        }
        theTable.reloadData()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        theTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
                var json:JSON=JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("json: \(self.json), count=\(self.json.count)")
                if json != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.шапка.title=json[0]["title"].stringValue
                        self._title=json[0]["title"].stringValue
                        self._desc=json[0]["description"].stringValue
                        self._instr=json[0]["instruction1"].stringValue+"\n"+json[0]["instruction2"].stringValue
                        self._price=json[0]["price"].stringValue
                        self._ico=NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+json[0]["pic"].stringValue
                        
                        self.theTable.reloadData()
                    })
                } else {
                    self.myToast("Ошибка", msg:"Сервер передал неверные данные3\nПопробуйте снова")
                }
            }
        }).resume()
    }
    
    func loadAd(giftId: Int){
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getAd.php?giftId=\(giftId)"
        //print("updateGifts запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                //self.myToast("Ошибка", msg:"Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                var jsonAd:JSON=JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("AD jsonAd: \(jsonAd), count=\(jsonAd.count)")
                if jsonAd != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self._banner=NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+jsonAd[0]["pic"].stringValue
                        self._bannerUrl=jsonAd[0]["url"].stringValue
                        self.theTable.reloadData()
                    })
                }
            }
        }).resume()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("Gift1TableViewCell", forIndexPath: indexPath) as! Gift1TableViewCell
            //cell.ico.hnk_setImageFromURL(NSURL(string: _ico)!)
            cell.ico.load(_ico)
            cell.titleLabel.text=_title+"\n"
            cell.descLabel.text=_desc+"\n"
            cell.priceLabel.text="  Стоимость \(_price) баллов   "
            if #available(iOS 8.0, *) {
                cell.titleLabel.adjustsFontSizeToFitWidth=false
                cell.descLabel.adjustsFontSizeToFitWidth=false
                cell.titleLabel.sizeToFit()
                cell.descLabel.sizeToFit()
            }else{
                cell.titleLabel.adjustsFontSizeToFitWidth=true
                cell.descLabel.adjustsFontSizeToFitWidth=true
            }
            cell1height=cell.contentView.height
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("Gift2TableViewCell", forIndexPath: indexPath) as! Gift2TableViewCell
            cell.instuctions=_instr
            //cell2height=cell.contentView.height
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("Gift3TableViewCell", forIndexPath: indexPath) as! Gift3TableViewCell
            //cell3height=cell.contentView.height
            cell.submit.enabled=orderButtonEnabled
            cell.controller=self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("Gift4TableViewCell", forIndexPath: indexPath) as! Gift4TableViewCell
            //print("_banner=\(_banner), w-h=\(cell.banner.width) - \(cell.banner.height)")
            if _banner != "" && cell.banner.height>0 && cell.banner.width>0 {
                //cell.banner.hnk_setImageFromURL(NSURL(string: _banner)!)
                cell.banner.load(_banner)
            }
            cell.bannerUrl=_bannerUrl
            cell.urlLabel.text="http://"+_bannerUrl
            cell4height=cell.contentView.height
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("Gift1TableViewCell", forIndexPath: indexPath) as! Gift1TableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            if #available(iOS 8.0, *) {
                return UITableViewAutomaticDimension
            } else {
                return max(self.view.height*0.5,cell1height) //return self.view.height*0.5
            }// */
            //return self.view.width*0.5+20
        case 1:
            return 30
            /*
            if #available(iOS 8.0, *) {
                return UITableViewAutomaticDimension
            } else {
                return max(50,cell2height) //return self.view.height*0.5
            }// */
            //http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights?rq=1
        case 2:
            return cell3height
            /*
            if #available(iOS 8.0, *) {
                return UITableViewAutomaticDimension
            } else {
                return max(500,cell3height) //return self.view.height*0.5
            }// */
        case 3:
            //if #available(iOS 8.0, *) {
            //    return UITableViewAutomaticDimension
            //} else {
                return max(300,cell4height) //return self.view.height*0.5
            //}
        default:
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("didSelectRowAtIndexPath \(indexPath.row)")
        theTable.deselectRowAtIndexPath(indexPath, animated:false)
        switch indexPath.row {
        case 1:
            Popups.SharedInstance.ShowAlert(self, title: "Инструкция", message: self._instr, buttons: ["Ок"]) { (buttonPressed) -> Void in
            }
        case 3:
            UIApplication.sharedApplication().openURL(NSURL(string: "http://"+_bannerUrl)!)
            //print ("click on banner! \(_bannerUrl)")
        default: break
        }
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
        dismissViewControllerAnimated(true, completion: nil)
    }


}
