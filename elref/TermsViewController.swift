//
//  feedbackViewController.swift
//  elref
//
//  Created by Dj Dance on 05.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Термины и Условия"

        // Do any additional setup after loading the view.
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)
        
        webView.delegate = self
        
        var addr=NSUserDefaults.standardUserDefaults().stringForKey("server")!+"/terms.php";
        var s=NSUserDefaults.standardUserDefaults().integerForKey("cityId")
        if s==0 {
            s=NSUserDefaults.standardUserDefaults().integerForKey("defaultCityId")
        }
        addr+="?city=\(s)"
        //print("addr=\(addr)")
        //NSUserDefaults.standardUserDefaults().setObject("mynameisben", forKey: "username")
        //NSUserDefaults.standardUserDefaults().synch
        //print("pollFirst=\(NSUserDefaults.standardUserDefaults().boolForKey("pollFirst"))")

        if let theRequestURL = NSURL (string: addr) {
            let theRequest = NSURLRequest(URL: theRequestURL)
            self.view.makeToastActivity(.Center)
            webView.loadRequest(theRequest)
        } else {
            someErr("Невозможно открыть адрес "+addr)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible=true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        self.view.hideToastActivity()
    }
    func webView(webView: UIWebView,didFailLoadWithError error: NSError?){
        //print("webView error: \(error?.localizedDescription)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible=false
        self.view.hideToastActivity()
        someErr("Плохая связь с сервером. \n\n\(error?.localizedDescription)")
        backButtonProc()
    }
    
    func backButtonProc(){
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func someErr(msg: String){
        let alert = UIAlertView(title: "Ошибка"
            , message: msg
            , delegate: self
            , cancelButtonTitle: "OK")
        alert.show()
    }

    @IBAction func backButton(sender: AnyObject) {
        backButtonProc()
    }
}
