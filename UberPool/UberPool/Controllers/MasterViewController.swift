//
//  MasterViewController.swift
//  UberPool
//
//  Created by Jeevan on 08/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
 
     var navigationView:NavigationView?
    /*
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
    */
    var leftViewController: SidePanelViewController?
    var nextViewController:GTXVC?
    
    var homeNavigationController: NavigationController!
    var sampleVC: SampleVC!
   // var loginVC:LoginViewController!


    override func viewDidLoad() {
        super.viewDidLoad()
        setFirstVC()
        addNavigationview()

        // Do any additional setup after loading the view.
    }
    
    /*
     
     - (void)styleNavBar {
     // 1. hide the existing nav bar
     [self.navigationController setNavigationBarHidden:YES animated:NO];
     
     // 2. create a new nav bar and style it
     UINavigationBar *newNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64.0)];
     [newNavBar setTintColor:[UIColor whiteColor]];
     
     // 3. add a new navigation item w/title to the new nav bar
     UINavigationItem *newItem = [[UINavigationItem alloc] init];
     newItem.title = @"Paths";
     [newNavBar setItems:@[newItem]];
     
     // 4. add the nav bar to the main view
     [self.view addSubview:newNavBar];
     }
     */
    
    func addNavigationview() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
       /* let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 90))
        let navItem = UINavigationItem() */
        if let _ = self.navigationView {
            self.navigationView = nil
            self.navigationView?.removeFromSuperview()
        }
        self.navigationView = loadNavigation()
        view.addSubview(self.navigationView!)
    }
    
    
    func loadNavigation() -> NavigationView {
        
        let bundle = Bundle.main
        let nib = UINib(nibName: "NavigationView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! NavigationView
        return view
    }
    
    
    func setFirstVC() {
        
        let board = UIStoryboard(name: "Main", bundle: Bundle.main)
        sampleVC = board.instantiateViewController(withIdentifier: "sampleVC") as? SampleVC
        
        homeNavigationController  = NavigationController(rootViewController: sampleVC)
        view.addSubview(sampleVC.view)
        addChildViewController(sampleVC)
        homeNavigationController.didMove(toParentViewController: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

}
