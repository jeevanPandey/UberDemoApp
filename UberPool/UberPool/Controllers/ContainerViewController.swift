

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

    func addGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        if let view =  self.navigationView {
            view.addGestureRecognizer(panGestureRecognizer)
        }

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


    func loadWaitingView() -> MenuWaitScreen {

        let bundle = Bundle.main
        let nib = UINib(nibName: "MenuWaitScreen", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! MenuWaitScreen
        return view
    }
    func addDummyView() {

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
        self.addGesture()
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

extension ContainerViewController : UIGestureRecognizerDelegate {

    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {

        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)

        switch recognizer.state {

        case .began:
            if currentState == .bothCollapsed {
                if gestureIsDraggingFromLeftToRight {
                    addLeftPanelViewController()
                }
                showShadowForCenterViewController(true)
            }

        case .changed:

            if let rview = recognizer.view {
                let translation = recognizer.translation(in: rview)
                moveTheViewBy(targetPostion: translation.x)
                print("translattion x: \(translation.x)")
                recognizer.setTranslation(CGPoint.zero, in: rview)
            }

        case .ended:
            if let _ = leftViewController,
                let rview = recognizer.view {

                let hasMovedGreaterThanHalfway = rview.center.x  > view.bounds.size.width-100
                if (hasMovedGreaterThanHalfway) {
                    animateLeftPanel(collapsed: true)
                }
                else {
                    animateLeftPanel(collapsed: false)
                }


            }

        default:
            break
        }
    }
}

