//
//  LoginViewController.swift
//  UberPool
//
//  Created by Jeevan on 01/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


@objc
protocol LoginViewControllerDelegate {
    @objc optional func userAuthenticatedForPessanger()
    @objc optional func userAuthenticatedForDriver()
}

class LoginViewController: UIViewController,Alertable {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var btnAuth: AnimatorButton!
    
    var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
       view.addKeyboardObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.removeKeyboardObservers()
    }
    
    //MARK: - Overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func dismissMe(_ sender: Any) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let homeNavVC = appDelegate.containerViewController.homeNavigationController
        homeNavVC!.willMove(toParentViewController: nil)
        homeNavVC!.removeFromParentViewController()
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
       // self.dismiss(animated: true, completion: nil)
    }
    
    func removeCurrentVC(){
    }
    
    @IBAction func authButtonClicked(_ sender: Any) {
        
        if !emailField.text!.isEmpty,!passwordField.text!.isEmpty {
            
            btnAuth.animatedTheButton(shouldAnimate: true, title: nil)
            view.endEditing(true)
            signInWithAuth()
        }
        
    }
    
    func signInWithAuth() {

        if let email = emailField.text, let password = passwordField.text {
           
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if error == nil,let userLaunch = user  {
                    
                    self.createUseRecord(authUser: userLaunch)
                }
                else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        self.btnAuth.animatedTheButton(shouldAnimate: false, title: "SignIn/SignUp")

                        switch errCode {
                        case .invalidEmail:
                            self.showAlert("invalid email")
                            print("invalid email")
                        case .emailAlreadyInUse:
                            print("in use")
                            self.showAlert("Email Already In use")
                        case  .invalidCredential:
                            self.showAlert("Wrong Password/Email")
                            print("Wrong Password/Email")
                        case .userNotFound:
                             self.signUpuser(email: email, password: password)
                        default:
                            self.showAlert(error!.localizedDescription)
                            print("Create User Error: \(error?.localizedDescription)")
                            return
                        }
                    }
                    
                    print("Sign in Issues \(error)")
                   
                }
                
            })
        }
    }
    
    func createUseRecord(authUser:User) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            let userData = ["provider":authUser.providerID] as [String:Any]
            DataService.instace.createFirebaseDBUser(uid: authUser.uid, userData: userData, isDriver: false)
            
            AppConfig.configureForUserType(authUser: authUser, isDriver: false)
            delegate?.userAuthenticatedForPessanger?()
        } else {
            let userData = ["provider":authUser.providerID,
                            "userIsDriver":true,
                            "isPickUpModeEnabled":false,
                            "isDriverOnTrip":false] as [String:Any]
            
            DataService.instace.createFirebaseDBUser(uid: authUser.uid, userData: userData, isDriver: true)
            AppConfig.configureForUserType(authUser: authUser, isDriver: true)
            delegate?.userAuthenticatedForDriver?()
        }
    }
    
    func setUpShareInstnace(isDriver:Bool)  {
        
        AppConfig.sharedInstance.userID = Auth.auth().currentUser?.uid
        AppConfig.sharedInstance.userEmail = Auth.auth().currentUser?.email
        AppConfig.sharedInstance.isPickModeEnabled = false
        AppConfig.sharedInstance.isDriver = isDriver
    }

    func signUpuser(email:String,password:String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let errornumb = error {
                print("Sign-Up issue\(errornumb)")
            }
            else {
                print("Sign Up Successfully with email")
                if let userAuth  = user {
               
                     self.createUseRecord(authUser: userAuth)
                }
            }
        }
    }
}
