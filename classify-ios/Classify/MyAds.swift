/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse


class MyAds: UITableViewController {

    /* Variables */
    var classifArray = NSMutableArray()
    
    
override func viewDidAppear(animated: Bool) {
    classifArray.removeAllObjects()
    
    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_USER, equalTo: PFUser.currentUser()!)
    query.orderByDescending(CLASSIF_UPDATED_AT)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    self.classifArray.addObject(object)
                } }
            // Pupolate the TableView
            self.tableView.reloadData()
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }

}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "My Ads"
   
}

    
    
    
    
/* MARK: - TABLE VIEW DELEGATES */
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classifArray.count
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyAdCell", forIndexPath: indexPath) as! MyAdCell

    // SHOW ALL YOUR ADS
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = classifArray[indexPath.row] as! PFObject
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.adImage.image = UIImage(data:imageData)
            } } }
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    
    

return cell
}

override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = classifArray[indexPath.row] as! PFObject
    
    // Open to Post Controller
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    postVC.postID = classifClass.objectId!
    presentViewController(postVC, animated: true, completion: nil)

}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
