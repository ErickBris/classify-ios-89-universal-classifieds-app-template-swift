/* =======================

 - Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse


class Favorites: UITableViewController {


    /* Variables */
    var favoritesArray = NSMutableArray()
    

    
override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {
        queryFavAds()
    } else {
        var alert = UIAlertView(title: APP_NAME,
        message: "You must login/signup into your Account to add Favorites",
        delegate: nil,
        cancelButtonTitle: "OK" )
        alert.show()
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    
}

func queryFavAds()  {
    favoritesArray.removeAllObjects()
    
    var query = PFQuery(className: FAV_CLASS_NAME)
    query.whereKey(FAV_USERNAME, equalTo: PFUser.currentUser()!.username!)
    query.includeKey(FAV_AD_POINTER)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    self.favoritesArray.addObject(object)
                } }
            // Show details (or reload a TableView)
            self.tableView.reloadData()
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }

}


/* MARK: - TABLEVIEW DELEGATES */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesCell", forIndexPath: indexPath) as! FavoritesCell
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row] as! PFObject
        // Get Ads as a Pointer
        var adPointer = favClass[FAV_AD_POINTER] as! PFObject
        
        cell.adTitleLabel.text = "\(adPointer[CLASSIF_TITLE]!)"
        cell.adDescrLabel.text = "\(adPointer[CLASSIF_DESCRIPTION]!)"
        
        // Get image
        let imageFile = adPointer[CLASSIF_IMAGE1] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.adImage.image = UIImage(data:imageData)
            } } }
        
        
return cell
}
    
// SELECT AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var favClass = PFObject(className: FAV_CLASS_NAME)
    favClass = favoritesArray[indexPath.row] as! PFObject
    // Get favorite Ads as a Pointer
    var adPointer = favClass[FAV_AD_POINTER] as! PFObject
    
    let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
    // Pass the Ad ID to the Controller
    showAdVC.singleAdID = adPointer.objectId!
    self.navigationController?.pushViewController(showAdVC, animated: true)
}

    

// REMOVE THIS AD FROM YOUR FAVORITES
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
}
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete selected Ad
            var favClass = PFObject(className: FAV_CLASS_NAME)
            favClass = favoritesArray[indexPath.row] as! PFObject
            
            favClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    
                } else {
                    var alert = UIAlertView(title: APP_NAME,
                    message: "Something went wrong, try again later",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                    alert.show()
                } }

            // Remove record in favoritesArray and the tableView's row
            self.favoritesArray.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    
}

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
