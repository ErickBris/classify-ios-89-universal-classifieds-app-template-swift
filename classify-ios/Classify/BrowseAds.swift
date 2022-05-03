/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse

var searchedAdsArray = NSMutableArray()


class BrowseAds: UITableViewController {
    
    /* Variables */
    var callTAG = 0
    

override func viewDidLoad() {
        super.viewDidLoad()

     self.title = " Browse Ads"
    
}


 
/* MARK: - TABLEVIEW DELEGATES */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedAdsArray.count
    }
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AdCell", forIndexPath: indexPath) as! AdCell
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[indexPath.row] as! PFObject
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    cell.addToFavOutlet.tag = indexPath.row
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.adImage.image = UIImage(data:imageData)
            } } }

    
return cell
}
 
// SELECTED AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[indexPath.row] as! PFObject
    
    let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
    // Pass the Ad ID to the Controller
    showAdVC.singleAdID = classifClass.objectId!
    self.navigationController?.pushViewController(showAdVC, animated: true)
}


    
// ADD AD TO FAVORITES BUTTON
@IBAction func addToFavButt(sender: AnyObject) {
    var button = sender as! UIButton
    
    if PFUser.currentUser() != nil {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[button.tag] as! PFObject
    var favClass = PFObject(className: FAV_CLASS_NAME)
    
    // ADD THIS AD TO FAVORITES
    favClass[FAV_USERNAME] = PFUser.currentUser()?.username!
    favClass[FAV_AD_POINTER] = classifClass
    
    // Saving block
    favClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            var alert = UIAlertView(title: APP_NAME,
            message: "This Ad has been added to your Favorites!",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later, or check your internet connection",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        }
        
    } // end Saving block
        
        
    } else {
        var alert = UIAlertView(title: APP_NAME,
        message: "You have to login/signup to favorite ads!",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
    }


}
 
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
