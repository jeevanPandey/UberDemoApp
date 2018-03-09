//
//  ContainerVCExtension.swift
//  UberPool
//
//  Created by Jeevan on 06/03/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import UIKit

extension ContainerViewController: HomeViewControllerDelegate {

    func toggleLeftPanel() {

        let collapsed = (currentState == .bothCollapsed)

        if collapsed {
            addLeftPanelViewController()
        }

        animateLeftPanel(collapsed : collapsed)
    }

    func toggleRightPanel() {

    }

    func addLeftPanelViewController() {

        if let vc = UIStoryboard.leftViewController() {
            leftViewController = vc
            addChildSidePanelController(vc)
            vc.delegate = self
        }
    }

    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {

        let initalFrame = CGRect(x: -centerPanelExpandedOffset, y: 0, width: centerPanelExpandedOffset, height: (self.leftViewController?.view.frame.size.height)!)
        self.leftViewController?.view.frame = initalFrame
        view.addSubview((self.leftViewController?.view)!)
        addChildViewController(self.leftViewController!)
        self.leftViewController!.didMove(toParentViewController: self)
    }

    func animateLeftPanel(collapsed: Bool) {
        if collapsed {
            currentState = .leftPanelExpanded
            animateXPostion(targetPostion: self.view.frame.size.width/2+centerPanelExpandedOffset, isCollapseed: collapsed)

        } else {
            self.currentState = .bothCollapsed
            animateXPostion(targetPostion: 0, isCollapseed: collapsed)
        }
    }

    func animateXPostion(targetPostion:CGFloat,isCollapseed:Bool) {

        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.currentViewController.view.frame.origin = CGPoint(x: targetPostion, y: 0)
                        self.navigationView?.frame.origin = CGPoint(x: targetPostion, y: 0)
                        if isCollapseed {
                            let initalFrame = CGRect(x: 0, y: 0, width: self.leftMenuOffset, height:(self.leftViewController?.view.frame.size.height)!)
                            self.leftViewController?.view.frame = initalFrame
                            self.navigationView?.menuButton.transform = CGAffineTransform(rotationAngle:CGFloat(Double.pi/2))
                        }
                        else {
                            let initalFrame = CGRect(x: -self.leftMenuOffset, y: 0, width: self.leftMenuOffset, height:self.leftViewController!.view.frame.size.height)
                            self.leftViewController?.view.frame = initalFrame
                            self.navigationView?.menuButton.transform = CGAffineTransform.identity
                        }
        }, completion:{finished in

        })

    }

    func moveTheViewBy(targetPostion: CGFloat) {

        self.currentViewController.view.center  =   CGPoint(x: self.currentViewController.view.center.x + targetPostion, y: self.currentViewController.view.center.y)
        self.navigationView?.center = CGPoint(x: self.navigationView!.center.x + targetPostion, y: self.navigationView!.center.y)
        let initalFrame = CGRect(x: self.currentViewController.view.frame.origin.x-self.leftMenuOffset, y: 0, width: self.leftMenuOffset, height:(self.leftViewController?.view.frame.size.height)!)
        self.leftViewController?.view.frame = initalFrame
       
    }

    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {

        UIView.animate(withDuration: 0.5, animations: {

            self.homeViewController.view.frame.origin = CGPoint(x: targetPosition, y: 0)

        }, completion: completion)
    }

    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {

        if shouldShowShadow {
            leftViewController?.view.layer.shadowOpacity = 0.8
        } else {
            leftViewController?.view.layer.shadowOpacity = 0.0
        }
    }

}
