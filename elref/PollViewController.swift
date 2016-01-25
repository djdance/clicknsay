//
//  PollViewController.swift
//  elref
//
//  Created by Dj Dance on 17.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

protocol PollViewControllerDelegate {
    func acceptData(data: AnyObject!)
}

class PollViewController: UIViewController {
    // create a variable that will recieve / send messages
    // between the view controllers.
    var delegate : PollViewControllerDelegate?
    // another data outlet
    var data : AnyObject?
    
    var poll:JSON=nil
    var json:JSON=nil
    var answers:JSON=nil
    var currentPage=1
    var maxpage=0
    var pollSuccess=false
    
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
        stepbackButton.layer.cornerRadius = 15
        stepbackButton.layer.masksToBounds = true
        stepforwButton.layer.cornerRadius = 15
        stepforwButton.layer.masksToBounds = true

        updatePoll()
    }
    
    func updatePoll(){
        if poll == nil {
            self.view.makeToast("Опрос потерян", duration: 2.0, position: .Bottom)
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
            /*
            var s=""
            for (_,item):(String, JSON) in json {
                if item["type"]>0 && item["type"]<100 {
                    if s != ""{
                        s+=","
                    }
                    s+=item["id"].stringValue+"\":\"\""
                }
            }
            s="{"+s+"}"
            //print("s=\(s)")
            answers=JSON.parse(s) // */
            answers=JSON([:])
        }
        anketaView.removeAllSubviews()
        scrollView.setContentOffset(CGPoint(x: 0,y:0),animated:true)
        anketaView.clipsToBounds=true
        var wasSomeText=false
        var y:CGFloat=0.0
        //for _ in 0...10 {
            for (_,item):(String, JSON) in json {
                if item["page"].intValue==currentPage {
                    //print ("page=\(currentPage), \(item["type"].stringValue)")
                    switch item["type"].intValue {
                    case 0:
                        let anketa = UINib(nibName: "anketa0", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa0
                        anketa.itemId=item["id"].intValue;
                        anketa.type=item["type"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        if !wasSomeText {
                            y+=50
                        }
                        anketa.titleLabel.text=item["title"].stringValue
                        if currentPage==maxpage {
                            anketa.titleLabel.sizeToFit()
                            anketa.y=y//self.view.height*0.4-50
                            anketa.x=(scrollView.width-anketa.titleLabel.width)*0.5
                        } else {
                            anketa.width=scrollView.width-40
                            anketa.y=y
                            anketa.x=20
                            anketa.titleLabel.sizeToFit()
                        }
                        anketa.updateConstraints()
                        anketa.height=anketa.titleLabel.frame.height
                        //print("h=\(anketa.titleLabel.frame.height) for \(item["title"].stringValue)")
                        y+=anketa.titleLabel.frame.height//+50
                        wasSomeText=true
                    case 1:
                        let anketa = UINib(nibName: "anketa1", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa1
                        anketa.itemId=item["id"].intValue;
                        anketa.type=item["type"].intValue;
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
                        anketa.type=item["type"].intValue;
                        anketa.controller=self
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
                        anketa.type=item["type"].intValue;
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
                    case 11:
                        //необязательное
                        let anketa = UINib(nibName: "anketa0", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa0
                        anketa.itemId=item["id"].intValue;
                        anketa.type=item["type"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text=item["title"].stringValue;
                        if currentPage==maxpage {
                            anketa.titleLabel.sizeToFit()
                            anketa.y=self.view.height*0.4-50
                            anketa.x=(scrollView.width-anketa.titleLabel.width)*0.5
                        } else {
                            anketa.width=scrollView.width-40
                            anketa.y=y
                            anketa.x=20
                            anketa.titleLabel.sizeToFit()
                        }
                        anketa.updateConstraints()
                        anketa.height=anketa.titleLabel.frame.height
                        //print("h=\(anketa.titleLabel.frame.height) for \(item["title"].stringValue)")
                        y+=anketa.titleLabel.frame.height//+50
                    case 100:
                        let anketa = UINib(nibName: "anketa100", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa100
                        anketa.itemId=item["id"].intValue;
                        anketa.type=item["type"].intValue;
                        anketaView.addSubview(anketa)
                        //if #available(iOS 8.0, *) {
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        //}else{
                            //anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        //}// */
                        //print("item[\"title\"].string=\(item["title"].string)")
                        anketa.b.titleLabel!.text=item["title"].stringValue=="" ? "Завершить голосование" : item["title"].stringValue;
                        anketa.controller=self
                        //anketa.editText.height=70
                        //anketa.layoutIfNeeded()
                        //anketa.sizeToFit()
                        anketa.updateConstraints()
                        if scrollView.width>anketa.width {
                            anketa.x=(scrollView.width-anketa.width)*0.5
                        }else{
                            anketa.width=scrollView.width
                            anketa.x=0
                        }
                        if wasSomeText {
                            anketa.y=y
                        }else{
                            anketa.y=self.view.height*0.2
                        }
                        //print("button100 y=\(y)")
                        //anketa.x=0//(scrollView.width-anketa.width)*0.5
                        y+=anketa.height//anketa.titleLabel.frame.height//+50
                    default:
                        let anketa = UINib(nibName: "anketa0", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! anketa0
                        anketa.itemId=item["id"].intValue;
                        anketa.type=item["type"].intValue;
                        anketaView.addSubview(anketa)
                        if #available(iOS 8.0, *) {
                            anketa.titleLabel.adjustsFontSizeToFitWidth=false
                        }else{
                            anketa.titleLabel.adjustsFontSizeToFitWidth=true
                            y+=20
                        }// */
                        anketa.titleLabel.text=""//item["title"].stringValue;
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
        var needChecked=false
        var wasChecked=false
        for subview in anketaView.subviews  {
            var item=JSON([:])
            item["pollId"].string=poll["id"].stringValue
            //textview or type11
            if let anketa0 = subview as? anketa0 {
                if anketa0.type==11 {
                    //print("необязательно!")
                    wasChecked=true
                }
                //print("checkbox itemId=\(anketa1.itemId)")
            }
            //checkbox
            if let anketa1 = subview as? anketa1 {
                item["itemId"].int=anketa1.itemId
                item["result"].string=anketa1.checkbox.selected ? "1" : "0"
                answers["\(anketa1.itemId)"]=item
                needChecked=true
                if anketa1.checkbox.selected {
                    wasChecked=true
                }
                //print("checkbox itemId=\(anketa1.itemId)")
            }
            //radios
            if let anketa2 = subview as? anketa2 {
                item["itemId"].int=anketa2.itemId
                item["result"].string=anketa2.checkbox.selected ? "1" : "0"
                answers["\(anketa2.itemId)"]=item
                needChecked=true
                if anketa2.checkbox.selected {
                    wasChecked=true
                }
                //print("checkbox itemId=\(anketa2.itemId)")
            }
            //edittext
            if let anketa5 = subview as? anketa5 {
                item["itemId"].int=anketa5.itemId
                item["result"].string=anketa5.editText.text
                answers["\(anketa5.itemId)"]=item
                needChecked=true
                if let s=anketa5.editText.text where s != "" {
                    wasChecked=true
                }
                //print("checkbox itemId=\(anketa5.itemId)")
            }
        }
        if needChecked && !wasChecked {
            myToast("Ошибка", msg: "Пожалуйста, ответьте на вопрос")
            return false
        }
        return true
    }
    
    func radioChecked(anketa: anketa2){
        for subview in anketaView.subviews  {
            //radios
            if let anketa2 = subview as? anketa2 where !(anketa2 === anketa) {
                anketa2.checkbox.selected=false
            }
        }
        
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
    
    func doneButton(){
        self.view.makeToast("Отправляем результаты...", duration: 10.0, position: .Bottom)
        ///print("answers: \(answers)")
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/postResults.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod="POST"
        do {
            try request.HTTPBody = answers.rawData()
            //try request.HTTPBody =  NSJSONSerialization.dataWithJSONObject(q.dictionaryObject!)
        } catch {
            myToast("Ошибка",msg: "Ошибка упаковки ответов\nПопробуйте поменять строки")
            return
        }
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        stepbackButton.enabled=false

        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //print("updateUser.php completed, data=\(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil  {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stepbackButton.enabled=true
                })
                self.myToast("Ошибка",msg: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Опрос завершён", message: "Спасибо за участие в опросе. Вам начислено \(self.poll["price"].stringValue) баллов", buttons: ["Ok"]) { (buttonPressed) -> Void in
                        //print("buttonPressed=\(buttonPressed)")
                        if buttonPressed == "Ok" {
                            self.pollSuccess=true
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                })
            }
        }).resume()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed() {
            self.delegate?.acceptData(pollSuccess)
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
