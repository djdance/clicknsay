//
//  feedbackViewController.swift
//  elref
//
//  Created by Dj Dance on 05.01.16.
//  Copyright © 2016 Dj Dance. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Обратная связь"

        // Do any additional setup after loading the view.
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        backButton.setTitleTextAttributes(attributes, forState: .Normal)
       
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        /*
        let subject = "Вопрос из программы"
        let body = "Вопрос в следующем: ..."
        let encodedParams = "subject=\(subject)&body=\(body)".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let url = "mailto:it-support@orgcom.ru?\(encodedParams)"
        
        if let emailURL = NSURL(fileURLWithPath: url) {
            if UIApplication.sharedApplication().canOpenURL(emailURL) {
                UIApplication.sharedApplication().openURL(emailURL)
            }
        }// */
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Вопрос из программы")
            mail.setMessageBody("Вопрос в следующем: ...", isHTML: false)
            mail.setToRecipients(["it-support@orgcom.ru"])
            presentViewController(mail, animated: true, completion: nil)
        } else {
            someErr("Установите почтовую программу!")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func someErr(msg: String){
        let alert = UIAlertView(title: "Ошибка"
            , message: msg
            , delegate: self
            , cancelButtonTitle: "OK")
        alert.show()
    }

    @IBAction func backButton(sender: AnyObject) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
}
