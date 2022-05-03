/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse
import MapKit
import GoogleMobileAds
import AudioToolbox
import MessageUI


class ShowSingleAd: UIViewController,
UIAlertViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
GADInterstitialDelegate,
MFMailComposeViewControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var adTitleLabel: UILabel!
    
    @IBOutlet var imagesScrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var adDescrTxt: UITextView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var messageTxt: UITextView!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    
    @IBOutlet var sendOutlet: UIButton!
    var reportButt = UIButton()
    
    var adMobInterstitial: GADInterstitial!
    
    
    /* Variables */
    var singleAdArray = NSMutableArray()
    var singleAdID = String()
    
    var dataURL = NSData()
    var reqURL = NSURL()
    var request = NSMutableURLRequest()
    var receiverEmail = ""
    var postTitle = ""
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    

    
override func viewWillAppear(animated: Bool) {
    // Query the selected Ad to get its details
    singleAdArray.removeAllObjects()
    querySingleAd()
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Initialize a Report Button
    reportButt = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    reportButt.adjustsImageWhenHighlighted = false
    reportButt.frame = CGRectMake(0, 0, 44, 44)
    reportButt.setBackgroundImage(UIImage(named: "reportButt"), forState: UIControlState.Normal)
    reportButt.addTarget(self, action: "reportButt:", forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64(5 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial()
    adMobInterstitial.adUnitID = ADMOB_UNIT_ID
    var request = GADRequest()
    // request.testDevices = [""]
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.showInterstitial()
    }
    
    
    // Reset variables for Reply
    receiverEmail = ""
    postTitle = ""
    
    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 1350)
    
    // Setup images ScrollView
    imagesScrollView.contentSize = CGSizeMake(imagesScrollView.frame.size.width*3, imagesScrollView.frame.size.height)
    image1.frame.origin.x = 0
    image2.frame.origin.x = imagesScrollView.frame.size.width
    image3.frame.origin.x = imagesScrollView.frame.size.width*2
    
    // Round views corners
    sendOutlet.layer.cornerRadius = 8

}
    
    
func querySingleAd() {
    println("SINGLE AD ID: \(singleAdID)")

    var query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_ID, equalTo: singleAdID)
    query.includeKey(CLASSIF_USER)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            if let objects = objects as? [PFObject] {
                for object in objects {
                    self.singleAdArray.addObject(object)
            } }
            // Show Ad details
            self.showAdDetails()
                
            } else {
                var alert = UIAlertView(title: APP_NAME,
                message: "Something went wrong, try again later or check your internet connection",
                delegate: nil,
                cancelButtonTitle: "OK" )
                alert.show()
            }
        }

}
    
func showAdDetails() {
    var classif = PFObject(className: CLASSIF_CLASS_NAME)
    classif = singleAdArray[0] as! PFObject
    
    // Get Ad Title
    adTitleLabel.text = "\(classif[CLASSIF_TITLE]!)"
    self.title = "\(classif[CLASSIF_TITLE]!)"
    
     // Get image1
    let imageFile1 = classif[CLASSIF_IMAGE1] as? PFFile
    imageFile1?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image1.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 1
        } } }
    
    // Get image2
    let imageFile2 = classif[CLASSIF_IMAGE2] as? PFFile
    imageFile2?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image2.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 2
        } } }
    
    // Get image3
    let imageFile3 = classif[CLASSIF_IMAGE3] as? PFFile
    imageFile3?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image3.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 3
        } } }
    
    // Get Ad Price
    priceLabel.text = "\(classif[CLASSIF_PRICE]!)"
    
    // Get Ad Description
    adDescrTxt.text = "\(classif[CLASSIF_DESCRIPTION]!)"
    
    // Get Ad Address
    addressLabel.text = "\(classif[CLASSIF_ADDRESS_STRING]!)"
    addPinOnMap(addressLabel.text!)

    // Get username
    var user = classif[CLASSIF_USER] as! PFUser
    user.fetchIfNeeded()
    usernameLabel.text = user.username!
    
}
    
 
    
/* MARK - ADMOB DELEGATES */
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        println("present Interstitial")
    }
}

    
    
