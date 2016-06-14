import UIKit
import RealmSwift

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    var drawerController: MMDrawerController!
    var gameFirst=NSUserDefaults.standardUserDefaults().boolForKey("gameFirst")
    
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var rootTable: UITableView!
    //@IBOutlet weak var KidssTableView: UITableView!

    var kids : Results<Kids>!
    var isEditingMode = false
    var currentCreateAction:UIAlertAction!
    var currentTextField1:UITextField!
    var currentTextField2:UITextField!
    var currentIndexPath:NSIndexPath!
    var dateFormatter = NSDateFormatter()
    let imagePickerController = UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Click and say!"
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        drawerButton.setTitleTextAttributes(attributes, forState: .Normal)
        //drawerButton.title=String.fontAwesomeIconWithName(.Bars)

        rootTable.delegate=self
        rootTable.dataSource=self
        //rootTable.rowHeight = UITableViewAutomaticDimension
        //rootTable.estimatedRowHeight = 100.0;
        //rootTable.separatorInset=UIEdgeInsetsMake(20, 20, 20, 20)
        //rootTable.contentInset=UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    override func viewWillAppear(animated: Bool) {
        readTasksAndUpdateUI(true)
    }
    
    func readTasksAndUpdateUI(reload: Bool){
        kids = uiRealm.objects(Kids)
        if reload {
            isEditingMode=false
            self.rootTable.setEditing(false, animated: false)
            self.rootTable.reloadData()
            //self.rootTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    @IBAction func editButtonClick(sender: AnyObject) {
        isEditingMode = !isEditingMode
        if isEditingMode {
            self.rootTable.reloadData()
            delay(0.2) {
                self.rootTable.setEditing(self.isEditingMode, animated: true)
            }
        } else {
            self.rootTable.setEditing(isEditingMode, animated: true)
            delay(0.2) {
                self.rootTable.reloadData()
            }
        }
    }

    @IBAction func addButtonClick(sender: AnyObject) {
        displayAlertToAddTaskList(NSIndexPath(forRow: 0, inSection: 999))
    }
    
    func displayAlertToAddTaskList(indexPath:NSIndexPath){
        var updatedKid=Kids()
        if indexPath.section != 999 {
            updatedKid=self.kids[indexPath.row]
        }
        var title = "New child"
        var doneTitle = "Create"
        if indexPath.section != 999{
            title = "Update child"
            doneTitle = "Update"
        }
        let alertController = UIAlertController(title: title, message: "Write the name of the child.", preferredStyle: UIAlertControllerStyle.Alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            let listName = self.currentTextField1.text
            let birthday = self.dateFormatter.dateFromString((self.currentTextField2.text)!)
            if indexPath.section != 999{
                // update mode
                try! uiRealm.write({ () -> Void in
                    updatedKid.name = listName!
                    updatedKid.createdAt = birthday!
                    self.rootTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    self.readTasksAndUpdateUI(false)
                })
            } else{
                let kid = Kids()
                kid.name = listName!
                kid.createdAt = birthday!
                try! uiRealm.write({ () -> Void in
                    uiRealm.add(kid)
                    if self.kids.count>2 {
                        self.rootTable.scrollToRowAtIndexPath(NSIndexPath(forRow: self.kids.count-2, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        self.rootTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.kids.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        self.readTasksAndUpdateUI(false)
                    } else {
                        self.readTasksAndUpdateUI(true)
                    }
                })
            }
        }
        alertController.addAction(createAction)
        createAction.enabled = indexPath.section != 999
        self.currentCreateAction = createAction
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            self.currentTextField1=textField
            textField.placeholder = "Child Name"
            textField.addTarget(self, action: #selector(RootViewController.nameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            if indexPath.section != 999{
                textField.text = updatedKid.name
            }
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            self.currentTextField2=textField
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.Date
            textField.inputView = datePickerView
            textField.addTarget(self, action: #selector(RootViewController.nameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

            datePickerView.addTarget(self, action: #selector(RootViewController.startDatePickerValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            if indexPath.section != 999{
                textField.text = self.dateFormatter.stringFromDate(updatedKid.createdAt) //"\(updatedKid.createdAt)"
                datePickerView.date=self.dateFormatter.dateFromString(textField.text!)!
            } else {
                textField.placeholder = "Birthday"
                //textField.text = self.dateFormatter.stringFromDate(NSDate()) //"\(updatedKid.createdAt)"
                datePickerView.date=NSDate()
            }
        }
       
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func nameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = self.currentTextField1.text?.characters.count > 0 && self.currentTextField2.text?.characters.count > 0
    }
    func startDatePickerValueChanged(sender: UIDatePicker) {
        self.currentTextField2.text = self.dateFormatter.stringFromDate(sender.date)
        nameFieldDidChange(self.currentTextField2)
    }
    
    func displayAlertToDelKid(indexPath:NSIndexPath){
        if indexPath.row<self.kids.count {
            let updatedKid = self.kids[indexPath.row]
            let alertController = UIAlertController(title: "Delete name "+updatedKid.name+"?", message: "This will destroy all hir words", preferredStyle: UIAlertControllerStyle.Alert)
            let createAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
                try! uiRealm.write({ () -> Void in
                    uiRealm.delete(updatedKid)
                    //print("self.kids.count=\(self.kids.count)")
                    if self.kids.count>0 {
                        self.rootTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                        self.readTasksAndUpdateUI(false)
                    } else {
                        self.readTasksAndUpdateUI(true)
                    }
                })
            }
            alertController.addAction(createAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func tableViewCellTitleClicked(cell: KidTableViewCell){
        if isEditingMode {
            displayAlertToAddTaskList(cell.indexPath!)
        }
    }
    func tableViewCellIcoClicked(cell: KidTableViewCell){
        if isEditingMode {
            self.currentIndexPath=cell.indexPath!
            Popups.SharedInstance.ShowAlert(self, title: "Выберите источник", message: "Откуда взять ваш снимок?", buttons: ["Сфотографировать" , "Из альбома"]) { (buttonPressed) -> Void in
                //print("buttonPressed=\(buttonPressed)")
                if buttonPressed == "Сфотографировать" {
                    self.fotoTapProc(0)
                } else if buttonPressed == "Из альбома" {
                    self.fotoTapProc(1)
                }
            }
        }
    }
    func fotoTapProc(mode: Int){
        self.imagePickerController.allowsEditing = false
        if mode==0 && UIImagePickerController.isSourceTypeAvailable(.Camera) {
            self.imagePickerController.sourceType = .Camera
        } else {
            self.imagePickerController.sourceType = .PhotoLibrary
        }
        self.imagePickerController.delegate = self
        navigationController?.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //let avatarPic = info[UIImagePickerControllerEditedImage] as? UIImage  //info[UIImagePickerControllerOriginalImage] as? UIImage
        let avatarPic = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let imageData = UIImageJPEGRepresentation(avatarPic!,0.1) {
            //print("imagePickerController: imageData ok, self.currentIndexPath.row=\(self.currentIndexPath.row)")
            let updatedKid=self.kids[self.currentIndexPath.row]
            try! uiRealm.write({ () -> Void in
                updatedKid.ico=imageData
                self.rootTable.reloadRowsAtIndexPaths([self.currentIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.readTasksAndUpdateUI(false)
            })
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: - UITableViewDataSource -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (kids) != nil && kids.count>0{
            self.rootTable.backgroundView=nil
            return 1
        } else {
            let label=UILabel.init(frame: CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height))
            label.text="Add your kids and their words"
            label.numberOfLines=0
            label.textAlignment=NSTextAlignment.Center
            label.sizeToFit()
            self.rootTable.backgroundView=label
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (kids) != nil{
            return kids.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let kid = kids[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("KidTableViewCell", forIndexPath: indexPath) as! KidTableViewCell
        cell.delegate=self
        cell.indexPath=indexPath
        
            cell.desc.adjustsFontSizeToFitWidth=false
            cell.title.text = kid.name
            cell.title.shake(isEditingMode)
        cell.title.backgroundColor=isEditingMode ? UIColor.whiteColor() : UIColor.clearColor()

        cell.desc.text = "\(kid.words.count) words"
            //cell.lockLabel.hidden = true
            //cell.date.text = dateFormatter.stringFromDate(kid.createdAt) //"\(kid.createdAt)"
            let differenceFromTodayComponents=NSCalendar.currentCalendar().components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: kid.createdAt, toDate: NSDate(), options: NSCalendarOptions())
        
        var s="";
        if differenceFromTodayComponents.year>0 {
            s += "\(differenceFromTodayComponents.year) year"
            if differenceFromTodayComponents.year>1 {
                s += "s"
            }
            if differenceFromTodayComponents.month>0 {
                s += "\n"
            }
        }
        if differenceFromTodayComponents.month>0 {
            s += "\(differenceFromTodayComponents.month) month"
            if differenceFromTodayComponents.month>1 {
                s += "s"
            }
        }
        cell.date.text = s
        //print("--------    date=\(kid.createdAt), s=\(s), year=\(differenceFromTodayComponents.year), month=\(differenceFromTodayComponents.month)")
        //cell.date.shake(isEditingMode)
        
        if let imageData=kid.ico {
            //print("imageData ok")
            var bottomImage=UIImage.init(data: imageData)!
            if isEditingMode {
                let topImage: UIImage = UIImage( named: "recycle" )!
                let w=min(bottomImage.size.width, bottomImage.size.height)
                UIGraphicsBeginImageContext(bottomImage.size)
                bottomImage.drawInRect( CGRectMake(0,0,bottomImage.size.width,bottomImage.size.height))
                topImage.drawInRect( CGRectMake((bottomImage.size.width-w)/2, (bottomImage.size.height-w)/2, w, w), blendMode: CGBlendMode.Normal, alpha: 0.75 )
                
                /*
                let rect: CGRect = CGRectMake( 50, 48, 380, 360 )
                let drawText = "replace"
                let textFontAttributes = [
                    NSFontAttributeName: UIFont(name: "FontAwesome", size: 120 )!,
                    NSForegroundColorAttributeName: UIColor.blackColor(),
                    ]
                drawText.drawInRect( rect, withAttributes: textFontAttributes )*/
                
                bottomImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            cell.ico.image=bottomImage
            //cell.ico.alpha=(isEditingMode ? 0.8 : 1.0);
        }
        //cell.se .selectedColor = UIColor(red:0.31, green:0.62, blue:0.53, alpha:1.0)
        
            return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let green = UIColor(red:0.31, green:0.62, blue:0.53, alpha:1.0)
        tableView.cellForRowAtIndexPath(indexPath)?.contentView.backgroundColor = green
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (kids) != nil && kids.count>0 {
            //print("h=\(tableView.frame.size.height / CGFloat(kids.count))")
            return max(100,tableView.frame.size.height / CGFloat(kids.count+1))
        }
        return UITableViewAutomaticDimension
    }
    
    
        func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Del") { (deleteAction, indexPath) -> Void in
                self.displayAlertToDelKid(indexPath)
            }
            let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (editAction, indexPath) -> Void in
                self.displayAlertToAddTaskList(indexPath)
            }
            editAction.backgroundColor = UIColor.greenColor()
            
            let wordsAction = UITableViewRowAction(style: .Normal, title: "Words") { (editAction, indexPath) -> Void in
                print("done")
            }
            //editAction.backgroundColor = UIColor.greenColor()
            return [wordsAction, deleteAction, editAction]
        }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "pollSegue" {
            if let selectedCell = sender as? KidTableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                //if kids[indexPath.row/2]["done"].stringValue == "1"{
                //    self.myToast("Отказ",msg: "Опрос уже пройден, устарел или закрыт")
                //    return false
                //}
            } else {
                return false
            }
        }
        return true
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue! \(segue.identifier)")
        if segue.identifier == "pollSegue" {
            /*
            let pollDetailViewController = segue.destinationViewController as! WordViewController
            if let selectedCell = sender as? WordsTableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                let tale=indexPath.row/2
                if words["\(tale)"]["done"].stringValue != "1"{
                    pollDetailViewController.word=words["\(tale)"]
                    pollDetailViewController.delegate=self
                }
                //print ("selected \(pollDetailViewController.poll)")
            }
             */
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

