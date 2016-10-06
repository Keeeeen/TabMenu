//
//  TabMenuCollectionViewCell.swift
//  TabMenu
//
//  Created by K.Kawakami on 2016/10/04.
//  Copyright © 2016年 川上健太郎. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol TabMenuCollectionViewCellDelegate {
    func itemTitleButtonTapped(_ sender: UIButton)
}

// MARK: - UICollectionViewCell

public class TabMenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTitleButton: UIButton!
    @IBOutlet weak var currentBarView: UIView!
    
    internal var delegate: TabMenuCollectionViewCellDelegate? = nil
    internal var option = TabMenuOptionGroup()
    
    internal var isCurrent: Bool = false {
        didSet {
            isCurrent ? highLightItemTitle() : unHighLightItemTitle()
        }
    }
        
    internal var currentBarViewHidden: Bool = true {
        didSet {
            currentBarView.isHidden = currentBarViewHidden
            //currentBarViewHidden ? unHighLightItemTitle() : highLightItemTitle()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: itemTitleLabel.intrinsicContentSize.width + option.tabMenuWidthMargin * 2, height: option.tabMenuHeight)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
//        currentBarViewHidden = true
    }
    
    internal func setUpLayout() {
        backgroundColor = option.tabMenuBackGroundColor
        itemTitleLabel.textColor = option.defaultItemTitleTextColor
    }
    
    internal func size(_ itemTitleText: String) -> CGSize {
        itemTitleLabel.text = itemTitleText
        itemTitleLabel.invalidateIntrinsicContentSize()
        return intrinsicContentSize
    }
    
    fileprivate func highLightItemTitle() {
        itemTitleLabel.textColor = option.highLightItemTitleTextColor
    }
    
    fileprivate func unHighLightItemTitle() {
        itemTitleLabel.textColor = option.defaultItemTitleTextColor
    }
    
    @IBAction func itemTitleButtonTapped(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        delegate?.itemTitleButtonTapped(button)
    }
}
