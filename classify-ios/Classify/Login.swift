/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/

import UIKit
import Parse
import ParseUI

var reloadUser = Bool()


class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var loginOutlet: UIButton!
    @IBOutlet var signupOutlet: UIButton!

    
    /* Variables */
    
    
    
override func prefersStatusBarHidden() -> Bool {
    return true
}
    override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Round views corners
    loginOutlet.layer.cornerRadius = 5
    signupOutlet.layer.cornerRadius = 5
    

    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
    
    self.navigationController?.navigationBarHidden = true
}

    
// LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
    var username = usernameTxt.text
    var password = passwordTxt.text
    
    passwordTxt.resignFirstResponder()
    
    showHUD()
    

    PFUser.logInWithUsernameInBackground(usernameTxt.text, password:passwordTxt.text) {
        (user, error) -> Void in
        
        if user != nil { // Login successfull
            self.dismissViewControllerAnimated(true, completion: nil)
            hudView.removeFromSuperview()
            reloadUser = true
            
        } else { // Login failed. Try again
            let alert = UIAlertView(title: APP_NAME,
            message: "Loing Error",
            delegate: self,
            cancelButtonTitle: "Retry",
            otherButtonTitles: "Sign Up")
            alert.show()
            
            hudView.removeFromSuperview()
        }
    }
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
        signupButt(self)
    }
    
    var emailStr = alertView.textFieldAtIndex(0)?.text
    if alertView.buttonTitleAtIndex(buttonIndex) == "Reset Password" {
        println("\(emailStr)")
    }
}

    
    
// SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("Signup") as! Signup
    signupVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    self.presentViewController(signupVC, animated: true, completion: nil)
}
  
    
    
    
    
/*  MARK - TEXTFIELD DELEGATES  */
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {
        passwordTxt.becomeFirstResponder()
    }
    if textField == passwordTxt  {
        passwordTxt.resignFirstResponder()
    }
return true
}
    
    
// Touch the view to dismiss the keyboard) =====================================
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
// FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Type your email address you used to register.",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Reset Password")
    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
    alert.show()
}


    
// Show HUD ========================================================
func showHUD() {
    hudView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
    hudView.backgroundColor = UIColor.darkGrayColor()
    hudView.alpha = 0.9
    hudView.layer.cornerRadius = hudView.bounds.size.width/2
    
    indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    hudView.addSubview(indicatorView)
    view.addSubview(hudView)
    indicatorView.startAnimating()
}
//========================================================
    
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
}
}
