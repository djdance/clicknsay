import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    let userId=NSUserDefaults.standardUserDefaults().integerForKey("userId")
    let profileKeys:[String] = ["email","username","avatarPic","date","gender","family","kids","district","address0","address2","work",""];
    let profileTitles:[String] = ["Электронная почта","Имя","Аватар","Год рождения","Пол","Семейное положение","Количество детей","Округ","На какой улице вы живёте","На какой улице вы работаете","Род деятельности",""];
    let profileSelL:[String] = ["","","","","Женский","Неженат/незамужем","","","","","",""];
    let profileSelR:[String] = ["","","","","Мужской","Женат/замужем","","","","","",""];
    let profilePlaceholders:[String] = ["пример@пример.рф","Иван Иванович Иванов","","1978","","","0","","","","Руководитель, учащийся безработный...",""];
    var profileValues:[String] = ["","","","","","","","","","","",""];
    /*
    0 - текст
    1 - чекбокс
    2 - картинка
    3 - цифра
    4 - кнопка отправить
    */
    let profileTypes:[Int] = [0,0,2,3,1,1,3,0,0,0,0,4];
    let imagePickerController = UIImagePickerController()
    var avatarPic: UIImage?
    var isNewAvatar=false
    
    
    
    func changedValue(cell:UITableViewCell) {
        //print("changedValue")
        if profileTypes[cell.tag]==1{
            let cell1=cell as! ProfileCheckboxTableViewCell
            //print("new value1 \(cell1.checkbox.on) for row \(cell.tag)=\(profileKeys[cell.tag])")
            profileValues[cell.tag]=cell1.checkbox.on ? "1":"0"
        } else if profileTypes[cell.tag]==0 || profileTypes[cell.tag]==3{
            let cell1=cell as! ProfileTextTableViewCell
            //print("new value0 \(cell1.textEdit.text) for row \(cell.tag)=\(profileKeys[cell.tag])")
            profileValues[cell.tag]=cell1.textEdit.text!
        }
    }

    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var cityButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Профиль"
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        drawerButton.setTitleTextAttributes(attributes, forState: .Normal)
        cityButton.setTitleTextAttributes(attributes, forState: .Normal)
        //drawerButton.title=String.fontAwesomeIconWithName(.Bars)
        let cache=Shared.imageCache
        cache.fetch(URL: NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/upload/user\(userId)_t")!).onSuccess { image in
            self.avatarPic=image
            //print("cache fetched");
            NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: "avatarPic")
        }
        

        var filled=true
        
        for (index, key) in profileKeys.enumerate() {
            let type=profileTypes[index]
            if type==2 {
                if let imgData = NSUserDefaults.standardUserDefaults().dataForKey(key) {
                    if let image = UIImage(data: imgData){
                        avatarPic = image
                    }
                } else{
                    filled=false
                }
            } else if type != 4 {
                if let s = NSUserDefaults.standardUserDefaults().stringForKey(key) {
                    profileValues[index]=s
                } else {
                    filled=false
                }
            }
        }
        profileTable.delegate=self
        profileTable.dataSource=self
        if (!filled){
            //https://github.com/scalessec/Toast-Swift
            self.view.makeToast("Заполните профиль!\nПолучите дополнительные баллы!", duration: 2.0, position: .Center)
        }
        
       
    }

    @IBAction func saveButton(sender: UIButton) {
        var q=JSON([:])
        for (index, key) in profileKeys.enumerate() {
            //print("index=\(index), key=\(key), value=\(profileValues[index])");
            let type=profileTypes[index]
            if type==2 && avatarPic != nil {
                let imageData = UIImagePNGRepresentation(avatarPic!)
                NSUserDefaults.standardUserDefaults().setObject(imageData, forKey: key)
            } else if type != 4 {
                let v=profileValues[index]
                let c=v.characters.count
                switch key {
                case "email": if c>0 && c<2 {
                        myToast("Ошибка", msg: "Нет емейла")
                        return;
                    } else if c>0 {
                        //let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
                        let emailRegex = "[a-zа-яё0-9._-]+@[a-zа-яё0-9._-]+\\.+[a-zа-яё0-9._-]+"
                        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(v) {
                            myToast("Ошибка", msg: "Некорректный email")
                            return;
                        }
                    }
                case "username": if c<2 {
                    myToast("Ошибка", msg: "Введите имя")
                    return;
                    }
                case "phone": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный телефон")
                    return;
                    }
                case "date": if c>0 && c<4 {
                    myToast("Ошибка", msg: "Некорректная дата")
                    return;
                    }
                case "address0": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный адрес 1")
                    return;
                    }
                case "address1": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный адрес 2")
                    return;
                    }
                case "address2": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный адрес 3")
                    return;
                    }
                case "district": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный округ")
                    return;
                    }
                case "addresswork": if c>0 && c<5 {
                    myToast("Ошибка", msg: "Некорректный род деятельности")
                    return;
                    }
                default: break
                }
                NSUserDefaults.standardUserDefaults().setObject(v, forKey: key)
                q[key].string=v
            }
        }
        //print ("q=\(q)")
        if q != nil {
            let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/updateUser.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&profile=1"
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
            
            sender.enabled=false
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
                    if q == nil || (q != nil && q["error"].isExists()) {
                        self.myToast("Ошибка",msg: "Невозможно передать данные\nПопробуйте позже или измените поля\n\n\(q["error"].string!)")
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), {
                            self.view.makeToast("Профиль записан", duration: 2.0, position: .Center)
                        })
                    }
                }
            }).resume()
        }
        
        //save image
        if avatarPic != nil {
            //let imageData = UIImagePNGRepresentation(avatarPic!)
            let imageData = UIImageJPEGRepresentation(avatarPic!,0.1)
            if imageData != nil {
                UIApplication.sharedApplication().networkActivityIndicatorVisible=true
                let av = UIActivityIndicatorView()
                av.frame=CGRectMake(UIScreen.mainScreen().bounds.width/2-10,UIScreen.mainScreen().bounds.height-75,20, 20)
                av.backgroundColor=UIColor.clearColor()
                av.color=UIColor.greenColor()
                av.startAnimating()
                self.view.addSubview(av)
                
                let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/updateUser.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&loadPic=1"
                let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
                
                request.HTTPMethod="POST"
                let boundary:String="-------------------21212222222222222222222"
                let body=NSMutableData()
                body.appendData(NSString(format:"--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(NSString(format:"Content-Disposition:form-data;name=\"image\";filename=\"image.jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(NSString(format:"Content-Type:image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                body.appendData(imageData!)
                body.appendData(NSString(format:"\r\n--\(boundary)--\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
                request.HTTPBody=body
                
                //let que=NSOperationQueue()  // -> sendAsynchronousRequest(request, queue: que, completionHandler:
                NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:  {data, response, error -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible=false
                    dispatch_sync(dispatch_get_main_queue(), {
                        av.stopAnimating()
                        av.removeFromSuperview()
                    })
                    //print("dataTaskWithRequest done")
                    //print("response=\(response)")
                    if (error != nil || data == nil) {
                        print("error: \(error != nil ? error?.localizedDescription : "nope")")
                    } else {
                        //print("data=\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                        var  s=NSString(data: data!, encoding: NSUTF8StringEncoding)!
                        //s=s.stringByReplacingOccurrencesOfString("\n",withString: "")
                        //let s="{\"res\": \"Warning\"}"
                        //let s="{'res': 'Warning'}"
                        //let json = JSON.parse(s as String)//(s)
                        //let json1 = JSON(data: s.dataUsingEncoding(NSUTF8StringEncoding)!)
                        //let json2 = JSON.parse(s as String)
                        //print("json=\(json["res"].string), json1=\(json1["res"].string), json2=\(json2["res"].string)")
                        //let res=json["res"].string
                        //print("res=\(res)")
                        /*if let res1=json["res"].string {
                        print("res1=\(res1)")
                        } else {
                        print("data=\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                        }// */
                        if #available(iOS 8.0, *) {
                            if s.containsString("error"){
                                self.myToast("Ошибка",msg: "Невозможно залить фото на сервер\nПопробуйте позже или измените снимок")
                            }
                        }
                    }
                }).resume()
            }
        }
        sender.enabled=true
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //NSLog("cellForRowAtIndexPath");
        switch profileTypes[indexPath.row] {
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCheckboxTableViewCell", forIndexPath: indexPath) as! ProfileCheckboxTableViewCell
            cell.label.text = profileTitles[indexPath.row]
            cell.leftLabel.text = profileSelL[indexPath.row]
            cell.leftLabel.sizeToFit()
            cell.rightLabel.text = profileSelR[indexPath.row]
            cell.rightLabel.sizeToFit()
            cell.checkbox.setOn(profileValues[indexPath.row]=="1", animated: false)
            cell.tag=indexPath.row
            cell.controller = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileImageTableViewCell", forIndexPath: indexPath) as! ProfileImageTableViewCell
            cell.label.text = profileTitles[indexPath.row]
            if avatarPic == nil {
                //print("tableView: avatarPic==nil")
                cell.foto.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/upload/user\(userId)_t")!)
            } else {
                //print("tableView: avatarPic ok!")
                cell.foto.image=avatarPic;
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileButtonTableViewCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileTextTableViewCell", forIndexPath: indexPath) as! ProfileTextTableViewCell
            cell.label.text = profileTitles[indexPath.row]
            cell.textEdit.placeholder=profilePlaceholders[indexPath.row]
            cell.textEdit.text=profileValues[indexPath.row]
            cell.tag=indexPath.row
            cell.controller = self
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //print("estimatedHeightForRowAtIndexPath")
        switch profileTypes[indexPath.row] {
        case 2:
            return 310
        default:
            return 90
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if profileTypes[indexPath.row]==2 {
            fotoTap_()
        }
    }// */
    
    func myToast(title: String, msg: String){
        let alert = UIAlertView(title: title
            , message: msg
            , delegate: self
            , cancelButtonTitle: "OK")
        dispatch_async(dispatch_get_main_queue(), {
            alert.show()
        })
    }
    func fotoTap_(){
        //if #available(iOS 8.0, *) {
        Popups.SharedInstance.ShowAlert(self, title: "Выберите источник", message: "Откуда взять ваш снимок?", buttons: ["Сфотографировать" , "Альбом"]) { (buttonPressed) -> Void in
            //print("buttonPressed=\(buttonPressed)")
            if buttonPressed == "Сфотографировать" {
                self.fotoTapProc(0)
            } else if buttonPressed == "Альбом" {
                self.fotoTapProc(1)
            }
        }
        //} else {
        //    fotoTapProc(0)
        //}
    }
    @IBAction func fotoTap(sender: UITapGestureRecognizer) {
        fotoTap_()
    }
    func fotoTapProc(mode: Int){
        imagePickerController.allowsEditing = true
        if mode==0 && UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePickerController.sourceType = .Camera
        } else {
            imagePickerController.sourceType = .PhotoLibrary
        }
        imagePickerController.delegate = self
        navigationController?.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //print("rdidFinishPickingMediaWithInfo")
        
        //var videoTemp = info[UIImagePickerControllerMediaURL] as! NSURL
        //videoPath = videoTemp.relativePath
        //UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil)
        
        avatarPic = info[UIImagePickerControllerEditedImage] as? UIImage
        isNewAvatar=true
        //avatarPic = info[UIImagePickerControllerOriginalImage] as? UIImage
        for (index, type) in profileTypes.enumerate() { //for var index in 0..<profileTitles.count
            if type==2 {
                profileTable.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)

    }

    @IBAction func backButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    @IBAction func cityButton(sender: AnyObject) {
        let myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CityViewController") as! CityViewController
        let myNavController = UINavigationController(rootViewController: myViewController)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = myNavController

    }
}
