
import Foundation
import UIKit

protocol SidePanelViewControllerDelegate {
 // func didSelectAnimal(_ item: Animal)
    
    func diSelectTitle(pagetitle:String)
    
    func didSelectButton(buttonTag:Int)
    
    func navigateToLogin() 
}

extension SidePanelViewControllerDelegate where Self : ContainerViewController {

    func didSelectButton(buttonTag:Int) {

        print("index of the item is \(buttonTag)")

    }

    func diSelectTitle(pagetitle:String) {

        if let vc = UIStoryboard.getNextViewController() {

            self.toggleLeftPanel()

            self.present(vc, animated: true, completion: {

                vc.tittleLabel.text = pagetitle
            })

        }
    }

    func addnewVC(tag:Int) {

        if let vc = UIStoryboard.getNextViewController() {
            vc.tagValue = tag

            self.present(vc, animated: true, completion: nil)

        }
    }

    func navigateToLogin() {

        self.toggleLeftPanel()
        self.goToLoginScreen()

    }

    func removeCurrentController()  {

        if let _ = self.currentViewController {

            self.currentViewController.removeFromParentViewController()
            self.currentViewController.view.removeFromSuperview()
            homeNavigationController.willMove(toParentViewController: nil)
            homeNavigationController.view.removeFromSuperview()
            homeNavigationController.removeFromParentViewController()
            homeNavigationController = nil
            self.currentViewController = nil
        }

    }

    func removeDummyview() {
        if let view = self.whiteView {
            view.removeFromSuperview()
        }
    }

    func goToLoginScreen() {

        self.removeCurrentController()
        self.removeDummyview()
        if let viewcontroller = UIStoryboard.getLoginViewController() {
            self.currentViewController = viewcontroller
            viewcontroller.delegate = self
            homeNavigationController = NavigationController(rootViewController: viewcontroller)
            homeNavigationController.isNavigationBarHidden = true
            view.addSubview(homeNavigationController.view)
            addChildViewController(homeNavigationController)
            homeNavigationController.didMove(toParentViewController: self)

        }
    }

    func naviagteToDriverPickerVC() {

        self.removeCurrentController()
        self.removeDummyview()
        if let viewcontroller = UIStoryboard.getDriverPickerVC() {
            self.navigationView?.alpha = 1.0
            self.currentViewController = viewcontroller
            homeNavigationController = NavigationController(rootViewController: viewcontroller)
            homeNavigationController.isNavigationBarHidden = true
            view.addSubview(homeNavigationController.view)
            addChildViewController(homeNavigationController)
            homeNavigationController.didMove(toParentViewController: self)
        }

        self.addNavigationview()
    }

    func addHomeController() {

        self.removeCurrentController()
        self.removeDummyview()
        if let viewcontroller = UIStoryboard.homeViewController() {
            self.navigationView?.alpha = 1.0
            viewcontroller.delegate = self
            self.currentViewController = viewcontroller
            homeNavigationController = NavigationController(rootViewController: viewcontroller)
            homeNavigationController.isNavigationBarHidden = true
            view.addSubview(homeNavigationController.view)
            addChildViewController(homeNavigationController)
            homeNavigationController.didMove(toParentViewController: self)
        }
        self.addNavigationview()
    }
}