// ADD A PIN ON THE MAP
func addPinOnMap(address: String) {
        if mapView.annotations.count != 0 {
            annotation = mapView.annotations[0] as! MKAnnotation
            mapView.removeAnnotation(annotation)
        }
        // Make a search on the Map
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
            
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            // Place not found or GPS not available
            if localSearchResponse == nil  {
                var alert = UIAlertView(title: APP_NAME,
                message: "Place not found, or GPS not available",
                delegate: nil,
                cancelButtonTitle: "Try again" )
                alert.show()
            }
                
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.adTitleLabel.text
            self.pointAnnotation.subtitle = self.addressLabel.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse.boundingRegion.center.latitude, longitude:localSearchResponse.boundingRegion.center.longitude)
                
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinView.annotation)
                
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }


}

/* MARK - SCROLLVIEW DELEGATE */
func scrollViewDidScroll(scrollView: UIScrollView) {
    // switch pageControl to current page
    let pageWidth = imagesScrollView.frame.size.width
    let page = Int(floor((imagesScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
    pageControl.currentPage = page
}
    
    
/* MARK - TEXTFIELD DELEGATE */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTxt { emailTxt.becomeFirstResponder() }
    if textField == emailTxt { phoneTxt.becomeFirstResponder() }
    if textField == phoneTxt { phoneTxt.resignFirstResponder() }
        
return true
}
    
    
    
    
// SEND REPLY BUTTON
@IBAction func sendReplyButt(sender: AnyObject) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = singleAdArray[0] as! PFObject
    var user = classifClass[CLASSIF_USER] as! PFUser
    user.fetchIfNeeded()
    
    receiverEmail = user.email!
    postTitle = adTitleLabel.text!
    println("\(receiverEmail)")
    
    if messageTxt.text != "" &&
       emailTxt.text != ""  &&
       nameTxt.text != ""
    {
            
    let strURL = "\(PATH_TO_PHP_FILE)sendReply.php?name=\(nameTxt.text)&fromEmail=\(emailTxt.text)&tel=\(phoneTxt.text)&messageBody=\(messageTxt.text)&receiverEmail=\(receiverEmail)&postTitle=\(postTitle)"
        
        reqURL = NSURL(string: strURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        request = NSMutableURLRequest()
        request.URL = reqURL
        request.HTTPMethod = "GET"
        var returnData = NSMutableData()
        var connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        println("URL: \(reqURL)")
        
        var alert = UIAlertView(title: APP_NAME,
        message: "Thanks, You're reply has been sent!",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
            
    
    // SOME REQUIRED FIELD IS EMPTY...
    } else {
    var alert = UIAlertView(title: APP_NAME,
    message: "Please fill all the required fields.",
    delegate: nil,
    cancelButtonTitle: "OK")
    alert.show()
    }
    
}
    
    
 
// REPORT AD BUTTON
func reportButt(sender:UIButton) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = singleAdArray[0] as! PFObject
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([MY_REPORT_EMAIL_ADDRESS])
    mailComposer.setSubject("Reporting Inappropriate Ad")
    mailComposer.setMessageBody("Hello,<br>I am reporting an ad with ID: <strong>\(classifClass.objectId!)</strong><br> and Title: <strong>\(classifClass[CLASSIF_TITLE]!)</strong><br>since it contains inappropriate contents and violates the Terms of Use of this App.<br><br>Please moderate this post.<br><br>Thank you very much,<br>Regards.", isHTML: true)
    presentViewController(mailComposer, animated: true, completion: nil)
}
// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
        var outputMessage = ""
        switch result.value {
        case MFMailComposeResultCancelled.value:  outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.value:  outputMessage = "Mail saved"
        case MFMailComposeResultSent.value:  outputMessage = "Thanks for reporting this post. We will check it out asap and moderate it"
        case MFMailComposeResultFailed.value:  outputMessage = "Something went wrong with sending Mail, try again later."
        default: break
        }
    var alert = UIAlertView(title: APP_NAME,
    message: outputMessage,
    delegate: self,
    cancelButtonTitle: "Ok" )
    alert.show()
        
    dismissViewControllerAnimated(false, completion: nil)
}

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
