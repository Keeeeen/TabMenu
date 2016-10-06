//
//  TabMenuView.swift
//  TabMenu
//
//  Created by K.Kawakami on 2016/10/04.
//  Copyright © 2016年 川上健太郎. All rights reserved.
//

import UIKit

// MARK: - Construction

fileprivate struct Const {
    fileprivate static let toManyTimesOfItems: Int = 4
}

// MARK: - Protocol

protocol TabMenuViewDelegate {
    func tappedItemTitleButton(at indexPath: IndexPath, direction: UIPageViewControllerNavigationDirection)
}

// MARK: - UIView

public class TabMenuView: UIView {
    
    @IBOutlet var tabMenuView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentBarView: UIView!
    @IBOutlet weak var currentBarViewWidthConstraints: NSLayoutConstraint!

    internal var currentBarViewHidden: Bool = false {
        didSet {
            currentBarView.isHidden = currentBarViewHidden
        }
    }
    
    internal var tabMenuItemTitles = [String]()
    internal var currentIndex: Int = 0
    internal var currentIndexPath: IndexPath {
        return IndexPath(item: currentIndex, section: 0)
    }
    
    internal var delegate: TabMenuViewDelegate?
    internal var tabMenuCollectionViewCell: TabMenuCollectionViewCell?
    
    fileprivate var option = TabMenuOptionGroup()
    fileprivate var collectionViewContentOffsetX: CGFloat = 0.0
    
    // MARK: Initialize
    
