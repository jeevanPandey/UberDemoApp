

import UIKit
import QuartzCore
import Firebase

class ContainerViewController: UIViewController,SidePanelViewControllerDelegate {
    
    enum SlideOutState {
        case bothCollapsed
        case leftPanelExpanded
    }
    
    let centerPanelExpandedOffset: CGFloat = 60
    let leftMenuOffset:CGFloat = 250
    var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    var leftViewController: SidePanelViewController?
    var nextViewController:GTXVC?
    var homeNavigationController: NavigationController!
    var homeViewController: HomeVC!
    var loginVC:LoginViewController!
    var navigationView:NavigationView?
    var currentViewController:UIViewController!
    var whiteView:MenuWaitScreen?

    override func viewDidLoad() {
       
        super.viewDidLoad()
        self.addDummyView()
        self.setupVC()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupVC() {
        
        guard let _ = Auth.auth().currentUser?.uid else {
            self.goToLoginScreen()
            return
        }
       
        DataService.instace.checkPassengerType { (eachSnap, isDriver) in
            
            if isDriver {
                
                 AppConfig.sharedInstance.userID = Auth.auth().currentUser?.uid
                 AppConfig.sharedInstance.userEmail = Auth.auth().currentUser?.email
                 AppConfig.sharedInstance.isDriver = true
                 let isPickOn:Bool = eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                 AppConfig.sharedInstance.isPickModeEnabled = isPickOn
                 self.naviagteToDriverPickerVC()
            }
            
            else {
                
                 AppConfig.sharedInstance.userID = Auth.auth().currentUser?.uid
                 AppConfig.sharedInstance.userEmail = Auth.auth().currentUser?.email
                 AppConfig.sharedInstance.isDriver = false
                 AppConfig.sharedInstance.isPickModeEnabled = false
                self.addHomeController()
            }
        }

    }

   /* func addSearchView() {
        removeOverlaysAnnotations()

        if let _ = self.customView {
            return
        }
        self.customView = self.loadViewFromNib()
        self.customView.delegate = self
        self.customView.mapView = self.mapView
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        customView.widthAnchor.constraint(equalToConstant: view.frame.size.width-40).isActive = true
        customView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height-200).isActive = true
        anchor =  customView.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor, constant: self.view.frame.size.height-10)
        anchor.isActive = true
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.anchor.constant = 180
            self.view.layoutIfNeeded()

        }) { (iscompleted) in

        }
    } */

    func loadWaitingView() -> MenuWaitScreen {

        let bundle = Bundle.main
        let nib = UINib(nibName: "MenuWaitScreen", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! MenuWaitScreen
        return view
    }
    func addDummyView() {
        
       /* self.whiteView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        self.whiteView?.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: (whiteView?.frame.size.width)!/2-80, y: (whiteView?.frame.size.height)!/2, width: 200, height: 50))
        label.text = "Setting up your moves 🚙🚙 "
        whiteView?.addSubview(label)
        self.view.addSubview(whiteView!) */
        self.whiteView = loadWaitingView()
        self.whiteView?.frame = CGRect(x: 0, y: 0,width: self.view.bounds.size.width,
                                       height: self.view.bounds.size.height)
        self.view.addSubview(self.whiteView!)

    }
    func addNavigationview() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if let _ = self.navigationView {
            self.navigationView?.removeFromSuperview()
            self.navigationView = nil
        }
        self.navigationView = loadNavigation()
        self.navigationView?.menuButton.addTarget(self, action: #selector(toggleLeftPanel), for: .touchUpInside)
        view.addSubview(self.navigationView!)
    }
    
    func loadNavigation() -> NavigationView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: "NavigationView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! NavigationView
        return view
    }
    
    func addLoginVC(){
        
        loginVC = UIStoryboard.getLoginViewController()
        loginVC.delegate = self
        homeNavigationController = NavigationController(rootViewController: loginVC)
        homeNavigationController.isNavigationBarHidden = true
        view.addSubview(loginVC.view)
        addChildViewController(homeNavigationController)
        homeNavigationController.didMove(toParentViewController: self)
        
    }
}

extension ContainerViewController:LoginViewControllerDelegate {
    
    func userAuthenticatedForPessanger() {
        
        self.addHomeController()
    }
    
    func userAuthenticatedForDriver() {
        self.naviagteToDriverPickerVC()
        
    }
}

