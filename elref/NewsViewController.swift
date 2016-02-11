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
    
    @IBOutlet weak var descLabel: FRHyperLabel!
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
        if let s=poll["pic"].string where s != "" {
            //print("ico=\(s)")
            //ico.hidden=false
            if s.containsString("http"){
                ico.hnk_setImageFromURL(NSURL(string: s)!)
            } else {
                ico.hnk_setImageFromURL(NSURL(string: NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/"+s+"_t")!)
            }
        } else {
            //print("ico hidden")
            //ico.hidden=true
        }
        if var s=poll["msg"].string where (s != "" && (s.containsString("[a") || s.containsString("http") || s.containsString("www."))) {
            //или же - textView.dataDetectorTypes = UIDataDetectorTypeLink;

            s = s.stringByReplacingOccurrencesOfString("=www", withString: "=http://www")
            s = s.stringByReplacingOccurrencesOfString(" www", withString: " http://www")
            s = s.stringByReplacingOccurrencesOfString("[a href=", withString: "")
            s = s.stringByReplacingOccurrencesOfString("[/a]", withString: "")
            s = s.stringByReplacingOccurrencesOfString("]", withString: " ")
            
            let ss=s.lowercaseString
            var links=[String]()
            do {
                let detector = try NSDataDetector(types: NSTextCheckingType.Link.rawValue)
                detector
                    .enumerateMatchesInString(
                        ss, options: [],
                        range: NSMakeRange(0, ss.characters.count),
                        usingBlock: {
                            (result: NSTextCheckingResult?,
                            flags: NSMatchingFlags,
                            stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            //print(result?.URL)
                            if let r=result {
                                if let u=r.URL {
                                    links.append("\(u.absoluteString)")
                                }
                            }
                    })
            } catch {
                print(error)
            }
            
            let attributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
            descLabel.attributedText = NSAttributedString(string: s, attributes: attributes)
            let handler = {
                (hyperLabel: FRHyperLabel!, substring: String!) -> Void in
                //print("clicked! \(substring)")
                UIApplication.sharedApplication().openURL(NSURL(string: substring)!)
            }
            descLabel.setLinksForSubstrings(links as [AnyObject], withLinkHandler: handler)
        } else {
            descLabel.text=poll["msg"].stringValue
        }
        descLabel.sizeToFit()
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