    init(option: TabMenuOptionGroup, tabMenuItems: [(viewController: UIViewController, title: String)]) {
        super.init(frame: CGRect.zero)
        
        self.option = option
        tabMenuItemTitles = tabMenuItems.map({ $0.title })
        currentIndex = tabMenuItems.count
        
        Bundle(for: TabMenuView.self).loadNibNamed("TabMenuView", owner: self, options: nil)
        addSubview(tabMenuView)
        
        let nib = UINib(nibName: "TabMenuCollectionViewCell", bundle: Bundle(for: TabMenuView.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "tabMenuCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.scrollsToTop = false
        
        tabMenuCollectionViewCell = nib.instantiate(withOwner: nil, options: nil).first as? TabMenuCollectionViewCell
        
        let folowLayout = UICollectionViewFlowLayout()
        folowLayout.scrollDirection = .horizontal
        folowLayout.minimumLineSpacing = 0.0
        folowLayout.minimumInteritemSpacing = 0.0
        collectionView.collectionViewLayout = folowLayout
        
        setUpAutoLayout()
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Layout
    
    fileprivate func layout() {
        tabMenuView.backgroundColor = option.tabMenuBackGroundColor
    }
    
    //MARK: AutoLayouts
    
    fileprivate func setUpAutoLayout() {
        let top = NSLayoutConstraint(
            item: tabMenuView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let left = NSLayoutConstraint(
            item: tabMenuView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let bottom = NSLayoutConstraint (
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: tabMenuView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let right = NSLayoutConstraint(
            item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: tabMenuView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0
        )
        
        tabMenuView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([top, left, bottom, right])
    }
    
    // MARK: - Life cycle
    
    override public func layoutSubviews() {
//        super.layoutSubviews()
        
        collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        
        guard let cell = tabMenuCollectionViewCell else {
            return
        }
        currentBarViewWidthConstraints.constant = cell.size(tabMenuItemTitles[0]).width
    }
    
    // MARK: Animation
    
    fileprivate func currentBarViewHiddenOfVisiableCells() {
        currentBarViewHidden = false
        collectionView.visibleCells.flatMap({ $0 as? TabMenuCollectionViewCell }).forEach({ $0.currentBarViewHidden = true })
    }
    
    fileprivate func transform(_ indexPath: IndexPath) -> IndexPath {
        if indexPath.item < tabMenuItemTitles.count {
            return IndexPath(item: indexPath.item + tabMenuItemTitles.count, section: 0)
        } else if indexPath.item > tabMenuItemTitles.count * 2 {
            return IndexPath(item: indexPath.item - tabMenuItemTitles.count, section: 0)
        } else {
            return indexPath
        }
    }
    
    fileprivate func scrollCurrentBarViewForTap(at indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        guard let tappedCell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        currentBarViewWidthConstraints.constant = tappedCell.frame.width
    }
    
    internal func scrollCurrentBarView(_ contentOffsetX: CGFloat) {
        currentBarViewHiddenOfVisiableCells()
        let scrollRate: CGFloat = contentOffsetX / frame.width
        
        var nextIndexPath: IndexPath?
        if scrollRate < 0 {
            nextIndexPath = IndexPath(item: self.currentIndex - 1, section: 0)
        } else if scrollRate > 0 {
            nextIndexPath = IndexPath(item: self.currentIndex + 1, section: 0)
        }
        
        guard
            let indexPath = nextIndexPath,
            let nextCell = collectionView.cellForItem(at: indexPath) as? TabMenuCollectionViewCell,
            let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabMenuCollectionViewCell
            else {
                return
        }
        
        if fabs(scrollRate) > 0.6 {
            nextCell.isCurrent = true
            currentCell.isCurrent = false
        }
        
        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }
        
        let distanceBetweenCell: CGFloat = currentCell.frame.width / 2 + nextCell.frame.width / 2
        let scrollWidth: CGFloat = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
        
        collectionView.contentOffset.x = collectionViewContentOffsetX + scrollRate * distanceBetweenCell
        currentBarViewWidthConstraints.constant = currentCell.frame.width + scrollWidth
    }
    
    internal func scrollToHorizontalCenter(at indexPath: IndexPath) {
        currentBarViewHiddenOfVisiableCells()
        
        let transformedIndexPath = transform(indexPath)
        collectionView.scrollToItem(at: transformedIndexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView.contentOffset.x
    }
    
    internal func update(at index: Int) {
        collectionViewContentOffsetX = 0.0
        currentIndex = transform(IndexPath(item: index, section: 0)).item
        collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        
        collectionView.visibleCells.flatMap({ $0 as? TabMenuCollectionViewCell }).forEach({
            if let indexPath = collectionView.indexPath(for: $0) , indexPath == currentIndexPath {
                $0.isCurrent = true
            } else {
                $0.isCurrent = false
            }
        })
    }
}

// MARK: - UICollectionViewDataSource

extension TabMenuView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabMenuItemTitles.count * Const.toManyTimesOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabMenuCell", for: indexPath) as? TabMenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let fixedIndex = indexPath.item % tabMenuItemTitles.count
        cell.itemTitleLabel.text = tabMenuItemTitles[fixedIndex]
        cell.option = option
        cell.setUpLayout()
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TabMenuView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TabMenuCollectionViewCell else {
            return
        }
        
        if indexPath.item % tabMenuItemTitles.count == currentIndex % tabMenuItemTitles.count {
            cell.currentBarViewHidden = false
            cell.isCurrent = true
        } else {
            cell.currentBarViewHidden = true
            cell.isCurrent = false
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TabMenuView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = tabMenuCollectionViewCell else {
            return CGSize.zero
        }
        
        let fixedIndex: Int = indexPath.item % tabMenuItemTitles.count
        let cellSize = cell.size(self.tabMenuItemTitles[fixedIndex])
        return cellSize
    }
}

// MARK: - UIScrollViewDelegate

extension TabMenuView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageViewItemContentSize = scrollView.contentSize.width / CGFloat(Const.toManyTimesOfItems)
        
        if scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= pageViewItemContentSize * 2 {
            self.collectionView.contentOffset.x = pageViewItemContentSize
        }
        
        guard scrollView.isDragging , let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabMenuCollectionViewCell  else {
            return
        }
        currentBarViewHidden = true
        currentCell.currentBarViewHidden = false
    }
}

// MARK: - TabMenuCollectionViewCellDelegate

extension TabMenuView: TabMenuCollectionViewCellDelegate {
    public func itemTitleButtonTapped(_ sender: UIButton) {
        currentBarViewHiddenOfVisiableCells()
        
        let point: CGPoint = sender.convert(CGPoint.zero, to: collectionView)
        
        guard let tappedIndexPath = collectionView.indexPathForItem(at: point) else {
            return
        }
        var direction: UIPageViewControllerNavigationDirection
        if tappedIndexPath.item < currentIndex || tappedIndexPath.item < tabMenuItemTitles.count {
            direction = .reverse
        } else {
            direction = .forward
        }
        
        delegate?.tappedItemTitleButton(at: tappedIndexPath, direction: direction)
        scrollCurrentBarViewForTap(at: tappedIndexPath)
    }
}
