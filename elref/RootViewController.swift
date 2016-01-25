import UIKit

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PollViewControllerDelegate {
    var drawerController: MMDrawerController!
    var cityId=NSUserDefaults.standardUserDefaults().integerForKey("cityId")
    let cityName=NSUserDefaults.standardUserDefaults().stringForKey("cityName")
    let userId=NSUserDefaults.standardUserDefaults().integerForKey("userId")
    var json:JSON=nil
    var polls:JSON=nil
    var Vid=(NSUserDefaults.standardUserDefaults().boolForKey("pollFirst") ? 1 : 0)
    var eye=(NSUserDefaults.standardUserDefaults().boolForKey("eye") ? 1 : 0)

    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var rootTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let slogan=NSUserDefaults.standardUserDefaults().stringForKey("defaultCitySlogan")
        navigationItem.title=slogan != nil && slogan != "" ? slogan : "Электронный Референдум"
        
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        drawerButton.setTitleTextAttributes(attributes, forState: .Normal)
        //drawerButton.title=String.fontAwesomeIconWithName(.Bars)
        
        if cityId<=0 {
            delay(0.4) {
                let myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CityViewController") as! CityViewController
                let myNavController = UINavigationController(rootViewController: myViewController)
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.centerContainer!.centerViewController = myNavController
            }
            return
        } else {
            rootTable.delegate=self
            rootTable.dataSource=self
            if #available(iOS 8.0, *) {
                rootTable.rowHeight = UITableViewAutomaticDimension
                rootTable.estimatedRowHeight = 100.0;
            } else {
                rootTable.estimatedRowHeight = 250.0;
            }
            updatePolls()
        }
    }
    
    func updatePolls(){
        guard let server=NSUserDefaults.standardUserDefaults().stringForKey("server") else {
            self.view.makeToast("Связь потеряна", duration: 2.0, position: .Bottom)
            return
        }
        guard let keychain=KeychainWrapper.stringForKey("deviceId") else {
            self.view.makeToast("Связь потеряна2", duration: 2.0, position: .Bottom)
            return
        }
        let urlPath = server+"/mob/getPolls.php?deviceId=\(keychain)&Vid=\(Vid)&eye=\(eye)"
        //print("updateUserProfile запрос \(urlPath)")
        self.view.makeToastActivity(.Center)
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            dispatch_async(dispatch_get_main_queue(), {
                self.view.hideToastActivity()
            })
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                self.myToast("Ошибка",msg: "Нет связи с сервером\nПопробуйте позднее\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                self.polls = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                if self.polls != nil && self.polls["error"].stringValue=="" {
                    //print("polls: \(self.polls)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.rootTable.reloadData()
                    })
                } else {
                    self.myToast("Ошибка",msg: "Сервер передал неверные данные3\nПопробуйте позднее")
                }
                delay(5) {
                    self.updateUserProfile()
                }
                delay(2) {
                    self.getMessages()
                }
            }
        }).resume()
    }

    func getMessages(){
        guard let server=NSUserDefaults.standardUserDefaults().stringForKey("server") else {
            self.view.makeToast("Связь потеряна2", duration: 2.0, position: .Bottom)
            return
        }
        guard let deviceId=KeychainWrapper.stringForKey("deviceId") else {
            self.view.makeToast("Ошибка системы keychain 2", duration: 2.0, position: .Bottom)
            return
        }
        let urlPath = server+"/mob/getUser.php?deviceId=\(deviceId)&messages=1"
        //print("updateUserProfile запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                //self.myToast("Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("json: \(self.json)")
                if self.json != nil && self.json["error"].stringValue=="" {
                    if let msg=self.json["msg"].string where msg != "" {
                        self.myToast("Сообщение от системы", msg:msg)
                    }
                    //print("newCityId=\(self.json["city"].int), self.cityId=\(self.cityId)")
                    if let newCityId=self.json["city"].int where newCityId>0 {
                        if newCityId != self.cityId {
                            self.cityId=newCityId
                            NSUserDefaults.standardUserDefaults().setInteger(self.cityId, forKey: "cityId")
                            NSUserDefaults.standardUserDefaults().setObject("", forKey: "cityName")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            self.myToast("Сообщение от администрации", msg:"Вы переведены на другой город")
                        }
                    }
                } else {
                    //self.myToast("Сервер передал неверные данные3\nПопробуйте снова")
                }
            }
        }).resume()
    }

    func updateUserProfile(){
        guard let servv=NSUserDefaults.standardUserDefaults().stringForKey("server") else {
            self.view.makeToast("Связь потеряна3", duration: 2.0, position: .Bottom)
            return
        }
        let urlPath = servv+"/mob/getScores.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&noScores=1"
        //print("updateUserProfile запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                self.myToast("Ошибка", msg:"Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                if self.json != nil {
                    //print("json: \(self.json)")
                    for (key,subJson):(String, JSON) in self.json[0] {
                        if key != "pass" && key != "counter" && key != "cookie" && key != "deviceId" && key != "password"{
                            //print("saving profile: json(\(key)) = \(subJson)")
                            NSUserDefaults.standardUserDefaults().setObject(subJson.string, forKey: key)
                        }
                    }
                } else {
                    self.myToast("Ошибка", msg:"Сервер передал неверные данные3\nПопробуйте снова")
                }
            }
        }).resume()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count*2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tale=indexPath.row%2
        if (tale==0){
            tale=indexPath.row/2
            switch polls[tale]["Vid"].intValue {
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("Root1TableViewCell", forIndexPath: indexPath) as! Root1TableViewCell
                //var date=json[indexPath.row+1]["updated"].stringValue
                cell.title.text = polls[tale]["title"].stringValue//+" \n \n \n \n \n \n "
                if #available(iOS 8.0, *) {
                    cell.desc.adjustsFontSizeToFitWidth=false
                }else{
                    cell.desc.adjustsFontSizeToFitWidth=true
                    //cell.desc.minimumScaleFactor=0.5
                }
                cell.desc.text = polls[tale]["msg"].stringValue
                cell.price.text = "+"+polls[tale]["price"].stringValue
                cell.price.layer.cornerRadius=15
                cell.price.layer.masksToBounds=true
                cell.price.clipsToBounds=true
                cell.price.layer.borderWidth = 1
                cell.price.layer.borderColor = UIColor(red: 0, green: 134.0/255.0, blue: 7.0/255.0, alpha: 1).CGColor  //#007137
                cell.price.layer.masksToBounds = true
                
                cell.lockLabel.hidden = polls[tale]["done"].stringValue == "1" ? false : true
                cell.ico.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+polls[tale]["pic"].stringValue)!)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("Root2TableViewCell", forIndexPath: indexPath) as! Root1TableViewCell
                //var date=json[indexPath.row+1]["updated"].stringValue
                cell.title.text = polls[tale]["title"].stringValue//+" \n \n \n \n \n \n "
                if #available(iOS 8.0, *) {
                    cell.desc.adjustsFontSizeToFitWidth=false
                }else{
                    cell.desc.adjustsFontSizeToFitWidth=true
                    //cell.desc.minimumScaleFactor=0.5
                }
                cell.desc.text = polls[tale]["anons"].stringValue
                var ch:Character="\u{f0f6}"
                if var t=polls[tale]["type"].string where t != "" {
                    //cell.price.font = UIFont.fontAwesomeOfSize(30)
                    t=t.substringFromIndex(t.startIndex.advancedBy(1))
                    let c=Int(strtoul(t, nil, 16))
                    ch=Character(UnicodeScalar(c))
                    //print ("\(t) = \(c) = \(ch)")
                    //cell.price.text = t//"\u{f26e}"//String.fontAwesomeIconWithCode("\u{f26e}")
                }
                var s=""
                s.append(ch)
                cell.price.text = s
                cell.price.layer.cornerRadius=15
                cell.price.layer.masksToBounds=true
                cell.price.clipsToBounds=true
                
                //cell.lockLabel.hidden = true
                cell.date.text = "Новости от "+polls[tale]["datetime"].stringValue
                cell.ico.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+polls[tale]["pic"].stringValue)!)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Root0TableViewCell", forIndexPath: indexPath)// as! UITableViewCell
            return cell
        }
        /*
        {
        "id" : "25",
        "active" : "1",
        "city" : "6",
        "priority" : "0",
        "title" : "Мамам посвящается… Праздничная программа ко Дню матери",
        "favorite" : "0",
        "type" : "xf0f6",
        "anons" : "Праздник, посвященный Дню матери, состоится в администрации города 26 ноября.",
        "Vid" : "2",
        "pic" : "upload\/city6_1448220649",
        "price" : "0",
        "datetime" : "2015-11-22 22:31:06",
        "done" : "0",
        "commentsCount" : "0",
        "msg" : "Праздник, посвященный Дню матери, состоится в администрации города 26 ноября.",
        "commentsAllowed" : "0"
        },
        */
    }
    
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("didSelectRowAtIndexPath \(indexPath.row)")
        rootTable.deselectRowAtIndexPath(indexPath, animated:false)
        switch polls[indexPath.row]["Vid"].intValue {
        case 1: break
        default: break
        }
    }// */
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var tale=indexPath.row%2
        if (tale==0){
            if #available(iOS 8.0, *) {
                return UITableViewAutomaticDimension
            } else {
                return rootTable.estimatedRowHeight
            }
        } else {
            return 10
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "pollSegue" {
            if let selectedCell = sender as? Root1TableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                if polls[indexPath.row/2]["done"].stringValue == "1"{
                    self.myToast("Отказ",msg: "Опрос уже пройден")
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue! \(segue.identifier)")
        if segue.identifier == "newsSegue" {
            let newsDetailViewController = segue.destinationViewController as! NewsViewController
            if let selectedCell = sender as? Root1TableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                let tale=indexPath.row/2
                newsDetailViewController.poll=polls[tale]
                //print ("selected \(newsDetailViewController.poll)")
            }
        }
        if segue.identifier == "pollSegue" {
            let pollDetailViewController = segue.destinationViewController as! PollViewController
            if let selectedCell = sender as? Root1TableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                let tale=indexPath.row/2
                if polls[tale]["done"].stringValue != "1"{
                    pollDetailViewController.poll=polls[tale]
                    pollDetailViewController.delegate=self
                }
                //print ("selected \(pollDetailViewController.poll)")
            }
        }
    }

    func acceptData(data: AnyObject!) {
        if let d = data {
            if d as! Bool {
                //print("meed to reload polls");
                updatePolls()
            }
        }
        
    }

    @IBAction func drawerMenuButton(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
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

}

