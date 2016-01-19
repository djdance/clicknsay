//
//  PollViewController.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class PollViewController: UIViewController {
    var poll:JSON=nil
    var json:JSON=nil
    var currentPage=1
    var maxpage=0
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var шапка: UINavigationItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var anketaView: UIView!
    @IBOutlet weak var stepbackButton: UIButton!
    @IBOutlet weak var stepforwButton: UIButton!
    @IBOutlet weak var pg: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        шапка.title="Голосование"
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)
        stepbackButton.hidden=true// enabled=false
        stepforwButton.hidden=true//enabled=false
        pg.setProgress(0, animated: true)
        scrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2)
        
        updatePoll()
    }
    
    func updatePoll(){
        if poll == nil {
            self.view.makeToast("Опрос потерян", duration: 2.0, position: .Center)
            return
        }
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getPollItems.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)&pollId=\(poll["id"].stringValue)"
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
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("news: json: \(self.json)")
                if self.json != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.fillPage()
                    })
                } else {
                    self.myToast("Ошибка",msg: "Нет данных с сервера")
                }
            }
        }).resume()
    }
    
    func fillPage(){
        /*
        [{
        "compulsorily" : "0",
        "originalId" : "0",
        "id" : "1833",
        "page" : "1",
        "order_at_page" : "0",
        "type" : "0",
        "pic" : "",
        "pollId" : "34",
        "title" : "Какие городские события вы бы с удовольствием посетили со своим ребенком?"
        },{}..]*/
        if maxpage==0 {
            currentPage=1
            maxpage=json[json.count-1]["page"].intValue
            if maxpage==0 {
                stepbackButton.hidden=true
                stepforwButton.hidden=true
                //https://github.com/scalessec/Toast-Swift
                self.view.makeToast("Ошибка!\nДанные опроса не загружены", duration: 2.0, position: .Center)
                return
            }
        }
        anketaView.removeAllSubviews()
        anketaView.clipsToBounds=true
        var y:CGFloat=0.0
        //for _ in 0...10 {
            for (_,item):(String, JSON) in json {
                if item["page"].intValue==currentPage {
                    //print ("\(item["type"].stringValue)")
                    switch item["type"].intValue {
                    case 0:
                        let anketa = UINib(nibName: "anketa0", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa0
                        anketa.itemId=item["id"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text=item["title"].stringValue;
                        anketa.width=scrollView.width-40
                        anketa.y=y
                        anketa.x=20
                        anketa.titleLabel.sizeToFit()
                        anketa.updateConstraints()
                        anketa.height=anketa.titleLabel.frame.height
                        //print("h=\(anketa.titleLabel.frame.height) for \(item["title"].stringValue)")
                        y+=anketa.titleLabel.frame.height//+50
                    case 1:
                        let anketa = UINib(nibName: "anketa1", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa1
                        anketa.itemId=item["id"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text=item["title"].stringValue;
                        //anketa.mySwitch.enabled=true// setOn(true, animated: true)
                        anketa.width=scrollView.width-40
                        anketa.y=y
                        anketa.x=30
                        anketa.titleLabel.sizeToFit()
                        anketa.sizeToFit()
                        anketa.updateConstraints()
                        //print("h=\(anketa.titleLabel.frame.height)=\(anketa.titleLabel.height) anketa.height=\(anketa.height)")
                        anketa.height=max(70,anketa.titleLabel.frame.height)
                        //print(".................................-> anketa.height=\(anketa.height)")
                        y+=anketa.height//anketa.titleLabel.frame.height//+50
                    case 2:
                        let anketa = UINib(nibName: "anketa2", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa2
                        anketa.itemId=item["id"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text=item["title"].stringValue;
                        //anketa.mySwitch.enabled=true// setOn(true, animated: true)
                        anketa.width=scrollView.width-40
                        anketa.y=y
                        anketa.x=30
                        anketa.titleLabel.sizeToFit()
                        anketa.sizeToFit()
                        anketa.updateConstraints()
                        //print("h=\(anketa.titleLabel.frame.height)=\(anketa.titleLabel.height) anketa.height=\(anketa.height)")
                        anketa.height=max(70,anketa.titleLabel.frame.height)
                        //print(".................................-> anketa.height=\(anketa.height)")
                        y+=anketa.height//anketa.titleLabel.frame.height//+50
                    case 5,6:
                        let anketa = UINib(nibName: "anketa5", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa5
                        anketa.itemId=item["id"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.editText.placeholder=item["title"].stringValue;
                        //anketa.editText.height=70
                        //anketa.layoutIfNeeded()
                        anketa.width=scrollView.width-70
                        anketa.y=y
                        anketa.x=30
                        anketa.sizeToFit()
                        anketa.updateConstraints()
                        y+=anketa.height//anketa.titleLabel.frame.height//+50
                    default:
                        let anketa = UINib(nibName: "anketa0", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa0
                        anketa.itemId=item["id"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text="[Этот тип вопроса не поддерживается данной версией программы. Пожалуйста, не участвуйте в опросе]\n"+item["title"].stringValue;
                        anketa.width=scrollView.width-60
                        anketa.y=y
                        anketa.x=20
                        anketa.titleLabel.sizeToFit()
                        anketa.updateConstraints()
                        anketa.height=anketa.titleLabel.frame.height
                        //print("h=\(anketa.titleLabel.frame.height) for \(item["title"].stringValue)")
                        y+=anketa.titleLabel.frame.height//+50
                    }
                }
            }
        //}
        //anketaView.sizeToFit()
        //anketaView.height=y
        //print("y=\(y), scrollView.h=\(scrollView.height)=\(scrollView.contentSize.height), anketaView.height=\(anketaView.height), self.h=\(self.view.height)=\(self.view.frame.height)")
        if #available(iOS 8.0, *) {
            //scrollView.height=self.view.height
            scrollView.contentSize=CGSizeMake(self.view.frame.size.width, y+100)
        }else{
            scrollView.height=y+100
        }
        stepbackButton.hidden=currentPage <= 1
        stepforwButton.hidden=currentPage >= maxpage
        pg.setProgress(Float(currentPage)/Float(maxpage), animated: true)
    }
    
    func checkForNext() -> Bool {
        for subview in anketaView.subviews  {
            //checkbox
            if let anketa1 = subview as? anketa1 {
                print("checkbox itemId=\(anketa1.itemId)")
            }
        }
        return true
    }
    
    @IBAction func stepbackButton(sender: AnyObject) {
        if (currentPage>1){
            currentPage--
            fillPage()
        }
    }
    @IBAction func stepforwButton(sender: AnyObject) {
        if checkForNext() {
            if (currentPage<maxpage){
                currentPage++
                fillPage()
            }
        }
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
