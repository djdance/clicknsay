//
//  NewsViewController.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    var poll:JSON=nil
    var json:JSON=nil

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var ico: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var шапка: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("NewsViewController loaded");
        шапка.title="Новости"
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)

        if poll != nil {
            updateUI()
        } else {
            шапка.title="Новости: загрузка..."
            date.text=""
            titleLabel.text=""
            descLabel.text=""
        }
        updatePoll()
    }
    
    func updateUI(){
        шапка.title="Новости: \(poll["title"])"
        date.text=poll["datetime"].stringValue
        titleLabel.text=poll["title"].stringValue
        titleLabel.sizeToFit()
        descLabel.text=poll["msg"].stringValue
        descLabel.sizeToFit()
        if poll["pic"].stringValue.containsString("http"){
            ico.hnk_setImageFromURL(NSURL(string: poll["pic"].stringValue)!)
        } else {
            ico.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+poll["pic"].stringValue+"_t")!)
        }
    }

    func updatePoll(){
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getPollItems.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&pollId=-\(poll["id"].stringValue)&ios=1"
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
                //self.myToast("Ошибка",msg: "Нет связи с сервером\nПопробуйте позднее\n\n\(error != nil ? error!.localizedDescription : "no data")")
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Ошибка", message: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")", buttons: ["Повтор","Отмена"]) { (buttonPressed) -> Void in
                        if buttonPressed == "Повтор" {
                            self.updatePoll()
                        }
                    }
                })

            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("news: json: \(self.json)")
                if self.json != nil {
                    self.poll=self.json[0]
                    dispatch_async(dispatch_get_main_queue(), {
                        self.updateUI()
                    })
                } else {
                    self.myToast("Ошибка",msg: "Нет данных с сервера")
                }
            }
        }).resume()
    }

    @IBAction func swipe(sender: UISwipeGestureRecognizer) {
    }
    @IBAction func backButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
