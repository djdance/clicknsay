import UIKit
import RealmSwift

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, DraggableCellDelegate {
    var drawerController: MMDrawerController!
    var gameFirst=NSUserDefaults.standardUserDefaults().boolForKey("gameFirst")
    
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var rootTable: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    var kids : Results<Kids>!
    //var isEditingMode = false
    var currentCreateAction:UIAlertAction!
    var currentTextField1:UITextField!
    var currentTextField2:UITextField!
    var currentIndexPath:NSIndexPath!
    var dateFormatter = NSDateFormatter()
    let imagePickerController = UIImagePickerController()
    var currentKid = NSUserDefaults.standardUserDefaults().integerForKey("currentKid");
    
    
    //test
    var pannedIndexPath: NSIndexPath?
    var pannedView: UIImageView?
    var dataValues:[Int] = {
        var tmp = [Int]()
        for i in 0 ..< 5 {
            tmp.append(i)
        }
        return tmp
    }()
    
    
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
        
        collectionView.multipleTouchEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        readTasksAndUpdateUI(true)
    }
    
    func readTasksAndUpdateUI(reload: Bool){
        kids = uiRealm.objects(Kids)
        if reload {
            editing=false
            self.rootTable.setEditing(false, animated: false)
            self.rootTable.reloadData()
            //self.rootTable.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    @IBAction func editButtonClick(sender: AnyObject) {
        editing = !editing
        if editing {
            self.rootTable.reloadData()
            collectionView.reloadSections(NSIndexSet(index:0))
            delay(0.2) {
                self.rootTable.setEditing(self.editing, animated: true)
            }
        } else {
            self.rootTable.setEditing(editing, animated: true)
            delay(0.2) {
                self.rootTable.reloadData()
                self.collectionView.reloadSections(NSIndexSet(index:0))
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
        if editing {
            displayAlertToAddTaskList(cell.indexPath!)
        }
    }
    func tableViewCellIcoClicked(cell: KidTableViewCell){
        if editing {
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
    

// MARK: - UITableView

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
            cell.title.shake(editing)
        cell.title.backgroundColor=editing ? UIColor.whiteColor() : UIColor.clearColor()
        cell.title.userInteractionEnabled = editing

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
            if editing {
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
        if identifier == "wordsSegue" {
            if let selectedCell = sender as? KidTableViewCell {
                let indexPath = rootTable.indexPathForCell(selectedCell)!
                print("wordsSegue row=\(indexPath.row)")
                currentKid=indexPath.row
                NSUserDefaults.standardUserDefaults().setInteger(currentKid, forKey: "currentKid")
                //NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                return false
            }
        }
        return true
    }
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue! \(segue.identifier)")
        if segue.identifier == "wordsSegue" {
            print("wordsSegue")
            / *
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
             * /
        }
    }// */


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
    
    
    
    // MARK: UICollectionViewDatasource
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return dataValues.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) ->
        UICollectionViewCell! {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) as! DraggableCell
            cell.delegate = self
            cell.tag = indexPath.item
            cell.label.text = dataValues[indexPath.item].description
            if editing {
                cell.deleteButton.hidden = false
            } else {
                cell.deleteButton.hidden = true
            }
            cell.editing = editing
            return cell
    }
    
    // MARK: DraggableCellDelegate
    
    func draggableCellDeleteButtonTapped(cell: DraggableCell) {
        // delete
        if let path = collectionView.indexPathForCell(cell) {
            dataValues.removeAtIndex(path.item)
            collectionView.performBatchUpdates({
                self.collectionView.deleteItemsAtIndexPaths([ path ])
                }, completion: { succes in self.collectionView.reloadData() })
        }
    }
    
    func draggableCell(cell: DraggableCell, pannedWithGestureRecognizer gestureRecognizer:UIPanGestureRecognizer) {
        if !editing {
            return
        }
        
        if gestureRecognizer.state == .Began {
            if pannedIndexPath != nil {
                return
            }
            let point = gestureRecognizer.locationInView(collectionView)
            if let path = collectionView.indexPathForItemAtPoint(point) {
                cell.hidden = true
                pannedIndexPath = path
                
                // create image for dragging
                UIGraphicsBeginImageContextWithOptions(cell.frame.size, cell.opaque, 0)
                cell.contentView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                // and add
                pannedView = UIImageView(image: image)
                pannedView!.backgroundColor = UIColor.whiteColor()
                pannedView!.layer.borderColor = cell.layer.borderColor
                pannedView!.layer.borderWidth = cell.layer.borderWidth
                pannedView!.center = gestureRecognizer.locationInView(self.view)
                self.view.addSubview(pannedView!)
            }
            
        } else if gestureRecognizer.state == .Changed {
            if pannedIndexPath == nil {
                return
            }
            
            let destPoint = gestureRecognizer.locationInView(self.view)
            pannedView!.center = destPoint
            
            let point = gestureRecognizer.locationInView(collectionView)
            if let indexPath = collectionView.indexPathForItemAtPoint(point) {
                if indexPath != pannedIndexPath {
                    // replace
                    let moved = dataValues.removeAtIndex(pannedIndexPath!.item)
                    dataValues.insert(moved, atIndex: indexPath.item)
                    
                    collectionView.moveItemAtIndexPath(pannedIndexPath!, toIndexPath: indexPath)
                    pannedIndexPath = indexPath
                }
            }
            
            // scroll if necessary
            let visibleItems = collectionView.indexPathsForVisibleItems()
            if visibleItems.count > 0 {
                let visibles = NSArray(array: visibleItems)
                let sorted = NSArray(array: visibles.sortedArrayUsingDescriptors([ NSSortDescriptor(key: "item", ascending: true) ]))
                
                if destPoint.y > CGRectGetHeight(self.view.frame) - 50 {
                    let lastPath = sorted.lastObject as! NSIndexPath
                    if lastPath.item + 1 < dataValues.count {
                        // scroll forward
                        let attr = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(lastPath)
                        var rect = attr!.frame
                        rect.origin.y += 100
                        
                        collectionView.scrollRectToVisible(rect, animated: true)
                    }
                    
                } else if destPoint.y < 150 {
                    // scroll upward
                    let firstPath = sorted.firstObject as! NSIndexPath
                    let attr = collectionView!.collectionViewLayout.layoutAttributesForItemAtIndexPath(firstPath)
                    var rect = attr!.frame
                    rect.origin.y -= 100
                    
                    if rect.origin.y >= 0 {
                        collectionView.scrollRectToVisible(rect, animated: true)
                    }
                }
            }
        } else {
            // end dragging
            cell.hidden = false
            pannedView?.removeFromSuperview()
            pannedView = nil
            pannedIndexPath = nil
        }
    }
}
// END of main class RootViewController




// MARK: DraggableCellDelegate
@objc protocol DraggableCellDelegate {
    optional func draggableCellDeleteButtonTapped(cell: DraggableCell)
    optional func draggableCell(cell: DraggableCell, pannedWithGestureRecognizer gestureRecognizer:UIPanGestureRecognizer)
}

// MARK: DraggableCell
class DraggableCell : UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var label: UILabel!
    weak var delegate: DraggableCellDelegate?
    var editing = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.layer.borderColor = UIColor.lightGrayColor().CGColor
        //self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(DraggableCell.panAction(_:)))
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
    }
    
    override func awakeFromNib() {
        deleteButton.transform = CGAffineTransformMakeRotation(CGFloat(45 * M_PI / 180))
    }
    
    func panAction(gesture: UIPanGestureRecognizer) {
        delegate?.draggableCell?(self, pannedWithGestureRecognizer: gesture)
    }
    
    @IBAction func deleteAction(button: UIButton) {
        delegate?.draggableCellDeleteButtonTapped?(self)
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !editing;
    }
    
}


