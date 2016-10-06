//
//  TabMenuPageViewController.swift
//  TabMenu
//
//  Created by K.Kawakami on 2016/10/04.
//  Copyright © 2016年 川上健太郎. All rights reserved.
//

import UIKit

public class TabMenuPageViewController: UIPageViewController {
    
    internal var tabMenuItems: [(viewController: UIViewController, title: String)] = []
    
    fileprivate var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabMenuItems.map{ $0.viewController }.index(of: viewController)
    }
    fileprivate var currentIndexPath: IndexPath? {
        guard let index = self.currentIndex else {
            return nil
        }
        return IndexPath(item: index, section: 0)
    }
    fileprivate var option = TabMenuOptionGroup()
    
    lazy internal var tabMenuView: TabMenuView = TabMenuView(option: self.option, tabMenuItems: self.tabMenuItems)
    
    //MARK - Initialize
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(tabMeuItems: [(viewController: UIViewController, title: String)], option: TabMenuOptionGroup) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.tabMenuItems = tabMeuItems
        self.option = option
    }
    
    //MARK: - Life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPageViewController()
        setUpScrollView()
        setUpTabMenuView()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PageViewController
    
    fileprivate func setUpPageViewController() {
        view.backgroundColor = option.tabMenuBackGroundColor
        
        delegate = self
        dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        
        setViewControllers(
            [tabMenuItems[0].viewController],
            direction: .forward,
            animated: true,
            completion: nil
        )
    }
    
    // MARK: - TabMenuView
    
    fileprivate func setUpTabMenuView() {
        tabMenuView.delegate = self
        tabMenuView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: UIScrollView
    
    fileprivate func setUpScrollView() {
        let scrollView = view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.delegate = self
    }
}

extension TabMenuPageViewController: UIPageViewControllerDataSource {
    
    //MARK: - Enum
    
    fileprivate enum TransitionCondition {
        case Before
        case After
    }
    
    fileprivate func transitionViewController(_ currentViewController: UIViewController, condition: TransitionCondition) -> UIViewController? {
        guard var index = tabMenuItems.map({ $0.viewController }).index(of: currentViewController) else {
            return nil
        }
        
        switch condition {
        case .Before:
            index -= 1
        case .After:
            index += 1
        }
        
        if index < 0 {
            index = tabMenuItems.count - 1
        } else if index == tabMenuItems.count {
            index = 0
        }
        
        if 0..<tabMenuItems.count ~= index {
            return tabMenuItems[index].viewController
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return transitionViewController(viewController, condition: .After)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return transitionViewController(viewController, condition: .Before)
    }
}

extension TabMenuPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let currentIndexPath = self.currentIndexPath else {
            return
        }
        tabMenuView.scrollToHorizontalCenter(at: currentIndexPath)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentIndex = self.currentIndex else {
            return
        }
        tabMenuView.update(at: currentIndex)
    }
}

extension TabMenuPageViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            let scrollOffsetX: CGFloat = scrollView.contentOffset.x - view.frame.width
            tabMenuView.scrollCurrentBarView(scrollOffsetX)
        }
    }
}

extension TabMenuPageViewController: TabMenuViewDelegate {
    public func tappedItemTitleButton(at indexPath: IndexPath, direction: UIPageViewControllerNavigationDirection) {
        let fixedIndex = indexPath.item % tabMenuItems.count
        setViewControllers([tabMenuItems[fixedIndex].viewController], direction: direction, animated: true) { _ in
            self.tabMenuView.update(at: indexPath.item)
        }
    }
}

