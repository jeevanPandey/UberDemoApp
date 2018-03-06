
import UIKit
import Firebase

class SidePanelViewController: UIViewController {
  
 var delegate: SidePanelViewControllerDelegate?
    
    @IBOutlet var modeSwitcher: UISwitch!
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var userPic: RoundedImageView!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var signInOutButton: UIButton!
    
    @IBOutlet var stackSwitch: UIStackView!
    
    @IBOutlet var userTypeLabel: UILabel!
    override func viewDidLoad() {
    super.viewDidLoad()
  }
    
    override func viewWillAppear(_ animated: Bool) {

        hideFields()
        
        self.setUpView()
        
       // self.observereFireBaseChnagesForDriver()
        //self.observereFireBaseChnagesForPassenger()
        
        self.setUpView()
    }
    
    func setUpView() {
        
        if AppConfig.sharedInstance.isDriver {
            
            self.stackSwitch.isHidden = false
            self.userPic.isHidden = false
            self.userEmailLabel.isHidden = false
            self.userEmailLabel.text = Auth.auth().currentUser?.email
            self.userTypeLabel.isHidden = false
            self.userTypeLabel.text = "Driver"
            self.modeSwitcher.isHidden = false
            self.modeLabel.isHidden = false
            let isPickOn:Bool = AppConfig.sharedInstance.isPickModeEnabled
            
            if(isPickOn) {
                self.modeLabel.text = "PICK-UP MODE ENABLED"
            }
            else {
                
                self.modeLabel.text = "PICK-UP MODE DISABLED"
            }
            self.modeSwitcher.isOn = isPickOn
            
            self.signInOutButton.setTitle("Sign-Out", for: .normal)
            
        }
        else {
            
            self.stackSwitch.isHidden = true
            self.userPic.isHidden = false
            self.userEmailLabel.isHidden = false
            self.userEmailLabel.text = Auth.auth().currentUser?.email
            self.userTypeLabel.isHidden = false
            self.userTypeLabel.text = "Passenger"
            self.modeSwitcher.isOn = false
            self.modeSwitcher.isHidden = true
            self.modeLabel.isHidden = true
            self.signInOutButton.setTitle("Sign-Out", for: .normal)
        }
        
    }
    
    func observereFireBaseChnagesForPassenger() {
     
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
             
                for eachSnap in snaps {
                
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        self.stackSwitch.isHidden = true
                        self.userPic.isHidden = false
                        self.userEmailLabel.isHidden = false
                        self.userEmailLabel.text = Auth.auth().currentUser?.email
                        self.userTypeLabel.isHidden = false
                        self.userTypeLabel.text = "Passenger"
                        self.modeSwitcher.isOn = false
                        self.modeSwitcher.isHidden = true
                        self.modeLabel.isHidden = true
                        self.signInOutButton.setTitle("Sign-Out", for: .normal)
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    func observereFireBaseChnagesForDriver() {
        
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        self.stackSwitch.isHidden = false
                        self.userPic.isHidden = false
                        self.userEmailLabel.isHidden = false
                        self.userEmailLabel.text = Auth.auth().currentUser?.email
                        self.userTypeLabel.isHidden = false
                        self.userTypeLabel.text = "Driver"
                        self.modeSwitcher.isHidden = false
                        self.modeLabel.isHidden = false
                        let isPickOn:Bool = eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                        
                        if(isPickOn) {
                            self.modeLabel.text = "PICK-UP MODE ENABLED"
                        }
                        else {
                            
                            self.modeLabel.text = "PICK-UP MODE DISABLED"
                        }
                        self.modeSwitcher.isOn = isPickOn
                        
                        self.signInOutButton.setTitle("Sign-Out", for: .normal)
                        
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    @IBAction func didSelectItem(_ sender: Any) {
        if let btn = sender as? UIButton {
        delegate?.diSelectTitle(pagetitle:btn.titleLabel!.text!)
           
             let tag = btn.tag
             delegate?.didSelectButton(buttonTag: tag)
        }
    }
    
    @IBAction func gotoLoginController(_ sender: Any) {
        
        if Auth.auth().currentUser == nil {
        
            delegate?.navigateToLogin()
        }
        else {
            do {
           
                try  Auth.auth().signOut()
                delegate?.navigateToLogin()
                
            } catch (let exception) {
                print("exception occurred \(exception)")
            }
         
        }
        
    }
    
    @IBAction func modeSwitchClicked(_ sender: Any) {
        
        let currentUserID = Auth.auth().currentUser?.uid
        if(modeSwitcher.isOn) {
            AppConfig.sharedInstance.isPickModeEnabled = true
            self.modeLabel.text = "PICK-UP MODE ENABLED"
            DataService.instace.REF_DRIVERS.child(currentUserID!).updateChildValues(["isPickUpModeEnabled":modeSwitcher.isOn])
        }
        else {
          
            AppConfig.sharedInstance.isPickModeEnabled = false
            self.modeLabel.text = "PICK-UP MODE DISABLED"
            DataService.instace.REF_DRIVERS.child(currentUserID!).updateChildValues(["isPickUpModeEnabled":modeSwitcher.isOn])
        }
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.containerViewController.toggleLeftPanel()
    }
    func hideFields() {
        self.modeSwitcher.isOn = false
        stackSwitch.isHidden = true
        self.modeSwitcher.isHidden = true
        self.modeLabel.isHidden = true
        self.userPic.isHidden = true
        self.userEmailLabel.isHidden = true
        self.userTypeLabel.isHidden = true
    }
    
}




