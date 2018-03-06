//
//  StoryBoardExtension.swift
//  UberPool
//
//  Created by Jeevan on 11/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import UIKit

 extension UIStoryboard {
    
    static func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    static func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LeftViewController") as? SidePanelViewController
    }
    
    static func rightViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "RightViewController") as? SidePanelViewController
    }
    
    static func homeViewController() -> HomeVC? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
    }
    
    static func getNextViewController() -> GTXVC? {
        
        return mainStoryboard().instantiateViewController(withIdentifier: "GT") as? GTXVC
    }
    
    static func getLoginViewController() -> LoginViewController? {
        
        return mainStoryboard().instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController
    }
    
    static func getDriverPickerVC() -> DriverPickerVC? {
        
        return mainStoryboard().instantiateViewController(withIdentifier: "ToPicker") as? DriverPickerVC
    }
}
