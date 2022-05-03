/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Home: UIViewController,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
GADInterstitialDelegate
{

    /* Views */
    @IBOutlet var searchOutlet: UIButton!
    @IBOutlet var termsOfUseOutlet: UIButton!
    
    @IBOutlet var fieldsView: UIView!
    @IBOutlet var keywordsTxt: UITextField!
    @IBOutlet var whereTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var categoriesScrollView: UIScrollView!
    
    var adMobInterstitial: GADInterstitial!

    
    /* Variables */
    var classifArray = NSMutableArray()
    var catButton = UIButton()
    
    

override func viewWillAppear(animated: Bool) {
    searchedAdsArray.removeAllObjects()
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(3 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial()
    adMobInterstitial.adUnitID = ADMOB_UNIT_ID
    var request = GADRequest()
    // request.testDevices = [""]
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.showInterstitial()
    }
    
    
    // Round views corners
    searchOutlet.layer.cornerRadius = 8
    searchOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    searchOutlet.layer.shadowOffset = CGSizeMake(0, 1.5)
    searchOutlet.layer.shadowOpacity = 0.8

    termsOfUseOutlet.layer.cornerRadius = 8
    
    
    // Put fieldsView in the center of the screen
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        fieldsView.center = CGPointMake(view.frame.size.width/2, 300 )
    }
    
    // Hide the Categ. PickerView
    categoryContainer.frame.origin.y = view.frame.size.height
    view.bringSubviewToFront(categoryContainer)
    
    setupCategoriesScrollView()
    
}

    
// SETUP CATEGORIES SCROLL VIEW
func setupCategoriesScrollView() {
        var xCoord: CGFloat = 5
        var yCoord: CGFloat = 0
        var buttonWidth:CGFloat = 90
        var buttonHeight: CGFloat = 90
        var gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        // Loop for creating buttons ========
        for itemCount = 0; itemCount < categoriesArray.count; itemCount++ {
            // Create a Button
            catButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            catButton.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight)
            catButton.tag = itemCount
            catButton.showsTouchWhenHighlighted = true
            catButton.setTitle("\(categoriesArray[itemCount])", forState: UIControlState.Normal)
            catButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
            catButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            catButton.setBackgroundImage(UIImage(named: "\(categoriesArray[itemCount])"), forState: UIControlState.Normal)
            catButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
            catButton.layer.cornerRadius = 5
            catButton.clipsToBounds = true
            catButton.addTarget(self, action: "catButtTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // Add Buttons & Labels based on xCood
            xCoord +=  buttonWidth + gapBetweenButtons
            categoriesScrollView.addSubview(catButton)
        } // END LOOP ================================
    
        // Place Buttons into the ScrollView =====
        categoriesScrollView.contentSize = CGSizeMake( (buttonWidth+5) * CGFloat(itemCount), yCoord)
}

    
/* MARK - ADMOB DELEGATES */
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        println("present Interstitial")
    }
}
    
    
// CATEGORY BUTTON TAPPED
func catButtTapped(sender: UIButton) {
    var button = sender as UIButton
    var categoryStr = "\(button.titleForState(UIControlState.Normal)!)"
    searchedAdsArray.removeAllObjects()
    
    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryStr)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    searchedAdsArray.addObject(object)
            } }
            // Go to Browse Ads VC
            let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
            self.navigationController?.pushViewController(baVC, animated: true)
            
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: self,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }

    
}
    
    
    
    
// SEARCH BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchedAdsArray.removeAllObjects()

    var keywordsArray = keywordsTxt.text.componentsSeparatedByString(" ") as NSArray

    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_DESCRIPTION_LOWERCASE, containsString: "\(keywordsArray[0])")
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryTxt.text!)
    query.whereKey(CLASSIF_ADDRESS_STRING, containsString: whereTxt.text.lowercaseString)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    searchedAdsArray.addObject(object)
                } }
            if searchedAdsArray.count > 0 {
            // Go to Browse Ads VC
             let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
            self.navigationController?.pushViewController(baVC, animated: true)
          
            } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Nothing found with your search keywords, try different keywords, location or category",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
            }
            
            
        } else {
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong, try again later or check your internet connection",
            delegate: nil,
            cancelButtonTitle: "OK" )
            alert.show()
        }
    }
    

}

    
    
    
/* MARK -  TEXTFIELD DELEGATE */
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        whereTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
        
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        whereTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == keywordsTxt {  whereTxt.becomeFirstResponder(); hideCatPickerView()  }
    if textField == whereTxt {  categoryTxt.becomeFirstResponder()  }

return true
}
    
    
    
/* MARK - PICKERVIEW DELEGATES */
func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1;
}

func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoriesArray.count
}
    
func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return categoriesArray[row]
}

func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryTxt.text = "\(categoriesArray[row])"
}

    
// POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    postVC.postID = ""
    presentViewController(postVC, animated: true, completion: nil)
}

    
// PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
        hideCatPickerView()
}
    
    
// DISMISS KEYBOARD ON TAP
@IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
    keywordsTxt.resignFirstResponder()
    whereTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    hideCatPickerView()
}
    
    
// SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height - self.categoryContainer.frame.size.height-44
    }, completion: { (finished: Bool) in  });
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  });
}
    
    
    
//SHOW TERMS OF USE
@IBAction func termsOfUseButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
