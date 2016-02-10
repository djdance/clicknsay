//
//  ScoreViewController.swift
//  elref
//
//  Created by Dj Dance on 13.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var maxscoreLabel: UILabel!
    @IBOutlet weak var scorePG: UIProgressView!
    @IBOutlet weak var scoreTable: UITableView!
    var json:JSON=nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Баллы"
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        drawerButton.setTitleTextAttributes(attributes, forState: .Normal)
        
        scorePG.transform = CGAffineTransformScale(scorePG.transform, 1, 5)
        scorePG.progressViewStyle = .Default

        if let money=NSUserDefaults.standardUserDefaults().stringForKey("money") {
            scoreLabel.text="Заработано баллов: \(money)"
        } else {
            scoreLabel.text="Заработано баллов: ??"
        }
        if let status=NSUserDefaults.standardUserDefaults().stringForKey("status"){
            statusLabel.text="Статус: \(status)"
        } else {
            statusLabel.text="Статус: неизвестен"
        }
        maxscoreLabel.text=""
        scorePG.setProgress(0, animated:false)
        if let maxscore=NSUserDefaults.standardUserDefaults().stringForKey("maxscore") where maxscore != ""{
            if let score=NSUserDefaults.standardUserDefaults().stringForKey("score") where score != ""{
                maxscoreLabel.text="\(score)/\(maxscore)"
                scorePG.setProgress(Float(score)!/Float(maxscore)!, animated:true)
            }
        }

        scoreTable.delegate=self
        scoreTable.dataSource=self
        
        
        scoreTable.layer.cornerRadius = 15
        scoreTable.layer.masksToBounds = true

        updateUserScore()
    }
    
    func updateUserScore(){
        let urlPath = NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/mob/getScores.php?deviceId=\(KeychainWrapper.stringForKey("deviceId")!)"
        //print("updateUserProfile запрос \(urlPath)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {data, response, error -> Void in
            //print("checkExistedUser completed")
            UIApplication.sharedApplication().networkActivityIndicatorVisible=false
            if error != nil || data == nil {
                //self.myToast("Ошибка", msg:"Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")")
                dispatch_async(dispatch_get_main_queue(), {
                    Popups.SharedInstance.ShowAlert(self, title: "Ошибка", message: "Нет связи с сервером\nПопробуйте снова\n\n\(error != nil ? error!.localizedDescription : "no data")", buttons: ["Повтор","Отмена"]) { (buttonPressed) -> Void in
                        if buttonPressed == "Повтор" {
                            self.updateUserScore()
                        }
                    }
                })

            } else {
                self.json = JSON(data: data!)
                //print("swity ok") // https://github.com/SwiftyJSON/SwiftyJSON
                //print("json: \(self.json), count=\(self.json.count)")
                if self.json != nil {
                    let j=self.json[0]
                    //print("json: \(j)")
                    NSUserDefaults.standardUserDefaults().setInteger(j["maxscore"].intValue, forKey: "maxscore")
                    NSUserDefaults.standardUserDefaults().setObject(j["status"].stringValue, forKey: "status")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.scoreLabel.text="Заработано баллов: \(j["money"].intValue)"
                        self.statusLabel.text="Статус: \(j["status"].stringValue)"
                        self.maxscoreLabel.text="\(j["score"].intValue)/\(j["maxscore"].intValue)"
                        self.scorePG.setProgress(Float(j["score"].intValue)/Float(j["maxscore"].intValue), animated:true)
                        self.scoreTable.reloadData()
                    })
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
        return json.count-1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScoreTableViewCell", forIndexPath: indexPath) as! ScoreTableViewCell
        var price=json[indexPath.row+1]["price"].stringValue
        if Int(price)>0 {
            price="+"+price
        }
        var date=json[indexPath.row+1]["updated"].stringValue
        date=date.stringByPaddingToLength(10, withString:" ", startingAtIndex:0)// .substringToIndex(9)
        cell.bonusLabel.text = json[indexPath.row+1]["comment_"].stringValue
        cell.scoreLabel.text = price
        cell.dateLabel.text = date
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
