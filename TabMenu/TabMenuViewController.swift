//
//  TabMenuViewController.swift
//  TabMenu
//
//  Created by K.Kawakami on 2016/10/04.
//  Copyright © 2016年 川上健太郎. All rights reserved.
//

import UIKit

open class TabMenuViewController: UIViewController {

    public func setUpPageViewController(tabMenuItems: [(viewController: UIViewController, title: String)], options: [TabMenuOption]?) {
        let option = TabMenuOptionGroup(options: options)
        let pageViewController = TabMenuPageViewController(tabMeuItems: tabMenuItems, option: option)
        pageViewController.view.frame = CGRect.zero
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        let top = NSLayoutConstraint(
            item       : pageViewController.view,
            attribute  : .top,
            relatedBy  : .equal,
            toItem     : topLayoutGuide,
            attribute  : .bottom,
            multiplier : 1.0,
            constant   : option.tabMenuHeight
        )
        
        let left = NSLayoutConstraint(
            item       : pageViewController.view,
            attribute  : .leading,
            relatedBy  : .equal,
            toItem     : view,
            attribute  : .leading,
            multiplier : 1.0,
            constant   : 0.0
        )
        
        let right = NSLayoutConstraint(
            item       : pageViewController.view,
            attribute  : .trailing,
            relatedBy  : .equal,
            toItem     : view,
            attribute  : .trailing,
            multiplier : 1.0,
            constant   : 0.0
        )
        
        let bottom = NSLayoutConstraint(
            item       : pageViewController.view,
            attribute  : .bottom,
            relatedBy  : .equal,
            toItem     : view,
            attribute  : .bottom,
            multiplier : 1.0,
            constant   : 0.0
        )
        
        view.addConstraints([top, left, right, bottom])
        self.setUpTabMenuView(with: option)
    }
    
    fileprivate func setUpTabMenuView(with option: TabMenuOptionGroup) {
        guard let pageViewController = childViewControllers[0] as? TabMenuPageViewController else {
            return
        }
        let tabMenuView = pageViewController.tabMenuView
        
        let height = NSLayoutConstraint(
            item: tabMenuView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1.0,
            constant: option.tabMenuHeight
        )
        
        tabMenuView.addConstraint(height)
        view.addSubview(tabMenuView)

        let top = NSLayoutConstraint(
            item: tabMenuView,
            attribute: .top,
            relatedBy: .equal,
            toItem: topLayoutGuide,
            attribute: .bottom,
            multiplier:1.0,
            constant: 0.0
        )
        
        let left = NSLayoutConstraint(
            item: tabMenuView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let right = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: tabMenuView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0
        )
        
        view.addConstraints([top, left, right])
        view.layoutSubviews()
    }
}
