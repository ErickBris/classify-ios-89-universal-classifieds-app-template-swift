/* =======================

- Classify -

made by FV iMAGINATION ©2015
for CodeCanyon

==========================*/


import UIKit
import Parse


class Signup: UIViewController,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var signupOutlet: UIButton!
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Round views corners
    signupOutlet.layer.cornerRadius = 5
    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 300)
    
}
    

// Touch the view to dismiss the keyboard) =====================================
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
// SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    var userForSignUp = PFUser()
    userForSignUp.username = usernameTxt.text
    userForSignUp.password = passwordTxt.text
    userForSignUp.email = emailTxt.text
    
    showHUD()
    
    userForSignUp.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
        if error == nil { // Successful Signup
            self.dismissViewControllerAnimated(true, completion: nil)
            hudView.removeFromSuperview()
            
        } else { // No signup, something went wrong
            var alert = UIAlertView(title: APP_NAME,
            message: "Something went wrong while registering your account, please try again",
            delegate: nil,
            cancelButtonTitle: "OK")
            alert.show()
            hudView.removeFromSuperview()
        }
    }
  
}
   
    
    
/* TEXTFIELD DELEGATES ========*/
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {   passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {   emailTxt.resignFirstResponder()   }
        
return true
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
