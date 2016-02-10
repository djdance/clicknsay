//
//  CityViewController.swift
//  elref
//
//  Created by Dj Dance on 09.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class CityViewController: UIViewController,/* UIPickerViewDelegate, UIPickerViewDataSource,*/ SWComboxViewDelegate {
    @IBOutlet weak var backButton: UIBarButtonItem!
    //@IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var comboView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    
    var json:JSON=nil
    var selectedIdx = -1
    let defaultCityId=NSUserDefaults.standardUserDefaults().integerForKey("defaultCityId")
    var cityId=NSUserDefaults.standardUserDefaults().integerForKey("cityId")


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title=NSUserDefaults.standardUserDefaults().stringForKey("app_name")
        //print("defaultCityId=\(defaultCityId), cityId=\(cityId) ")
        
        // Do any additional setup after loading the view.
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)
        //picker.delegate=self
        //picker.dataSource=self
        self.setupCombox()
        registerButton.enabled=false
        
        if cityId>0 {
            loadCities()
        } else {
            checkExistedUser()
        }
    }

    func checkExistedUser(){
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getUser.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)"
        //print("checkExistedUser запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                //self.myToast("Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Ошибка", message: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")", buttons: ["Повтор","Отмена"]) { (buttonPressed) -> Void in
                        if buttonPressed == "Повтор" {
                            self.checkExistedUser()
                        }
                    }
                })

            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                if self.json != nil {
                    //print("json: \(self.json)")
                    if self.json["error"]=="no user"{
                        self.loadCities()
                    } else if self.json["error"] != nil && self.json["error"] != "" {
                        self.myToast("Сервер передал неверные данные 2")
                    } else {
                        //print("city=\(self.json["city"].string)")
                        //print("username=\(self.json["username"].string)")
                        var username=""
                        if let un=self.json["username"].string {
                            username=un
                        }
                        //print("С возвращением!")
                        dispatch_async(dispatch_get_main_queue(), {
                            Popups.SharedInstance.ShowAlert(self, title: "С возвращением, \(username)!", message: "Мы обнаружили, что вы переустановили программу. Ваш город - \(self.json["cityName"].string!).", buttons: ["Да" , "Нет"]) { (buttonPressed) -> Void in
                                //print("buttonPressed=\(buttonPressed)")
                                if buttonPressed == "Да" {
                                    self.cityId=self.json["city"].intValue
                                    NSUserDefaults.standardUserDefaults().setInteger(self.cityId, forKey: "cityId")
                                    NSUserDefaults.standardUserDefaults().setObject(self.json["cityName"].string!, forKey: "cityName")
                                    NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                                    //print("city \(self.cityId) записан")
                                    self.finish()
                                } else if buttonPressed == "Нет" {
                                    self.loadCities()
                                }
                            }
                        })
                    }
                } else {
                    self.myToast("Сервер передал неверные данные3\nПопробуйте снова")
                }
            }
        }).resume()
    }
    
    func loadCities(){
        registerButton.enabled=false
        selectedIdx = -1
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getCity.php"
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("loadCities completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil  || data == nil {
                //self.myToast("Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Ошибка", message: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")", buttons: ["Повтор","Отмена"]) { (buttonPressed) -> Void in
                        if buttonPressed == "Повтор" {
                            self.loadCities()
                        }
                    }
                })

            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("загружено городов: \((self.json != nil ? self.json.count : 0))")
                //print("cities json=\(self.json.rawString()!)")
                if self.json != nil {
                    /*
                    json[1] = {
                    "showPage4" : "false",
                    "noProduction" : "false",
                    "cityPhoto" : "http:\/\/orgcom.ru\/cities\/lipetsk\/fon1.jpg",
                    "nameT" : "lipetsk",
                    "noCarousel" : "false",
                    "name" : "Лии\320пецк",
                    "title" : "Открытый Липецк",
                    "host" : "openlipetsk.ru",
                    "showPage3" : "false",
                    "id" : "6",
                    "slogan" : "Выбирай, каким быть твоему городу!"
                    }
                    */
                    dispatch_async(dispatch_get_main_queue(), {
                        //self.picker.reloadAllComponents()
                        self.setupCombox()
                        self.registerButton.enabled=true
                    })
                } else {
                    self.myToast("Сервер передал неверные данные\nПопробуйте снова")
                }
            }
        }).resume()
    }
    
    func setupCombox(){
        var selIdx = 0
        var helper: SWComboxTitleHelper
        helper = SWComboxTitleHelper()
        var list = [String]()
        if self.json != nil {
            for (index,subJson):(String, JSON) in self.json {
                //print("json[\(index)][\"id\"].int = \(subJson)")//["id"].int)")
                list.append(subJson["name"].string!)
                if Int(subJson["id"].string!)==cityId || Int(subJson["id"].string!)==defaultCityId{
                    selIdx = Int(index)!
                }
            }
        } else {
            list.append("Загрузка городов...")
        }
        //print("selIdx=\(selIdx)")
        var comboxView:SWComboxView
        comboxView = SWComboxView.loadInstanceFromNibNamedToContainner(comboView)!
        comboxView.bindData(list, comboxHelper: helper, seletedIndex: selIdx, comboxDelegate: self, containnerView: self.view)
        selectedIdx=selIdx
    }
    func selectedAtIndex(index:Int, combox: SWComboxView){
        if json != nil {
            //print("json[\(index)] = \(json[index]["name"].string)")
            selectedIdx=index
            registerButton.enabled=true
        }
    }
    func tapComboxToOpenTable(combox: SWComboxView){
    }
    /* // MARK: handle picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return json != nil ? 1 : 0
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return json != nil ? json.count : 0
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return json != nil ? json[row]["name"].string : ""
    }// */

    
    @IBAction func termsLabel(sender: AnyObject) {
        let myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TermsViewController") as! TermsViewController
        let myNavController = UINavigationController(rootViewController: myViewController)
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = myNavController
    }
    

    @IBAction func registerButton(sender: UIButton) {
        //print("registerButton, selectedIdx=\(selectedIdx)")
        if json != nil && selectedIdx >= 0 {
            cityId=Int(json[selectedIdx]["id"].string!)!
            let cityName=json[selectedIdx]["name"].string!
            registerButton.enabled=false
            if defaultCityId>0 && defaultCityId != cityId {
                myToast("Эта версия программы работает только с городом "+NSUserDefaults.standardUserDefaults().stringForKey("defaultCityName")!)
                return
            }
            let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/updateUser.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)"+"&cityId=\(cityId)"
            //print("registerButton запрос \(urlPath)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=true
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
                //print("registerButton completed")
                UIApplication.sharedApplication().networkActivityIndicatorVisible=false
                if error != nil {
                    self.myToast("Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
                } else {
                    NSUserDefaults.standardUserDefaults().setInteger(self.cityId, forKey: "cityId")
                    NSUserDefaults.standardUserDefaults().setObject(cityName, forKey: "cityName")
                    //print("city \(self.cityId) записан")
                    self.finish()
                }
                }).resume()
        }
    }
    
    func finish(){
        dispatch_async(dispatch_get_main_queue(), {
            let myViewController:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RootViewController") as! RootViewController
            let myNavController = UINavigationController(rootViewController: myViewController)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.centerContainer!.centerViewController = myNavController
        })
    }
    
    @IBAction func backButton(sender: AnyObject) {
        if cityId<=0 {
            myToast("Пожалуйста, зарегистрируйтесь")
            return
        }
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func myToast(msg: String){
        let alert = UIAlertView(title: "Ошибка"
            , message: msg
            , delegate: self
            , cancelButtonTitle: "OK")
        dispatch_async(dispatch_get_main_queue(), {
            alert.show()
        })
    }

}
