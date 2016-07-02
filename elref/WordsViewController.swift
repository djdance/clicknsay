import UIKit
import RealmSwift

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    var drawerController: MMDrawerController!
    
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var rootTable: UITableView!

    var kids : Results<Kids>!
    var words: List<Word>!
    var isEditingMode = false
    var currentCreateAction:UIAlertAction!
    var currentTextField1:UITextField!
    var currentIndexPath:NSIndexPath!
    var currentKid = NSUserDefaults.standardUserDefaults().integerForKey("currentKid");
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="Click and say!"
        
        let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
        drawerButton.setTitleTextAttributes(attributes, forState: .Normal)
        //drawerButton.title=String.fontAwesomeIconWithName(.Bars)

        rootTable.delegate=self
        rootTable.dataSource=self
        rootTable.rowHeight = UITableViewAutomaticDimension
        rootTable.estimatedRowHeight = 70;
    }
    
    override func viewWillAppear(animated: Bool) {
        readWordsAndUpdateUI(true)
    }
    
    func readWordsAndUpdateUI(reload: Bool){
        kids = uiRealm.objects(Kids)
        if currentKid<0 {
            words.removeAll()
        } else {
            navigationItem.title="Click and say! - "+kids[currentKid].name
            words=kids[currentKid].words
        }
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
        var updatedWord=Word()
        if indexPath.section != 999 {
            updatedWord=self.words[indexPath.row]
        }
        var title = "New word"
        var doneTitle = "Create"
        if indexPath.section != 999{
            title = "Update word"
            doneTitle = "Update"
        }
        let alertController = UIAlertController(title: title, message: "Write the word.", preferredStyle: UIAlertControllerStyle.Alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            let listName = self.currentTextField1.text
            if indexPath.section != 999{
                // update mode
                try! uiRealm.write({ () -> Void in
                    updatedWord.title = listName!
                    self.rootTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                    self.readWordsAndUpdateUI(false)
                })
            } else{
                updatedWord.title = listName!
                updatedWord.isEnabled=true
                updatedWord.repeats=0
                try! uiRealm.write({ () -> Void in
                    self.words.append(updatedWord)
                    if self.words.count>2 {
                        self.rootTable.scrollToRowAtIndexPath(NSIndexPath(forRow: self.words.count-2, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        self.rootTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.words.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        self.readWordsAndUpdateUI(false)
                    } else {
                        self.readWordsAndUpdateUI(true)
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
            textField.placeholder = "any single word"
            textField.addTarget(self, action: #selector(RootViewController.nameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            if indexPath.section != 999{
                textField.text = updatedWord.title
            }
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func nameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = self.currentTextField1.text?.characters.count > 0
    }
    func displayAlertToDelWord(indexPath:NSIndexPath){
        if indexPath.row<self.words.count {
            let updatedWord = self.words[indexPath.row]
            let alertController = UIAlertController(title: "Delete word "+updatedWord.title+"?", message: "This will destroy word's statistic", preferredStyle: UIAlertControllerStyle.Alert)
            let createAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
                try! uiRealm.write({ () -> Void in
                    //uiRealm.delete(updatedWord)
                    self.words.removeAtIndex(indexPath.row)
                    //print("self.kids.count=\(self.kids.count)")
                    if self.words.count>0 {
                        self.rootTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                        self.readWordsAndUpdateUI(false)
                    } else {
                        self.readWordsAndUpdateUI(true)
                    }
                })
            }
            alertController.addAction(createAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func tableViewCellTitleClicked(cell: WordTableViewCell){
        if isEditingMode {
            displayAlertToAddTaskList(cell.indexPath!)
        }
    }
    
    func enableButtonTapped(cell: WordTableViewCell){
        var updatedWord=self.words[cell.indexPath!.row]
        try! uiRealm.write({ () -> Void in
            //print("set on=\(cell.enableButton.on)")
            updatedWord.isEnabled = cell.enableButton.on
        })
        
    }
    
    // MARK: - UITableViewDataSource -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (words) != nil && words.count>0{
            self.rootTable.backgroundView=nil
            return 1
        } else {
            let label=UILabel.init(frame: CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height))
            label.text="Add first words one by one"
            label.numberOfLines=0
            label.textAlignment=NSTextAlignment.Center
            label.sizeToFit()
            self.rootTable.backgroundView=label
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (words) != nil{
            return words.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let word = words[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("WordTableViewCell", forIndexPath: indexPath) as! WordTableViewCell
        cell.delegate=self
        cell.indexPath=indexPath
        
            cell.title.text = word.title
            cell.title.shake(isEditingMode)
        cell.title.backgroundColor=isEditingMode ? UIColor.whiteColor() : UIColor.clearColor()
        cell.title.userInteractionEnabled = isEditingMode

        cell.repatsLabel.text = "\(word.repeats) repeats"
        cell.enableButton.on=word.isEnabled
        
            return cell
    }
    /*
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let green = UIColor(red:0.31, green:0.62, blue:0.53, alpha:1.0)
        tableView.cellForRowAtIndexPath(indexPath)?.contentView.backgroundColor = green
    }// */
    
    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (words) != nil && words.count>0 {
            //print("h=\(tableView.frame.size.height / CGFloat(kids.count))")
            return max(100,tableView.frame.size.height / CGFloat(words.count+1))
        }
        return UITableViewAutomaticDimension
    }// */
    
    
        func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Del") { (deleteAction, indexPath) -> Void in
                self.displayAlertToDelWord(indexPath)
            }
            let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (editAction, indexPath) -> Void in
                self.displayAlertToAddTaskList(indexPath)
            }
            editAction.backgroundColor = UIColor.greenColor()
            
            return [deleteAction, editAction]
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

